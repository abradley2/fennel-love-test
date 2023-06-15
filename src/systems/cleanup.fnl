(local ecs (require :lib.ecs))

(local system (ecs.processingSystem))

(tset system :filter (ecs.requireAll :flagged-for-removal))

(fn init [world]
  (tset system :process
        (fn [_system entity [draw delta]]
          (if draw nil
              (when (. entity :flagged-for-removal)
                (ecs.removeEntity world entity)))))
  (ecs.addSystem world system))

{: init}
