(local util (require :util))

(local player-sprite-sheet
       (love.graphics.newImage :assets/sprites/player_sprite_sheet.png))

(local player-sprite-quads
       {:down [(love.graphics.newQuad 0 0 16 16
                                      (player-sprite-sheet:getDimensions))
               (love.graphics.newQuad 0 30 16 16
                                      (player-sprite-sheet:getDimensions))]
        :left [(love.graphics.newQuad 30 0 16 16
                                      (player-sprite-sheet:getDimensions))
               (love.graphics.newQuad 30 30 16 16
                                      (player-sprite-sheet:getDimensions))]
        :up [(love.graphics.newQuad 60 0 16 16
                                    (player-sprite-sheet:getDimensions))
             (love.graphics.newQuad 60 30 16 16
                                    (player-sprite-sheet:getDimensions))]
        :right [(love.graphics.newQuad 90 30 16 16
                                       (player-sprite-sheet:getDimensions))
                (love.graphics.newQuad 90 0 16 16
                                       (player-sprite-sheet:getDimensions))]})

(local player-state {:player-entity true
                     :shove-delta-x 0
                     :shove-delta-y 0
                     :shove-delta-per-frame 0
                     :x 256
                     :to-x 256
                     :y 256
                     :to-y 256
                     :width 16
                     :height 16
                     :action {:name :down
                              :animating false
                              :frame-delta 0
                              :frames-per-quad 16}
                     :speed 3
                     :quad-sets player-sprite-quads
                     :draw [player-sprite-sheet
                            (-> (. player-sprite-quads :down)
                                (. 1))]})

(fn on-update [delta player-state keyboard area]
  (let [speed (* (. player-state :speed) delta)]
    (if (-?> (. player-state :action) (. :animating))
        (case (-> (. player-state :action) (. :name))
          :up
          (tset player-state :to-y (- (. player-state :y) speed))
          :down
          (tset player-state :to-y (+ (. player-state :y) speed))
          :left
          (tset player-state :to-x (- (. player-state :x) speed))
          :right
          (tset player-state :to-x (+ (. player-state :x) speed)))
        nil)))

(fn on-key-pressed [player-state key]
  (case key
    :up
    (tset player-state :action
          {:name :up :animating true :frame-delta 9 :frames-per-quad 8})
    :down
    (tset player-state :action
          {:name :down :animating true :frame-delta 9 :frames-per-quad 8})
    :left
    (tset player-state :action
          {:name :left :animating true :frame-delta 9 :frames-per-quad 8})
    :right
    (tset player-state :action
          {:name :right :animating true :frame-delta 9 :frames-per-quad 8}))
  player-state)

(fn on-key-released [player-state keyboard key]
  (if (-> false
          (or (= true (. keyboard :up)))
          (or (= true (. keyboard :down)))
          (or (= true (. keyboard :left)))
          (or (= true (. keyboard :right))))
      (-> false
          (or (when (. keyboard :up) (on-key-pressed :up)))
          (or (when (. keyboard :down) (on-key-pressed :down)))
          (or (when (. keyboard :left) (on-key-pressed :left)))
          (or (when (. keyboard :right) (on-key-pressed :right))))
      (do
        (-> (. player-state :action) (tset :animating false))
        (-> (. player-state :action) (tset :frame-delta 0)))))

{: player-state : on-update : on-key-pressed : on-key-released}
