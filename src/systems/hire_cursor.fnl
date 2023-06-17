(local ecs (require :lib.ecs))
(local player (require :player))

(local cursor nil)

(fn init-cursor [player-state]
  {:x 0 :y 0 :cursor true})

(fn process-hire-cursor-system [_system entity [draw delta]]
  (when (not draw)
    (do
      nil)))

(fn hire-cursor-system-prewrap [world]
  (when (and (= nil cursor) (= (-> (. player :player-state) (. :mode)) :hiring))
    (ecs.addEntity world (init-cursor (. player :player-state)))))

(fn hire-cursor-system-postwrap [world]
  (when (and (not= nil cursor) (not= (-> (. player :player-state) (. :mode))
                                     :hiring))
    (ecs.removeEntity world cursor)))

(fn init [world]
  (let [system (ecs.processingSystem)]
    (tset system :process process-hire-cursor-system)
    (tset system :filter (ecs.requireAll :cursor))
    (tset system :preWrap (partial hire-cursor-system-prewrap world))
    (tset system :postWrap (partial hire-cursor-system-postwrap world))
    (ecs.addSystem world system)))

{: init}
