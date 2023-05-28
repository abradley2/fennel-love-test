(love.window.setMode 640 640 {:resizable false})

(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))

(local player (require :player))
(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(local player-sprite-sheet (player.player-sprite-sheet))
(local player-sprite-quads (player.player-sprite-quads player-sprite-sheet))
(local player-state (player.init-player-state player-sprite-quads))

(local images {})

(fn load-image [image-name]
  (tset images image-name (love.graphics.newImage :assets/world_tiles.png))
  (. images image-name))

(fn get-image [image-name]
  (or (. images image-name) (load-image image-name)))

(fn love.update [dt]
  (let [speed-delta (/ dt 0.0166)]
    (player.run-player-state (* (. player-state :speed) speed-delta)
                             player-state player-sprite-quads -keyboard
                             world.tiles)))

(fn love.keypressed [key]
  (do
    (when (= :escape key) (love.event.quit))
    (tset -keyboard key true)
    (player.handle-player-movement player-state key)))

(fn love.keyreleased [key]
  (tset -keyboard key false)
  (if (-> false
          (or (= true (. -keyboard :up)))
          (or (= true (. -keyboard :down)))
          (or (= true (. -keyboard :left)))
          (or (= true (. -keyboard :right))))
      (-> false
          (or (when (. -keyboard :up) (player.handle-player-movement :up)))
          (or (when (. -keyboard :down) (player.handle-player-movement :down)))
          (or (when (. -keyboard :left) (player.handle-player-movement :left)))
          (or (when (. -keyboard :right) (player.handle-player-movement :right))))
      (do
        (tset player-state :moving false)
        (tset player-state :direction-delta 0))))

(fn love.draw []
  (each [_ tile (pairs world.tiles)]
    (love.graphics.draw world.overworld-sprite-sheet (. tile :quad) (. tile :x)
                        (. tile :y) 0 1))
  (love.graphics.draw player-sprite-sheet (. player-state :sprite-quad)
                      (. player-state :x) (. player-state :y) 0 1))
