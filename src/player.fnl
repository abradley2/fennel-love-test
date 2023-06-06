(local util (require :util))

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

(fn -init-player-state [player-sprite-sheet player-sprite-quads]
  {:player-entity true
   :x 256
   :y 256
   :moving false
   :direction :down
   :direction-delta 0
   :delta-per-frame 16
   :speed 1.5
   :draw [player-sprite-sheet
          (-> (. player-sprite-quads :down)
              (. 1))]})

(fn choose-sprite-quad [sprite-quads delta delta-per-frame]
  (let [cur-frame (+ 1 (math.floor (/ delta delta-per-frame)))]
    (if (. sprite-quads cur-frame)
        [(. sprite-quads cur-frame) delta]
        (choose-sprite-quad sprite-quads 0 delta-per-frame))))

(fn handle-collisions [[next-x next-y] player-state area tile-idx?]
  (let [direction (. player-state :direction)
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

(fn on-update [delta player-state player-sprite-quads keyboard area]
  (let [speed (* (. player-state :speed) delta)
        [sprite-sheet _] (. player-state :draw)
        [sprite-quad next-delta] (choose-sprite-quad (->> (. player-state
                                                             :direction)
                                                          (. player-sprite-quads))
                                                     (. player-state
                                                        :direction-delta)
                                                     (. player-state
                                                        :delta-per-frame))]
    (tset player-state :direction-delta next-delta)
    (tset player-state :draw [sprite-sheet sprite-quad])
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
              (handle-collisions player-state area)))
        nil)))

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
