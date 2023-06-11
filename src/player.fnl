(local util (require :util))

(local player-sprite-sheet (love.graphics.newImage :assets/Warrior_Blue.png))

(local player-tile-size 64)

(fn offset-pairs-to-quads [offset-pairs]
  (icollect [_ [x y] (ipairs offset-pairs)]
    (love.graphics.newQuad x y 192 192 (player-sprite-sheet:getDimensions))))

(local quad-sets {:idle (offset-pairs-to-quads [[0 0]
                                                [192 0]
                                                [384 0]
                                                
                                                [768 0]
                                                [960 0]])
                  :up (offset-pairs-to-quads [[0 192]
                                              [192 192]
                                              [384 192]
                                              [567 192]
                                              [768 192]
                                              [960 192]])
                  :down (offset-pairs-to-quads [[0 192]
                                                [192 192]
                                                [384 192]
                                                [567 192]
                                                [768 192]
                                                [960 192]])
                  :left (offset-pairs-to-quads [[0 192]
                                                [192 192]
                                                [384 192]
                                                [567 192]
                                                [768 192]
                                                [960 192]])
                  :right (offset-pairs-to-quads [[0 192]
                                                 [192 192]
                                                 [384 192]
                                                 [567 192]
                                                 [768 192]
                                                 [960 192]])})

(local player-state {:player-entity true
                     :shove-delta-x 0
                     :shove-delta-y 0
                     :shove-delta-per-frame 0
                     :x 256
                     :to-x 256
                     :y 256
                     :to-y 256
                     :zoom-mod 0.75
                     :width 16
                     :height 16
                     :action {:name :idle
                              :animating true
                              :frame-delta 0
                              :frames-per-quad 16}
                     :speed 3
                     : quad-sets
                     :draw [player-sprite-sheet
                            (-> (. quad-sets :down)
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
        (-> (. player-state :action) (tset :animating true))
        (-> (. player-state :action) (tset :name :idle))
        (-> (. player-state :action) (tset :frame-delta 0)))))

{: player-state : on-update : on-key-pressed : on-key-released}
