(love.window.setMode 0 0)

(fn choose-sprite-quad [sprite-quads delta delta-per-frame]
  (let [cur-frame (+ 1 (math.floor (/ delta delta-per-frame)))]
    (if (. sprite-quads cur-frame)
        [(. sprite-quads cur-frame) delta]
        (choose-sprite-quad sprite-quads 0 delta-per-frame))))

(fn run-player-state [speed player-state player-sprite-quads keyboard]
  (let [[sprite-quad next-delta] (choose-sprite-quad (->> (. player-state
                                                             :direction)
                                                          (. player-sprite-quads))
                                                     (. player-state
                                                        :direction-delta)
                                                     (. player-state
                                                        :delta-per-frame))]
    (tset player-state :direction-delta next-delta)
    (tset player-state :sprite-quad sprite-quad))
  (if (. player-state :moving)
      (do
        (tset player-state :direction-delta
              (+ (. player-state :direction-delta) speed))
        (case (. player-state :direction)
          :up
          (do
            (tset player-state :y (- (. player-state :y) speed))
            player-state)
          :down
          (do
            (tset player-state :y (+ (. player-state :y) speed))
            player-state)
          :left
          (do
            (tset player-state :x (- (. player-state :x) speed))
            player-state)
          :right
          (do
            (tset player-state :x (+ (. player-state :x) speed))
            player-state)))
      nil))

(fn handle-player-movement [player-state key]
  (case key
    :up
    (do
      (tset player-state :moving true)
      (tset player-state :direction :up)
      (tset player-state :direction-delta 0)
      true)
    :down
    (do
      (tset player-state :moving true)
      (tset player-state :direction :down)
      (tset player-state :direction-delta 0)
      true)
    :left
    (do
      (tset player-state :moving true)
      (tset player-state :direction :left)
      (tset player-state :direction-delta 0)
      true)
    :right
    (do
      (tset player-state :moving true)
      (tset player-state :direction :right)
      (tset player-state :direction-delta 0)
      true)))

(local -player-sprite-sheet (love.graphics.newImage :player_sprite_sheet.png))

(local -player-sprite-quads
       {:down [(love.graphics.newQuad 0 0 16 16
                                      (-player-sprite-sheet:getDimensions))
               (love.graphics.newQuad 0 30 16 16
                                      (-player-sprite-sheet:getDimensions))]
        :left [(love.graphics.newQuad 30 0 16 16
                                      (-player-sprite-sheet:getDimensions))
               (love.graphics.newQuad 30 30 16 16
                                      (-player-sprite-sheet:getDimensions))]
        :up [(love.graphics.newQuad 60 0 16 16
                                    (-player-sprite-sheet:getDimensions))
             (love.graphics.newQuad 60 30 16 16
                                    (-player-sprite-sheet:getDimensions))]
        :right [(love.graphics.newQuad 90 30 16 16
                                       (-player-sprite-sheet:getDimensions))
                (love.graphics.newQuad 90 0 16 16
                                       (-player-sprite-sheet:getDimensions))]})

(local (w h) (love.window.getMode))

(local -player-state {:x (- (/ w 2) 32)
                      :y (- (/ h 2) 32)
                      :moving false
                      :direction :down
                      :direction-delta 0
                      :delta-per-frame 48
                      :speed 6
                      :sprite-quad (-> (. -player-sprite-quads :down)
                                       (. 1))})

(local -keyboard {:up false :down false :left false :right false})

(fn love.update [dt]
  (let [speed-delta (/ dt 0.0166)]
    (run-player-state (* (. -player-state :speed) speed-delta) -player-state
                      -player-sprite-quads -keyboard)))

(fn love.keypressed [key]
  (do
    (when (= :escape key) (love.event.quit))
    (tset -keyboard key true)
    (handle-player-movement -player-state key)
    else
    false))

(fn love.keyreleased [key]
  (tset -keyboard key false)
  (if (-> false 
          (or (= true (. -keyboard :up)))
          (or (= true (. -keyboard :down)))
          (or (= true (. -keyboard :left)))
          (or (= true (. -keyboard :right))))
      (-> false 
          (or (when (. -keyboard :up) (handle-player-movement :up)))
          (or (when (. -keyboard :down) (handle-player-movement :down)))
          (or (when (. -keyboard :left) (handle-player-movement :left)))
          (or (when (. -keyboard :right) (handle-player-movement :right))))
      (do
        (tset -player-state :moving false)
        (tset -player-state :direction-delta 0))))

(fn love.draw []
  (love.graphics.draw -player-sprite-sheet (. -player-state :sprite-quad)
                      (. -player-state :x) (. -player-state :y) 0 4))
