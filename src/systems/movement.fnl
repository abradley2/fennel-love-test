(local ecs (require :lib.ecs))
(local util (require :util))

(var area-movement-system nil)

(local movement-system (ecs.processingSystem))

(fn area-to-collisions [area-tiles]
  (accumulate [collision-tiles [] _ area-tile (pairs area-tiles)]
    (do
      (if (-> false
              (or (not= (. area-tile :original-tile-id) 1))
              (or (not= (. area-tile :orginal-tile-id) 10)))
          nil
          (table.insert collision-tiles area-tile))
      collision-tiles)))

(fn check-collision [entity tile]
  (util.check-collision (. entity :to-x) (. entity :to-y) (. entity :width)
                        (. entity :heith) (. tile :x) (. tile :y)
                        (. tile :width) (. tile :height)))

(fn get-direction [entity]
  (if (> (. entity :x) (. entity :to-x)) :right
      (< (. entity :x) (. entity :to-x)) :left
      (> (. entity :y) (. entity :to-y)) :down
      (< (. entity :y) (. entity :to-y)) :up))

(fn adjust-entity [entity border-tile]
  nil)

(fn check-movement [entity area tile-idx?]
  (print "CHECK MOVEMENT FOR ENTITY" entity)
  (let [tile-idx (or tile-idx? 1)
        tile (. area tile-idx)]
    (if (not= nil tile)
        (let [does-collide (check-collision entity tile)]
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

{: init : deinit}
