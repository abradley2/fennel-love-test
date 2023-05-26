(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))

(local player (require :player))
(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(fn love.update [dt]
  (let [speed-delta (/ dt 0.0166)]
    (player.run-player-state (* (. player.player-state :speed) speed-delta)
                             player.player-state player.player-sprite-quads
                             -keyboard world.tiles)))

(fn love.keypressed [key]
  (do
    (when (= :escape key) (love.event.quit))
    (tset -keyboard key true)
    (player.handle-player-movement player.player-state key)))

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
        (tset player.player-state :moving false)
        (tset player.player-state :direction-delta 0))))

(fn love.draw []
  (each [_ tile (pairs world.tiles)]
    (love.graphics.draw world.overworld-sprite-sheet (. tile :quad) (. tile :x)
                        (. tile :y) 0 1))
  (love.graphics.draw player.player-sprite-sheet
                      (. player.player-state :sprite-quad)
                      (. player.player-state :x) (. player.player-state :y) 0 1))
