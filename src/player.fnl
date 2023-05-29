(fn -player-sprite-sheet []
  (love.graphics.newImage :assets/sprites/player_sprite_sheet.png))

(fn -player-sprite-quads [player-sprite-sheet]
  {:down [(love.graphics.newQuad 0 0 16 16 (player-sprite-sheet:getDimensions))
          (love.graphics.newQuad 0 30 16 16 (player-sprite-sheet:getDimensions))]
   :left [(love.graphics.newQuad 30 0 16 16 (player-sprite-sheet:getDimensions))
          (love.graphics.newQuad 30 30 16 16
                                 (player-sprite-sheet:getDimensions))]
   :up [(love.graphics.newQuad 60 0 16 16 (player-sprite-sheet:getDimensions))
        (love.graphics.newQuad 60 30 16 16 (player-sprite-sheet:getDimensions))]
   :right [(love.graphics.newQuad 90 30 16 16
                                  (player-sprite-sheet:getDimensions))
           (love.graphics.newQuad 90 0 16 16
                                  (player-sprite-sheet:getDimensions))]})

(fn -init-player-state [player-sprite-quads]
  {:x 16
   :y 16
   :moving false
   :direction :down
   :direction-delta 0
   :delta-per-frame 16
   :speed 2
   :sprite-quad (-> (. player-sprite-quads :down)
                    (. 1))})

(fn choose-sprite-quad [sprite-quads delta delta-per-frame]
  (let [cur-frame (+ 1 (math.floor (/ delta delta-per-frame)))]
    (if (. sprite-quads cur-frame)
        [(. sprite-quads cur-frame) delta]
        (choose-sprite-quad sprite-quads 0 delta-per-frame))))

(fn handle-collisions [[next-x next-y] player-state tiles]
  (let [direction (. player-state :direction)]
    (tset player-state :x next-x)
    (tset player-state :y next-y)))

(fn on-update [delta player-state player-sprite-quads keyboard tiles]
  (let [speed (* (. player-state :speed) delta)
        [sprite-quad next-delta] (choose-sprite-quad (->> (. player-state
                                                             :direction)
                                                          (. player-sprite-quads))
                                                     (. player-state
                                                        :direction-delta)
                                                     (. player-state
                                                        :delta-per-frame))]
    (tset player-state :direction-delta next-delta)
    (tset player-state :sprite-quad sprite-quad)
    (if (. player-state :moving)
        (do
          (tset player-state :direction-delta
                (+ (. player-state :direction-delta) speed))
          (-> (case (. player-state :direction)
                :up
                [(. player-state :x) (- (. player-state :y) speed)]
                :down
                [(. player-state :x) (+ (. player-state :y) speed)]
                :left
                [(- (. player-state :x) speed) (. player-state :y)]
                :right
                [(+ (. player-state :x) speed) (. player-state :y)])
              (handle-collisions player-state tiles)))
        nil))
  player-state)

(fn on-key-pressed [player-state key]
  (case key
    :up
    (do
      (tset player-state :moving true)
      (tset player-state :direction :up)
      (tset player-state :direction-delta 17))
    :down
    (do
      (tset player-state :moving true)
      (tset player-state :direction :down)
      (tset player-state :direction-delta 17))
    :left
    (do
      (tset player-state :moving true)
      (tset player-state :direction :left)
      (tset player-state :direction-delta 17))
    :right
    (do
      (tset player-state :moving true)
      (tset player-state :direction :right)
      (tset player-state :direction-delta 17)))
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
        (tset player-state :moving false)
        (tset player-state :direction-delta 0))))

{:player-sprite-sheet -player-sprite-sheet
 :player-sprite-quads -player-sprite-quads
 :init-player-state -init-player-state
 : choose-sprite-quad
 : on-update
 : on-key-pressed
 : on-key-released}
