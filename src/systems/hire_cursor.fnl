(local ecs (require :lib.ecs))
(local player (require :player))
(local ally (require :ally))

(local hire-image (love.graphics.newImage :assets/Archer_Blue.png))
(local cursor-image (love.graphics.newImage :assets/Pointer_Square.png))

(local spawned-entities [])

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

(fn on-key-pressed [world key keyboard]
  (case key
    :space
    (when (not= nil cursor)
      (let [spawn-x (+ 32 (. cursor :x))
            spawn-y (+ 32 (. cursor :y))
            archer (ally.init-archer-blue spawn-x spawn-y)]
        (ecs.addEntity world archer)
        (table.insert spawned-entities archer)
        (-> (. player :player-state) (tset :mode :default))
        (ecs.removeEntity world cursor)
        (set cursor nil)
        (each [_i grid-square (ipairs cursor-grids)]
          (ecs.removeEntity world grid-square))
        (each [_ _ (ipairs cursor-grids)]
          (table.remove cursor-grids 1)))))
  (check-keyboard keyboard))

(fn on-key-released [world key keyboard] nil)

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

(var system nil)

(fn init [world]
  (let [-system (ecs.processingSystem)]
    (tset -system :process process-hire-cursor-system)
    (tset -system :filter (ecs.requireAll :cursor))
    (tset -system :preWrap (partial hire-cursor-system-prewrap world))
    (tset -system :postWrap (partial hire-cursor-system-postwrap world))
    (ecs.addSystem world -system)
    (set system -system)))

(fn deinit [world]
  (ecs.removeSystem world system)
  (set cursor nil)
  (each [_i grid-square (ipairs cursor-grids)]
    (ecs.removeEntity world grid-square))
  (each [_ _ (ipairs cursor-grids)]
    (table.remove cursor-grids 1))
  (each [_i entity (ipairs spawned-entities)]
    (ecs.removeEntity world entity))
  (each [_ _ (ipairs spawned-entities)]
    (table.remove spawned-entities 1)))

{: init : deinit : on-key-pressed : on-key-released}
