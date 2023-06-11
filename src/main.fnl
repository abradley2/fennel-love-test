(local json (require :lib.json))
(local ecs (require :lib.ecs))
(local util (require :util))
(local player (require :player))
(local action_animation (require :systems.action_animation))
(local touch_damage (require :systems.touch_damage))
(local shove (require :systems.shove))
(local movement (require :systems.movement))

(local player-state (. player :player-state))

(local map-logic {:area_50_50.json area_50_50})

; (love.window.setMode 512 512 {:resizable false})
(love.window.setMode 768 768 {:resizable false})
; (love.window.setMode 1024 1024 {:resizable false})

(love.graphics.setDefaultFilter :nearest)

(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))

; These are not configurable. Do not change.
(local area-grid 32)
(local area-size 1024)
(local tile-size 32)

(local target-square (/ GAME-WIDTH area-grid))
(global CAMERA-ZOOM (/ target-square tile-size))

(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(local area {:sprite-batch-groups nil :area-systems nil})

(local world-map-data (let [world-map-fh (io.open :./src/map/map.world)
                            world-map-json (world-map-fh:read :*all)]
                        (json.decode world-map-json)))

(local game-state {:leaving-area nil
                   :entering-area nil
                   :animate-transition nil
                   :current-map (-> world-map-data (. :maps) (. 1))
                   :world-offset-x 0
                   :world-offset-y 0})

(local draw-system (ecs.processingSystem))

(tset draw-system :process (fn [_ entity [draw _]]
                             (if draw
                                 (let [[sprite quad] (. entity :draw)]
                                   (love.graphics.draw sprite quad
                                                       (-> (. entity :x)
                                                           (* CAMERA-ZOOM))
                                                       (-> (. entity :y)
                                                           (* CAMERA-ZOOM))
                                                       0 1.5))
                                 nil)))

(tset draw-system :filter (ecs.requireAll :draw))

(local ecs-world (ecs.world draw-system))
(ecs.setSystemIndex ecs-world draw-system 1)

(action_animation.init ecs-world)
(touch_damage.init ecs-world)
(shove.init ecs-world)

(ecs.addEntity ecs-world player-state)

(fn set-area [area-name] ; clean up world
  (if (not (= nil (. area :area-systems)))
      (do
        (-?> (. area :area-systems) (. :deinit) (#($1 ecs-world)))
        (movement.deinit ecs-world))
      nil)
  (let [layers (world.read-tiled-map area-name)
        system (. map-logic area-name)] ; add to world ; TODO - Add collisions layers
    (movement.init ecs-world [])
    (tset area :sprite-batch-groups
          (icollect [_ layer (ipairs layers)]
            (world.create-sprite-batches layer)))
    (tset area :area-systems system)
    (-?> system (. :init) (#($1 ecs-world area))))
  area)

(set-area :map_50_50.json)

(fn load-next-area [map-idx?]
  (let [map-idx (or map-idx? 1)
        map (-> world-map-data (. :maps) (. map-idx))]
    (if (util.check-collision (. map :x) (. map :y) (. map :width)
                              (. map :height)
                              (+ (. player-state :x)
                                 (. game-state :world-offset-x))
                              (+ (. player-state :y)
                                 (. game-state :world-offset-y))
                              1 1)
        (do
          (tset game-state :leaving-area
                {:sprite-batch-groups (. area :sprite-batch-groups)})
          (tset game-state :entering-area (set-area (. map :fileName)))
          (tset game-state :world-offset-x (. map :x))
          (tset game-state :world-offset-y (. map :y))
          (tset game-state :current-map map))
        (load-next-area (+ map-idx 1)))))

(fn check-for-area-transition []
  (let [player-x (. player-state :x)
        player-y (. player-state :y)]
    (if (< (+ player-x 16) 0) (do
                                (tset game-state :animate-transition
                                      [:left area-size])
                                (load-next-area))
        (> player-x area-size) (do
                                (tset game-state :animate-transition
                                      [:right area-size])
                                (load-next-area))
        (< (+ player-y 16) 0) (do
                               (tset game-state :animate-transition
                                     [:up area-size])
                               (load-next-area))
        (> player-y area-size) (do
                                (tset game-state :animate-transition
                                      [:down area-size])
                                (load-next-area))
        nil)))

(var area-transition-tick 0)

(fn love.update [dt]
  (ecs-world.update ecs-world [false (/ dt 0.0166)])
  (if (= nil (. game-state :leaving-area))
      (let [delta (/ dt 0.0166)]
        (set area-transition-tick (+ area-transition-tick dt))
        (if (and (> area-transition-tick 0.25)
                 (= nil (. game-state :leaving-area)))
            (do
              (check-for-area-transition)
              (set area-transition-tick 0))
            nil)
        (player.on-update delta player-state -keyboard area))
      (let [delta (/ dt 0.0166)
            animate-speed (* 16 delta)
            [direction animation-offset] (. game-state :animate-transition)
            should-move-player true
            next-offset (math.max 0 (- animation-offset animate-speed))]
        (if (= 0 next-offset)
            (do
              (tset game-state :leaving-area nil)
              (tset game-state :entering-area nil)
              (tset game-state :animate-transition nil))
            (do
              (tset game-state :animate-transition [direction next-offset])
              (if (= :left direction)
                  (do
                    (tset player-state :x (+ (. player-state :x) animate-speed))
                    (tset player-state :to-x (. player-state :x)))
                  (= :right direction)
                  (do
                    (tset player-state :x (- (. player-state :x) animate-speed))
                    (tset player-state :tox (. player-state :x)))
                  (= :up direction)
                  (do
                    (tset player-state :y (+ (. player-state :y) animate-speed))
                    (tset player-state :to-y (. player-state :y)))
                  (= :down direction)
                  (do
                    (tset player-state :y (- (. player-state :y) animate-speed))
                    (tset player-state :to-y (. player-state :y)))))))))

(fn love.keypressed [key]
  (do
    (when (= :escape key) (love.event.quit))
    (tset -keyboard key true)
    (player.on-key-pressed player-state key)))

(fn love.keyreleased [key]
  (tset -keyboard key false)
  (player.on-key-released player-state -keyboard key))

(fn love.draw []
  (if (= nil (. game-state :leaving-area))
      (each [_k sprite-batch-group (ipairs (. area :sprite-batch-groups))]
        (each [_ sprite-batch (pairs sprite-batch-group)]
          (love.graphics.draw sprite-batch)))
      (let [[direction offset] (. game-state :animate-transition)
            entering-x-offset (if (= :left direction)
                                  (* (* offset CAMERA-ZOOM) -1)
                                  (= :right direction)
                                  (* offset CAMERA-ZOOM)
                                  0)
            entering-y-offset (if (= :up direction)
                                  (* (* offset CAMERA-ZOOM) -1)
                                  (= :down direction)
                                  (* offset CAMERA-ZOOM)
                                  0)
            leaving-x-offset (if (= :left direction)
                                 (- (* area-size CAMERA-ZOOM)
                                    (* offset CAMERA-ZOOM))
                                 (= :right direction)
                                 (- (* offset CAMERA-ZOOM)
                                    (* area-size CAMERA-ZOOM))
                                 0)
            leaving-y-offset (if (= :up direction)
                                 (- (* area-size CAMERA-ZOOM)
                                    (* offset CAMERA-ZOOM))
                                 (= :down direction)
                                 (- (* offset CAMERA-ZOOM)
                                    (* area-size CAMERA-ZOOM))
                                 0)]
        (each [_k sprite-batch-group (ipairs (-> game-state (. :leaving-area)
                                                 (. :sprite-batch-groups)))]
          (each [_ sprite-batch (pairs sprite-batch-group)]
            (love.graphics.draw sprite-batch (or leaving-x-offset 0)
                                (or leaving-y-offset 0))))
        (each [_k sprite-batch-group (ipairs (-> game-state (. :entering-area)
                                                 (. :sprite-batch-groups)))]
          (each [_ sprite-batch (pairs sprite-batch-group)]
            (love.graphics.draw sprite-batch (or entering-x-offset 0)
                                (or entering-y-offset 0))))))
  (ecs-world.update ecs-world [true nil]))
