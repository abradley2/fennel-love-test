(local ecs (require :lib.ecs))
(local player (require :player))

(local player-state (. player :player-state))

(local touch-damage-system (ecs.processingSystem))

(fn process-touch-damage-system [_system entity [draw delta]]
  (if draw nil
      (do
        (print :player player-state (. player-state :x) (. player-state :y)))))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (ecs.addSystem world touch-damage-system)
  (ecs.setSystemIndex world touch-damage-system 2))

{: init}
