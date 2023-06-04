(local ecs (require :lib.ecs))

(var system nil)

(fn init []
  (set system (ecs.processingSystem))
  system)

(fn deinit []
  nil)

{: init : deinit}
