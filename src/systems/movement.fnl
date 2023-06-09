(local ecs (require :lib.ecs))

(var area-movement-system nil)

(local movement-system (ecs.processingSystem))

(fn get-direction [entity]
  (if (> (. entity :x) (. entity :to-x)) :right
      (< (. entity :x) (. entity :to-x)) :left
      (> (. entity :y) (. entity :to-y)) :down
      (< (. entity :y) (. entity :to-y)) :up))

(fn create-process-movement-system [area]
  (fn [_system entity [draw delta]]
    (if draw nil (do
                   nil))))

(fn init [world area]
  (let [movement-system (ecs.processingSystem)]
    (tset movement-system :filter
          (ecs.requireAll :x :y :to-x :to-y :width :height))
    (tset movement-system :process (create-movement-system-process area))
    (set area-movement-system movement-system)
    (ecs.addSystem world area-movement-system)
    (ecs.setSystemIndex area-movement-system 3)))

(fn deinit [world]
  (ecs.removeSystem world area-movement-system))
