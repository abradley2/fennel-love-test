(local json (require :lib.json))

;; (local area_x50_y50 (require :src.map.area_50_50))
(local overworld-sprite-sheet
       (love.graphics.newImage :assets/overworld_sprite_sheet.png))

(fn read-map [map-file]
  (let [f (io.open map-file)
        data (f:read :*all)
        map-json (json.decode data)]
    (f:close)
    {:sprite-layer (-> (. map-json :layers)
                       (. 1)
                       (. :data))
     :height (. map-json :height)
     :width (. map-json :width)
     :tile-height (. map-json :tileheight)
     :tile-width (. map-json :tilewidth)}))

(local area_x50_y50 (read-map :src/map/area_50_50.tmj))

; TODO: read all these directly from the tiled file

(local sprite-sheet-column-count 9)
(local column-count 16)
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

(local tiles (to-tiles (. area_x50_y50 :sprite-layer)))

{: tiles : overworld-sprite-sheet}
