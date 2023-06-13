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
  (tset entity :shove-delta-per-frame 4)
  (case direction
    :left
    (tset entity :shove-delta-x 32)
    :right
    (tset entity :shove-delta-x -32)
    :up
    (tset entity :shove-delta-y 32)
    :down
    (tset entity :shove-delta-y -32)))

(fn process-touch-damage-system [_system entity [draw delta]]
  (if draw nil (let [collides-with-player (util.check-collision (. entity :x)
                                                                (. entity :y) 32
                                                                32
                                                                (. player-state
                                                                   :x)
                                                                (. player-state
                                                                   :y)
                                                                32 32)]
                 (if (-> collides-with-player
                         (and (= 0 (. player-state :shove-delta-per-frame)))
                         (and (= 0 (. player-state :shove-delta-per-frame))))
                     (let [[player-shove-direction entity-shove-direction] (get-shove-direction player-state
                                                                                                entity)]
                       (shove-entity player-shove-direction player-state)
                       (shove-entity entity-shove-direction entity))
                     nil))))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage :facing :x :y))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (ecs.addSystem world touch-damage-system)
  (ecs.setSystemIndex world touch-damage-system 2))

{: init}
