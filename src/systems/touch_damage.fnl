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
    (if (= entity-facing (reverse player-facing))
        [(reverse entity-facing) (reverse player-facing)]
        (= entity-facing player-facing)
        [entity-facing (reverse player-facing)]
        (= player-moving false)
        [entity-facing (reverse entity-facing)]
        (= entity-moving false)
        [(reverse player-facing) player-facing]
        [(reverse player-facing) (reverse entity-facing)])))

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
                         (and (= 0 (. entity :shove-delta-y)))
                         (and (= 0 (. entity :shove-delta-x)))
                         (and (= 0 (. player-state :shove-delta-y)))
                         (and (= 0 (. player-state :shove-delta-x))))
                     (case (. entity :facing)
                       :down
                       (do
                         (tset player-state :shove-delta-per-frame 4)
                         (tset player-state :shove-delta-y 32)
                         (tset entity :shove-delta-per-frame 4)
                         (tset entity :shove-delta-y -32))
                       :up
                       (do
                         (tset player-state :shove-delta-per-frame 4)
                         (tset player-state :shove-delta-y -32)
                         (tset entity :shove-delta-per-frame 4)
                         (tset entity :shove-delta-y 32))
                       :left
                       (do
                         (tset player-state :shove-delta-per-frame 4)
                         (tset player-state :shove-delta-x 32)
                         (tset entity :shove-delta-per-frame 4)
                         (tset entity :shove-delta-x -32))
                       :right
                       (do
                         (tset player-state :shove-delta-per-frame 4)
                         (tset player-state :shove-delta-x -32)
                         (tset entity :shove-delta-per-frame 4)
                         (tset entity :shove-delta-x 32)))
                     nil))))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage :facing :x :y))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (ecs.addSystem world touch-damage-system)
  (ecs.setSystemIndex world touch-damage-system 2))

{: init}
