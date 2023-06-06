(local ecs (require :lib.ecs))

(local player-system (ecs.processingSystem))

(tset player-system :filter (ecs.requireAll :player-entity))
(tset player-system :process
      (fn [_ entity [draw delta]]
        (if draw nil (print (. entity :y) delta))))

(fn init [world area]
  (ecs.addSystem world player-system)
  nil)

(fn deinit [world area]
  (ecs.removeSystem world player-system)
  nil)

{: init : deinit}
