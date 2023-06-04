(local ecs (require :lib.ecs))

(var system nil)

(fn init [world]
  (set system [(ecs.processingSystem) (ecs.processingSystem)])
  system)

(fn deinit [world]
  nil)

{: init : deinit}
