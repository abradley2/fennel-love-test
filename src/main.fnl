(love.window.setMode 512 512 {:resizable false})
; (love.window.setMode 768 768 {:resizable false})
; (love.window.setMode 1024 1024 {:resizable false})

(love.graphics.setDefaultFilter :nearest)

(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))
(local area-grid 32)
(local target-square (/ GAME-WIDTH area-grid))
(global CAMERA-ZOOM (/ target-square 16))

(local player (require :player))
(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(local area {:world nil :logic nil :enemies nil :sprite-batches nil})

(fn set-area [area-name]
  (let [tiled-map (world.read-tiled-map (.. area-name :.json))]
    (tset area :world (. tiled-map :world))
    (tset area :logic (. tiled-map :logic))
    (tset area :enemies (. tiled-map :enemies))
    (tset area :sprite-batches
          (-> (. tiled-map :world) world.create-sprite-batches))))

(set-area :area_50_50)

(local player-sprite-sheet (player.player-sprite-sheet))
(local player-sprite-quads (player.player-sprite-quads player-sprite-sheet))
(local player-state (player.init-player-state player-sprite-quads))

(fn love.update [dt]
  (let [delta (/ dt 0.0166)]
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
