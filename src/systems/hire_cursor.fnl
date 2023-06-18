(local ecs (require :lib.ecs))
(local player (require :player))

(local cursor-image (love.graphics.newImage :assets/Pointer_Square.png))

(var cursor nil)
(local cursor-grids [])

(local draw [cursor-image (love.graphics.newQuad 0 0 64 64 64 64)])

(fn create-grid [player-state]
  (let [player-x (+ (. player-state :x) (. player-state :x-draw-offset))
        player-y (+ (. player-state :y) (. player-state :y-draw-offset))
        player-width (. player-state :width)
        player-height (. player-state :height)]
    {:up {:x (-> player-x (+ 32))
          :y (-> player-y (+ -32))
          :height 64
          :width 64
          : draw}
     :up-left {:x (-> player-x (+ -32))
               :y (-> player-y (+ -32))
               :height 64
               :width 64
               : draw}
     :up-right {:x (-> player-x (+ 96))
                :y (-> player-y (+ -32))
                :height 64
                :width 64
                : draw}
     :left {:x (-> player-x (+ -32))
            :y (-> player-y (+ 32))
            :height 64
            :width 64
            : draw}
     :right {:x (-> player-x (+ 96))
             :y (-> player-y (+ 32))
             :height 64
             :width 64
             : draw}
     :down {:x (-> player-x (+ 32))
            :y (-> player-y (+ 96))
            :height 64
            :width 64
            : draw}
     :down-left {:x (-> player-x (+ -32))
                 :y (-> player-y (+ 96))
                 :height 64
                 :width 64
                 : draw}
     :down-right {:x (-> player-x (+ 96))
                  :y (-> player-y (+ 96))
                  :height 64
                  :width 64
                  : draw}}))

(fn init-cursor [player-state]
  {:x 0 :y 0 :cursor true})

(fn process-hire-cursor-system [_system entity [draw delta]]
  (when (not draw)
    (do
      nil)))

(fn hire-cursor-system-prewrap [world]
  (when (and (= nil cursor) (= (-> (. player :player-state) (. :mode)) :hiring))
    (do
      (set cursor (init-cursor (. player :player-state)))
      (ecs.addEntity world (init-cursor (. player :player-state)))
      (each [_ grid-square (pairs (create-grid (. player :player-state)))]
        (do
          (table.insert cursor-grids grid-square)
          (ecs.addEntity world grid-square))))))

(fn hire-cursor-system-postwrap [world]
  (when (and (not= nil cursor) (not= (-> (. player :player-state) (. :mode))
                                     :hiring))
    (do
      (ecs.removeEntity world cursor)
      (set cursor nil)
      (each [_i grid-square (ipairs cursor-grids)]
        (do
          (ecs.removeEntity world grid-square)))
      (each [_ _ (ipairs cursor-grids)]
        (table.remove cursor-grids 1)))))

(fn init [world]
  (let [system (ecs.processingSystem)]
    (tset system :process process-hire-cursor-system)
    (tset system :filter (ecs.requireAll :cursor))
    (tset system :preWrap (partial hire-cursor-system-prewrap world))
    (tset system :postWrap (partial hire-cursor-system-postwrap world))
    (ecs.addSystem world system)))

{: init}
