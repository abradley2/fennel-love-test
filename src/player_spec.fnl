(local player (require :src.player))

(fn init-player-state-suite []
  (it "Should set a default sprite-quad"
      (fn []
        (let [default-quad {}
              quads {:up [default-quad]
                     :right [default-quad]
                     :down [default-quad]
                     :left [default-quad]}
              init-player (player.init-player-state quads)]
          (assert.are.same (. init-player :sprite-quad) default-quad)))))

(describe :player.fnl
          (fn []
            (describe :init-player-state init-player-state-suite)))
