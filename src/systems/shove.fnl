(local ecs (require :lib.ecs))

(local shove-system (ecs.processingSystem))

(tset shove-system :filter (ecs.requireAny :shove-delta-y :shove-delta-x))

(fn halt-entity [entity]
  (if (not= (. entity :speed) 0)
      (do
        (tset entity :original-speed (. entity :speed))
        (tset entity :speed 0))
      nil))

(fn un-halt-entity [entity]
  (if (and (not= nil (. entity :original-speed))
           (not= 0 (. entity :original-speed)))
      (tset entity :speed (. entity :original-speed))
      nil))

(fn process-shove-system [_system entity [draw delta]]
  (if draw nil (let [shove-distance (math.min (* (. entity
                                                    :shove-delta-per-frame)
                                                 delta)
                                              (math.abs (or (-> (. entity
                                                                   :shove-delta-x)
                                                                (#(if (not= 0
                                                                            $1)
                                                                      $1
                                                                      nil)))
                                                            (-> (. entity
                                                                   :shove-delta-y)
                                                                (#(if (not= 0
                                                                            $1)
                                                                      $1
                                                                      0))))))]
                 (if (not= 0 (. entity :shove-delta-x))
                     (if (> (. entity :shove-delta-x) 0)
                         (do
                           (halt-entity entity)
                           (tset entity :x (+ (. entity :x) shove-distance))
                           (tset entity :shove-delta-x
                                 (- (. entity :shove-delta-x) shove-distance)))
                         (< (. entity :shove-delta-x) 0)
                         (do
                           (halt-entity entity)
                           (tset entity :x (- (. entity :x) shove-distance))
                           (tset entity :shove-delta-x
                                 (+ (. entity :shove-delta-x) shove-distance)))
                         nil)
                     (not= 0 (. entity :shove-delta-y))
                     (if (> (. entity :shove-delta-y) 0)
                         (do
                           (halt-entity entity)
                           (tset entity :y (+ (. entity :y) shove-distance))
                           (tset entity :shove-delta-y
                                 (- (. entity :shove-delta-y) shove-distance)))
                         (< (. entity :shove-delta-y) 0)
                         (do
                           (halt-entity entity)
                           (tset entity :y (- (. entity :y) shove-distance))
                           (tset entity :shove-delta-y
                                 (+ (. entity :shove-delta-y) shove-distance)))
                         nil)
                     (un-halt-entity entity)))))

(tset shove-system :process process-shove-system)

(fn init [world]
  (ecs.addSystem world shove-system)
  (ecs.setSystemIndex world shove-system 2))

{: init}
