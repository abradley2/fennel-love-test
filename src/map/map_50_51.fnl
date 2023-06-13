(local ecs (require :lib.ecs))
(local enemy (require :enemy))

(var systems nil)
(var entities nil)

(fn deinit [world]
  (each [_ entity (pairs entities)]
    (ecs.removeEntity world entity)))

(fn init [world layers]
  (let [enemy-spawn (. layers :Enemy_Spawn)]
    (set entities (icollect [_ tile (pairs enemy-spawn)]
                    (enemy.enemy-from-tile tile)))
    (each [_ entity (pairs entities)]
      (ecs.addEntity world entity))))

{: init : deinit}
