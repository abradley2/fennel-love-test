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
                     :x 256
                     :y 256
                     :action {:name :down
                              :animating false
                              :frame-delta 0
                              :frames-per-quad 16}
                     :speed 1.5
                     :quad-sets player-sprite-quads
                     :draw [player-sprite-sheet
                            (-> (. player-sprite-quads :down)
                                (. 1))]})

(fn handle-collisions [[next-x next-y] player-state area tile-idx?]
  (let [direction (. player-state :action)
        world (. area :world)
        tile-idx (or tile-idx? 1)
        world-tile (. world tile-idx)
        does-collide (case (-?> world-tile (. :original-tile-id))
                       1
                       false
                       8
                       false
                       9
                       false
                       10
                       false
                       17
                       false
                       18
                       false
                       nil
                       false
                       _
                       (util.check-collision (+ 4 next-x) (+ 10 next-y) 8 5
                                             (. world-tile :x) (. world-tile :y)
                                             16 16))]
    (if does-collide
        nil
        (if (= world-tile nil)
            (do
              (tset player-state :x next-x)
              (tset player-state :y next-y))
            (handle-collisions [next-x next-y] player-state area (+ tile-idx 1))))))

(fn on-update [delta player-state keyboard area]
  (let [speed (* (. player-state :speed) delta)]
    (if (-?> (. player-state :action) (. :animating))
        (do
          (-> (case (-> (. player-state :action) (. :name))
                :up
                [(. player-state :x) (- (. player-state :y) speed)]
                :down
                [(. player-state :x) (+ (. player-state :y) speed)]
                :left
                [(- (. player-state :x) speed) (. player-state :y)]
                :right
                [(+ (. player-state :x) speed) (. player-state :y)])
              (handle-collisions player-state area)))
        nil)))

(fn on-key-pressed [player-state key]
  (case key
    :up
    (tset player-state :action
          {:name :up :animating true :frame-delta 17 :frames-per-quad 16})
    :down
    (tset player-state :action
          {:name :down :animating true :frame-delta 17 :frames-per-quad 16})
    :left
    (tset player-state :action
          {:name :left :animating true :frame-delta 17 :frames-per-quad 16})
    :right
    (tset player-state :action
          {:name :right :animating true :frame-delta 17 :frames-per-quad 16}))
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
