(local json (require :lib.json))

;; (local overworld-sprite-sheet (love.graphics.newImage :assets/world_tiles.png))

(fn get-quad-table [first-gid tileset-data quad-table? current-tile-idx?]
  (let [quad-table (or quad-table? {})
        current-tile-idx (or current-tile-idx? 1)
        tilecount (. tileset-data :tilecount)
        columns (. tileset-data :columns)
        spacing (. tileset-data :spacing)
        margin (. tileset-data :margin)
        tileheight (. tileset-data :tileheight)
        tilewidth (. tileset-data :tilewidth)]
    (if (> current-tile-idx tilecount)
        quad-table
        (do
          (let [sprite-row-zidx (math.floor (/ (- current-tile-idx 1) columns))
                sprite-col-zidx (math.fmod (- current-tile-idx 1) columns)]
            (tset quad-table (+ first-gid (- current-tile-idx 1))
                  {:width tilewidth
                   :height tileheight
                   :original-tile-id current-tile-idx
                   :image (. tileset-data :image)
                   :x-offset (+ margin
                                (+ (* spacing sprite-col-zidx)
                                   (* tilewidth sprite-col-zidx)))
                   :y-offset (+ margin
                                (+ (* spacing sprite-row-zidx)
                                   (* tileheight sprite-row-zidx)))})
            quad-table)
          (get-quad-table first-gid tileset-data quad-table
                          (+ 1 current-tile-idx))))))

(fn merge-tables [tables]
  (accumulate [joined [] _i table (pairs tables)]
    (do
      (each [i v (pairs table)] (tset joined i v))
      joined)))

(fn create-layers [quads layers]
  (icollect [_k layer (ipairs layers)]
    (icollect [idx tile-id (ipairs (. layer :data))]
      (let [columns (. layer :width)
            row-zidx (math.floor (/ (- idx 1) columns))
            col-zidx (math.fmod (- idx 1) columns)
            quad (. quads tile-id)]
        (if (= quad nil)
            nil
            {: quad
             : tile-id
             :x (* col-zidx (. quad :width))
             :y (* row-zidx (. quad :height))
             :visible (. layer :visible)})))))

(fn read-tiled-map [map-file]
  (let [map-fh (io.open (.. :./src/map/ map-file))
        map-json (map-fh:read :*all)
        map-data (json.decode map-json)
        tile-height (. map-data :tileheight)
        tile-width (. map-data :tilewidth)
        width (. map-data :width)
        height (. map-data :height)
        layers (. map-data :layers)
        tilesets (. map-data :tilesets)]
    (map-fh:close)
    (-> (collect [_k tileset-metadata (ipairs tilesets)]
          (let [source (. tileset-metadata :source)
                first-gid (. tileset-metadata :firstgid)
                tileset-fh (io.open (.. :./src/map/ source))
                tileset-json (tileset-fh:read :*all)
                tileset-data (json.decode tileset-json)]
            (values source (get-quad-table first-gid tileset-data))))
        merge-tables
        (create-layers layers))))

(fn read-map [map-file]
  (let [map-fh (io.open (.. :./src/map/ map-file))
        data (map-fh:read :*all)
        map-json (json.decode data)]
    (map-fh:close)
    {:sprite-layer (-> (. map-json :layers)
                       (. 1)
                       (. :data))
     :height (. map-json :height)
     :width (. map-json :width)
     :tile-height (. map-json :tileheight)
     :tile-width (. map-json :tilewidth)}))

(local area_x50_y50 (read-map :area_50_50.json))

; TODO: read all these directly from the tiled file

(local sprite-sheet-column-count 9)
(local column-count 32)
(local tile-width 16)
(local tile-height 16)
(local tileset-margin 1)
(local tileset-spacing 1)

(fn to-tiles [tiles -tile-idx? -all-tiles?]
  (let [tile-idx (or -tile-idx? 1)
        tile (. tiles tile-idx)
        all-tiles (or -all-tiles? [])]
    (if (= nil tile)
        all-tiles
        (let [sprite-row-zidx (math.floor (/ (- tile 1)
                                             sprite-sheet-column-count))
              sprite-col-zidx (- (math.fmod tile sprite-sheet-column-count) 1)
              map-row-zidx (math.floor (/ (- tile-idx 1) column-count))
              map-col-zidx (math.fmod (- tile-idx 1) column-count)
              x (* map-col-zidx tile-width)
              y (* map-row-zidx tile-height)
              x-offset (+ tileset-margin
                          (+ (* tileset-spacing sprite-col-zidx)
                             (* tile-height sprite-col-zidx)))
              y-offset (+ tileset-margin
                          (+ (* tileset-spacing sprite-row-zidx)
                             (* tile-width sprite-row-zidx)))]
          (tset all-tiles tile-idx {:quad (love.graphics.newQuad x-offset
                                                                 y-offset
                                                                 tile-width
                                                                 tile-height
                                                                 (overworld-sprite-sheet:getDimensions))
                                    : tile
                                    : tile-width
                                    : tile-height
                                    : x
                                    : y})
          (to-tiles tiles (+ tile-idx 1) all-tiles)))))

;; (local tiles (to-tiles (. area_x50_y50 :sprite-layer)))

;; {: tiles : overworld-sprite-sheet}
{: read-tiled-map : merge-tables}

;(do (local world (require :src.world)) (world.read-tiled-map :area_50_50.json))
