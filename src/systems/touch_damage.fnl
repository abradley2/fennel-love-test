(local ecs (require :lib.ecs))

(local player-system (ecs.processingSystem))

(var player nil)

(fn process-player-system [_system entity [draw delta]]
  (if draw nil (do
                 nil)))

(tset player-system :filter (ecs.requireAll :player-entity))
(tset player-system :process process-player-system)
(tset player-system :onAdd (fn [entity] (set player entity)))
(tset player-system :onRemove (fn [entity] (set player nil)))

(local touch-damage-system (ecs.processingSystem))

(fn process-touch-damage-system [_system entity [draw delta]]
  (if draw nil (do
                 nil)))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (print :WORLD world)
  (ecs.addSystem world player-system))

{: init}
