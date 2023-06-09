(local ecs (require :lib.ecs))
(local enemy (require :enemy))

(local enemies [])

(fn init-enemies [entities]
  (each [_k entity (pairs entities)]
    (let [id (. entity :original-tile-id)
          x (. entity :x)
          y (. entity :y)]
      (if (= enemy.charger-tile-id id)
          (table.insert enemies (enemy.init-charger x y))
          nil))))

(local player-system (ecs.processingSystem))

(tset player-system :filter (ecs.requireAll :player-entity))
(tset player-system :process (fn [_ entity [draw delta]]
                               (if draw nil
                                   (do
                                     nil))))

(fn init [world area]
  (init-enemies (. area :entities))
  (each [_ enemy (pairs enemies)]
    (ecs.addEntity world enemy))
  (ecs.addSystem world player-system))

(fn deinit [world]
  (ecs.removeSystem world player-system)
  (each [_ enemy (pairs enemies)]
    (ecs.removeEntity world enemy)))

{: init : deinit}
