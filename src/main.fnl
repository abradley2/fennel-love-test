(local json (require :lib.json))
(local util (require :util))

; (love.window.setMode 512 512 {:resizable false})
(love.window.setMode 768 768 {:resizable false})
; (love.window.setMode 1024 1024 {:resizable false})

(love.graphics.setDefaultFilter :nearest)

(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))

; These are not configurable. Do not change.
(local area-grid 32)
(local area-size 512)
(local tile-size 16)

(local target-square (/ GAME-WIDTH area-grid))
(global CAMERA-ZOOM (/ target-square tile-size))

(local player (require :player))
(local player-sprite-sheet (player.player-sprite-sheet))
(local player-sprite-quads (player.player-sprite-quads player-sprite-sheet))
(local player-state (player.init-player-state player-sprite-quads))

(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(local area {:world nil :logic nil :enemies nil :sprite-batches nil})

(local world-map-data (let [world-map-fh (io.open :./src/map/map.world)
                            world-map-json (world-map-fh:read :*all)]
                        (json.decode world-map-json)))

(local game-state {:moving-area nil
                   :current-map (-> world-map-data (. :maps) (. 1))
                   :world-offset-x 0
                   :world-offset-y 0})

(fn load-next-area [map-idx?]
  (let [map-idx (or map-idx? 1)
        map (-> world-map-data (. :maps) (. map-idx))]
    (if (util.check-collision (. map :x) (. map :y) (. map :width)
                              (. map :height) (. player-state :x)
                              (. player-state :y) 1 1)
        map
        (load-next-area (+ map-idx 1)))))

(fn check-for-area-transition []
  (let [player-x (-> (. player-state :x) (+ (. game-state :world-offset-x)))
        player-y (-> (. player-state :y) (+ (. game-state :world-offset-y)))
        map-x (-> (. game-state :current-map) (. :x))
        map-y (-> (. game-state :current-map) (. :y))]
    (if (< (+ player-x 16) map-x) (load-next-area)
        (> player-x (+ map-x area-size)) (load-next-area)
        (< (+ player-y 16) map-y) (load-next-area)
        (> player-y (+ map-y area-size)) (load-next-area)
        nil)))

(fn set-area [area-name]
  (let [tiled-map (world.read-tiled-map (.. area-name :.json))]
    (tset area :world (. tiled-map :world))
    (tset area :logic (. tiled-map :logic))
    (tset area :enemies (. tiled-map :enemies))
    (tset area :sprite-batches
          (-> (. tiled-map :world) world.create-sprite-batches))))

(set-area :area_50_50)

(var tick 0)

(fn love.update [dt]
  (let [delta (/ dt 0.0166)]
    (set tick (+ tick dt))
    (if (> tick 0.25) (do
                        (check-for-area-transition)
                        (set tick 0)) nil)
    (player.on-update delta player-state player-sprite-quads -keyboard area)))

(fn love.keypressed [key]
  (do
    (when (= :escape key) (love.event.quit))
    (tset -keyboard key true)
    (player.on-key-pressed player-state key)))

(fn love.keyreleased [key]
  (tset -keyboard key false)
  (player.on-key-released player-state -keyboard key))

(fn love.draw []
  (each [_k sprite-batch (pairs (. area :sprite-batches))]
    (love.graphics.draw sprite-batch))
  (love.graphics.draw player-sprite-sheet (. player-state :sprite-quad)
                      (-> (. player-state :x) (* CAMERA-ZOOM))
                      (-> (. player-state :y) (* CAMERA-ZOOM)) 0 CAMERA-ZOOM))
