(local json (require :lib.json))

(local images {})

(fn -load-image [image-name]
  (tset images image-name (love.graphics.newImage image-name))
  (. images image-name))

(fn -get-image [image-name]
  (or (. images image-name) (-load-image image-name)))

(local quads {})

(fn -load-quad [render-tile]
  (let [quad (. render-tile :quad)
        quad-id (.. (. quad :image) "__" (. quad :original-tile-id))]
    (tset quads quad-id
          (love.graphics.newQuad (. quad :x-offset) (. quad :y-offset)
                                 (. quad :width) (. quad :height)
                                 (-get-image (.. :assets/ (. quad :image)))))
    (. quads quad-id)))

(fn -create-sprite-batches [render-tiles]
  (accumulate [batch-table {} _ render-tile (pairs render-tiles)]
    (if (= false (. render-tile :visible))
        batch-table
        (let [image-name (-> (. render-tile :quad) (. :image))
              image (-get-image (.. :assets/ image-name))
              sprite-batch (or (. batch-table image-name)
                               (let [new-batch (love.graphics.newSpriteBatch image
                                                                             576)]
                                 (tset batch-table image-name new-batch)
                                 new-batch))]
          (sprite-batch:add (-load-quad render-tile) (. render-tile :display-x)
                            (. render-tile :display-y) 0 CAMERA-ZOOM)
          batch-table))))

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

(fn create-layers [quads layers map-data]
  (icollect [_k layer (ipairs layers)]
    (icollect [idx tile-id (ipairs (. layer :data))]
      (let [columns (. layer :width)
            row-zidx (math.floor (/ (- idx 1) columns))
            col-zidx (math.fmod (- idx 1) columns)
            quad (. quads tile-id)]
        (if (= quad nil)
            nil
            (let [layer-zoom (/ (. quad :width) (. map-data :tilewidth))
                  attrs {: quad
                         : tile-id
                         :original-tile-id (. quad :original-tile-id)
                         ; it seems _REALLY OFF_ that I need to apply this offset to y after layer zoom
                         :x (* col-zidx (. quad :width) (/ layer-zoom))
                         :y (- (* row-zidx (. quad :height) (/ layer-zoom))
                               (- (. quad :width) (. map-data :tilewidth)))
                         :width 16
                         :height 16
                         :visible (. layer :visible)}]
              (tset attrs :display-x (* (. attrs :x) CAMERA-ZOOM))
              (tset attrs :display-y (* (. attrs :y) CAMERA-ZOOM))
              attrs))))))

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
    (-> (icollect [_k tileset-metadata (ipairs tilesets)]
          (let [source (. tileset-metadata :source)
                first-gid (. tileset-metadata :firstgid)
                tileset-fh (io.open (.. :./src/map/ source))
                tileset-json (tileset-fh:read :*all)
                tileset-data (json.decode tileset-json)]
            (get-quad-table first-gid tileset-data)))
        (merge-tables)
        (create-layers layers map-data))))

; (do (local world (require :src.world)) (world.read-tiled-map :map_50_50.json))
; (do (local world (require :src.world)) (-> (world.read-tiled-map :map_50_50.json) (. 2) ) )
{: read-tiled-map :create-sprite-batches -create-sprite-batches}
