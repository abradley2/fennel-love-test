(local ecs (require :lib.ecs))
(local util (require :util))

(var area-movement-system nil)

(local movement-system (ecs.processingSystem))

(fn with-collision-offset [collision-box entity]
  {:to-x (-> (. entity :to-x) (+ (. collision-box :x-offset)))
   :x (-> (. entity :to-x) (+ (. collision-box :x-offset)))
   :y (-> (. entity :to-y) (+ (. collision-box :y-offset)))
   :to-y (-> (. entity :to-y) (+ (. collision-box :y-offset)))
   :x-offset (. collision-box :x-offset)
   :y-offset (. collision-box :y-offset)
   :width (. collision-box :width)
   :height (. collision-box :height)})

(fn get-collision-box [entity]
  (or (-?> (. entity :collision-box) (with-collision-offset entity)) entity))

(fn area-to-collisions [area-tiles]
  (accumulate [collision-tiles [] _ area-tile (pairs area-tiles)]
    (let [should-check-collision true]
      (if should-check-collision
          (table.insert collision-tiles area-tile)
          nil)
      collision-tiles)))

(fn check-collision [entity tile]
  (util.check-collision (. entity :to-x) (. entity :to-y) (. entity :width)
                        (. entity :height) (. tile :x) (. tile :y)
                        (. tile :width) (. tile :height)))

(fn get-direction [entity]
  (if (> (. entity :x) (. entity :to-x)) :left
      (< (. entity :x) (. entity :to-x)) :right
      (> (. entity :y) (. entity :to-y)) :up
      (< (. entity :y) (. entity :to-y)) :down))

(fn adjust-entity [entity border-tile]
  (let [direction (get-direction entity)
        collision-box (get-collision-box entity)]
    (case direction
      :right
      (let []
        (tset entity :x
              (-> (. border-tile :x) (- (. collision-box :width))
                  (- (. collision-box :x-offset)) (- 1)))
        (tset entity :to-x (. entity :x)))
      :left
      (let []
        (tset entity :x
              (-> (. border-tile :x) (+ (. collision-box :width))
                  (- (. collision-box :x-offset)) (+ 1)))
        (tset entity :to-x (. entity :x)))
      :up
      (let []
        (tset entity :y
              (-> (. border-tile :y) (+ (. collision-box :height))
                  (- (. collision-box :y-offset)) (+ 1)))
        (tset entity :to-y (. entity :y)))
      :down
      (let []
        (tset entity :y
              (-> (. border-tile :y) (- (. collision-box :height))
                  (- (. collision-box :y-offset)) (- 1)))
        (tset entity :to-y (. entity :y))))
    nil))

(fn check-movement [entity area tile-idx?]
  (let [tile-idx (or tile-idx? 1)
        tile (. area tile-idx)]
    (if (not= nil tile)
        (let [collision-box (get-collision-box entity)
              does-collide (check-collision collision-box tile)]
          (if does-collide
              (adjust-entity entity tile)
              (check-movement entity area (+ tile-idx 1))))
        (do
          (tset entity :x (. entity :to-x))
          (tset entity :y (. entity :to-y))))))

(fn create-process-movement-system [area]
  (fn [_system entity [draw delta]]
    (if draw nil (if (-> true
                         (and (= (. entity :x) (. entity :to-x)))
                         (and (= (. entity :y) (. entity :to-y))))
                     nil
                     (check-movement entity area)))))

(fn init [world area]
  (let [movement-system (ecs.processingSystem)]
    (tset movement-system :filter
          (ecs.requireAll :x :y :to-x :to-y :width :height))
    (tset movement-system :process
          (-> (area-to-collisions area)
              create-process-movement-system))
    (set area-movement-system movement-system)
    (ecs.addSystem world area-movement-system)
    (ecs.setSystemIndex world area-movement-system 4)))

(fn deinit [world]
  (ecs.removeSystem world area-movement-system))

{: init : deinit : get-collision-box}
