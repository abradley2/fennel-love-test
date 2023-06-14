(local util (require :util))

(local player-sprite-sheet (love.graphics.newImage :assets/Warrior_Blue.png))
(local player-sprite-sheet-flipped
       (love.graphics.newImage :assets/Warrior_Blue_Flipped.png))

(local player-tile-size 64)

(fn offset-pairs-to-quads [offset-pairs flipped]
  (icollect [_ [x y] (ipairs offset-pairs)]
    (love.graphics.newQuad x y 192 192
                           (if (= true flipped)
                               (player-sprite-sheet-flipped:getDimensions)
                               (player-sprite-sheet:getDimensions)))))

(local quad-sets
       {:idle (offset-pairs-to-quads [[0 0] [192 0] [384 0] [768 0] [960 0]])
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
                                       [960 192]])
        :attack-left (offset-pairs-to-quads [[960 384]
                                             [768 384]
                                             [576 384]
                                             [384 384]
                                             [192 384]
                                             [768 576]
                                             [567 567]
                                             [384 567]
                                             [192 567]])})

(local player-state {:player-entity true
                     :shove-delta-x 0
                     :shove-delta-y 0
                     :shove-delta-per-frame 0
                     :x-draw-offset -64
                     :y-draw-offset -64
                     :collision-box {:x-offset -16
                                     :y-offset -8
                                     :width 32
                                     :height 40}
                     :x 800
                     :to-x 800
                     :y 900
                     :to-y 900
                     :width 64
                     :height 64
                     :zoom-mod (/ 64 92)
                     :facing :down
                     :moving false
                     :attacking false
                     :sword-attack nil
                     :action {:name :idle
                              :animating true
                              :frame-delta 0
                              :frames-per-quad 8}
                     :speed 4
                     :sword-attack nil
                     : quad-sets
                     :draw [player-sprite-sheet
                            (-> (. quad-sets :down)
                                (. 1))]})

(fn on-update [delta player-state keyboard area]
  (let [speed (* (. player-state :speed) delta)]
    (when (-> (. player-state :action) (. :completed-loop))
      (when (-> (. player-state :action) (. :prev-action))
        (do
          (tset player-state :action
                (-> (. player-state :action) (. :prev-action)))
          (tset player-state :attacking false)
          (tset player-state :sword-attack nil)
          (tset player-state :moving false))))
    (if (-?> (. player-state :action) (. :animating))
        (case (-> (. player-state :action) (. :name))
          :up
          (do
            (tset player-state :facing :up)
            (tset player-state :moving true)
            (tset player-state :to-y (- (. player-state :y) speed)))
          :down
          (do
            (tset player-state :facing :down)
            (tset player-state :moving true)
            (tset player-state :to-y (+ (. player-state :y) speed)))
          :left
          (do
            (tset player-state :facing :left)
            (tset player-state :moving true)
            (tset player-state :to-x (- (. player-state :x) speed)))
          :right
          (do
            (tset player-state :facing :right)
            (tset player-state :moving true)
            (tset player-state :to-x (+ (. player-state :x) speed))))
        nil)))

(fn on-key-pressed [player-state key]
  (case key
    :space
    (if (-> player-state (. :action) (. :name) (= :attack))
        nil
        (case (. player-state :facing)
          :left
          (do
            (tset player-state :attacking true)
            (tset player-state :sword-attack
                  {:x (-> (. player-state :x) (- 48))
                   :y (-> (. player-state :y) (- 48))
                   :width 48
                   :height 48
                   :shove-delta-x 0
                   :shove-delta-y 0
                   :facing :left
                   :moving true
                   :shove-delta-per-frame 0})
            (tset player-state :action
                  {:name :attack-left
                   :animating true
                   :frame-delta 0
                   :frames-per-quad 3
                   :prev-action (. player-state :action)}))))
    :up
    (do
      (-> player-state (. :draw) (tset 1 player-sprite-sheet))
      (when (not (. player-state :attacking))
        (tset player-state :action
              {:name :up :animating true :frame-delta 9 :frames-per-quad 8})))
    :down
    (do
      (-> player-state (. :draw) (tset 1 player-sprite-sheet-flipped))
      (when (not (. player-state :attacking))
        (tset player-state :action
              {:name :down :animating true :frame-delta 9 :frames-per-quad 8})))
    :left
    (do
      (-> player-state (. :draw) (tset 1 player-sprite-sheet-flipped))
      (when (not (. player-state :attacking))
        (tset player-state :action
              {:name :left :animating true :frame-delta 9 :frames-per-quad 8})))
    :right
    (do
      (-> player-state (. :draw) (tset 1 player-sprite-sheet))
      (when (not (. player-state :attacking))
        (tset player-state :action
              {:name :right :animating true :frame-delta 9 :frames-per-quad 8}))))
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
      (when (not (. player-state :attacking))
        (do
          (tset player-state :moving false)
          (-> (. player-state :action) (tset :animating true))
          (-> (. player-state :action) (tset :name :idle))
          (-> (. player-state :action) (tset :frame-delta 0))))))

{: player-state : on-update : on-key-pressed : on-key-released}
