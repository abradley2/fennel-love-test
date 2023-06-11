(local ecs (require :lib.ecs))
(local enemy (require :enemy))

(var systems nil)
(var entities nil)

(fn deinit [world]
  (each [_ entity (pairs entities)]
    (ecs.removeEntity world entity)))

(fn init [world]
  (set entities [])
  ;; (set entities [((. enemy :init-torch-red) 564 564)])
  (each [_ entity (pairs entities)]
    (ecs.addEntity world entity)))

{: init : deinit}
