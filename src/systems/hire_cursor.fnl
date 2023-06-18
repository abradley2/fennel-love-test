(local ecs (require :lib.ecs))
(local player (require :player))

(local hire-image (love.graphics.newImage :assets/Archer_Blue.png))
(local cursor-image (love.graphics.newImage :assets/Pointer_Square.png))

(var cursor nil)
(local cursor-grids [])

(local draw-hire
       [hire-image
        (love.graphics.newQuad 0 0 192 192 (hire-image:getDimensions))])

(local draw-cursor [cursor-image (love.graphics.newQuad 0 0 64 64 64 64)])

(fn create-grid [player-state]
  (let [player-x (+ (. player-state :x) (. player-state :x-draw-offset))
        player-y (+ (. player-state :y) (. player-state :y-draw-offset))
        player-width (. player-state :width)
        player-height (. player-state :height)]
    {:up {:x (-> player-x (+ 32))
          :y (-> player-y (+ -32))
          :height 64
          :width 64
          :draw draw-cursor}
     :up-left {:x (-> player-x (+ -32))
               :y (-> player-y (+ -32))
               :height 64
               :width 64
               :draw draw-cursor}
     :up-right {:x (-> player-x (+ 96))
                :y (-> player-y (+ -32))
                :height 64
                :width 64
                :draw draw-cursor}
     :left {:x (-> player-x (+ -32))
            :y (-> player-y (+ 32))
            :height 64
            :width 64
            :draw draw-cursor}
     :right {:x (-> player-x (+ 96))
             :y (-> player-y (+ 32))
             :height 64
             :width 64
             :draw draw-cursor}
     :down {:x (-> player-x (+ 32))
            :y (-> player-y (+ 96))
            :height 64
            :width 64
            :draw draw-cursor}
     :down-left {:x (-> player-x (+ -32))
                 :y (-> player-y (+ 96))
                 :height 64
                 :width 64
                 :draw draw-cursor}
     :down-right {:x (-> player-x (+ 96))
                  :y (-> player-y (+ 96))
                  :height 64
                  :width 64
                  :draw draw-cursor}}))

(fn move-cursor [direction]
  (let [grid (. cursor :grid)
        current-tile (. grid direction)]
    (tset cursor :x (. current-tile :x))
    (tset cursor :y (. current-tile :y))))

(fn check-keyboard [keyboard]
  (when (not= nil cursor)
    (let [up-pressed (. keyboard :up)
          down-pressed (. keyboard :down)
          left-pressed (. keyboard :left)
          right-pressed (. keyboard :right)
          grid (. cursor :grid)]
      (if (and up-pressed left-pressed) (move-cursor :up-left)
          (and up-pressed right-pressed) (move-cursor :up-right)
          (and down-pressed left-pressed) (move-cursor :down-left)
          (and down-pressed right-pressed) (move-cursor :down-right)
          up-pressed (move-cursor :up)
          down-pressed (move-cursor :down)
          left-pressed (move-cursor :left)
          right-pressed (move-cursor :right)))))

(fn on-key-pressed [keyboard] (check-keyboard keyboard))
(fn on-key-released [keyboard] (check-keyboard keyboard))

(fn init-cursor [player-state]
  (let [grid (create-grid player-state)
        current-tile (. grid (. player-state :facing))]
    {:x (. current-tile :x)
     :y (. current-tile :y)
     :zoom-mod (/ 64 92)
     :x-draw-offset -32
     :y-draw-offset -32
     :height 64
     :width 64
     :cursor true
     :draw draw-hire
     : grid}))

(fn process-hire-cursor-system [_system entity [draw delta]]
  (when (not draw)
    (do
      nil)))

(fn hire-cursor-system-prewrap [world]
  (when (and (= nil cursor) (= (-> (. player :player-state) (. :mode)) :hiring))
    (do
      (each [_ grid-square (pairs (create-grid (. player :player-state)))]
        (do
          (table.insert cursor-grids grid-square)
          (ecs.addEntity world grid-square)))
      (set cursor (init-cursor (. player :player-state)))
      (ecs.addEntity world cursor))))

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

{: init : on-key-pressed : on-key-released}
