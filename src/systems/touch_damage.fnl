(local ecs (require :lib.ecs))
(local player (require :player))
(local util (require :util))

(local player-state (. player :player-state))

(local touch-damage-system (ecs.processingSystem))

(fn reverse [direction]
  (case direction
    :up
    :down
    :down
    :up
    :left
    :right
    :right
    :left))

(fn get-shove-direction [entity player]
  (let [entity-facing (. entity :facing)
        entity-moving (. entity :moving)
        player-facing (. player :facing)
        player-moving (. player :moving)]
    (if (= player-moving false)
        [entity-facing (reverse entity-facing)]
        (= entity-moving false)
        [(reverse player-facing) player-facing]
        (= entity-facing (reverse player-facing))
        [(reverse entity-facing) (reverse player-facing)]
        (= entity-facing player-facing)
        [entity-facing (reverse player-facing)]
        [(reverse player-facing) (reverse entity-facing)])))

(fn shove-entity [direction entity]
  (when (not= false (. entity :shovable))
    (do
      (tset entity :shove-delta-per-frame 4)
      (case direction
        :left
        (tset entity :shove-delta-x 32)
        :right
        (tset entity :shove-delta-x -32)
        :up
        (tset entity :shove-delta-y 32)
        :down
        (tset entity :shove-delta-y -32)))))

(fn -process-touch-damage-system [entity-bar entity-foo]
  (let [does-collide (util.check-collision (. entity-foo :x) (. entity-foo :y)
                                           32 32 (. entity-bar :x)
                                           (. entity-bar :y) 32 32)]
    (if (-> does-collide
            (and (= 0 (. entity-bar :shove-delta-per-frame)))
            (and (= 0 (. entity-bar :shove-delta-per-frame))))
        (let [[entity-bar-shove-direction entity-foo-shove-direction] (get-shove-direction entity-bar
                                                                                           entity-foo)]
          (shove-entity entity-bar-shove-direction entity-bar)
          (shove-entity entity-foo-shove-direction entity-foo))
        nil)))

(fn process-touch-damage-system [_system entity [draw delta]]
  (if draw nil
      (do
        (-process-touch-damage-system player-state entity))))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage :facing :x :y))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (ecs.addSystem world touch-damage-system)
  (ecs.setSystemIndex world touch-damage-system 2))

{: init}
