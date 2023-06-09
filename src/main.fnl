(local json (require :lib.json))
(local ecs (require :lib.ecs))
(local util (require :util))
(local player (require :player))
(local action_animation (require :systems.action_animation))
(local touch_damage (require :systems.touch_damage))
(local area_50_50 (require :map.area_50_50))

(local player-state (. player :player-state))

(local map-logic {:area_50_50.json area_50_50})

; (love.window.setMode 512 512 {:resizable false})
(love.window.setMode 768 768 {:resizable false})
; (love.window.setMode 1024 1024 {:resizable false})

(love.graphics.setDefaultFilter :nearest)

(global (GAME-WIDTH GAME-HEIGHT) (love.window.getMode))

; These are not configurable. Do not change.
(local area-grid 32)
(local area-size 512)
(local tile-size 16)

(local target-square (/ GAME-WIDTH area-grid))
(global CAMERA-ZOOM (/ target-square tile-size))

(local world (require :world))

(local -keyboard {:up false :down false :left false :right false})

(local area {:world nil
             :logic nil
             :entities nil
             :sprite-batches nil
             :entity-sprites nil
             :area-systems nil})

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
                                                       0 CAMERA-ZOOM))
                                 nil)))

(tset draw-system :filter (ecs.requireAll :draw))

(local ecs-world (ecs.world draw-system))
(ecs.setSystemIndex ecs-world draw-system 1)

(action_animation.init ecs-world)
(touch_damage.init ecs-world)

(ecs.addEntity ecs-world player-state)

(fn set-area [area-name] ; clean up world
  (if (not (= nil (. area :world)))
      (do
        (-?> (. area :area-systems) (. :deinit) (#($1 ecs-world)))
        (each [_ logic-tile (pairs (. area :logic))]
          (tset logic-tile :type :logic-tile)
          (ecs.removeEntity ecs-world logic-tile))
        (each [_ world-tile (pairs (. area :world))]
          (tset world-tile :type :world-tile)
          (ecs.addEntity ecs-world world-tile)))
      nil)
  (let [tiled-map (world.read-tiled-map area-name)
        system (. map-logic area-name)] ; add to world
    (each [_ logic-tile (pairs (. tiled-map :logic))]
      (ecs.addEntity ecs-world logic-tile))
    (each [_ world-tile (pairs (. tiled-map :world))]
      (ecs.addEntity ecs-world world-tile))
    (tset area :world (. tiled-map :world))
    (tset area :logic (. tiled-map :logic))
    (tset area :entities (. tiled-map :entities))
    (tset area :sprite-batches
          (-> (. tiled-map :world) world.create-sprite-batches))
    (tset area :area-systems system)
    (-?> system (. :init) (#($1 ecs-world area))))
  area)

(set-area :area_50_50.json)

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
                {:sprite-batches (. area :sprite-batches)})
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
            animate-speed (* 8 delta)
            player-transition-mod (/ (+ area-size tile-size) area-size)
            player-animate-speed (* animate-speed player-transition-mod)
            [direction animation-offset player-animation-offset] (. game-state
                                                                    :animate-transition)
            next-offset (math.max 0 (- animation-offset animate-speed))]
        (if (= 0 next-offset)
            (do
              (tset game-state :leaving-area nil)
              (tset game-state :entering-area nil)
              (tset game-state :animate-transition nil))
            (do
              (tset game-state :animate-transition [direction next-offset])
              (if (= :left direction)
                  (tset player-state :x
                        (+ (. player-state :x) player-animate-speed))
                  (= :right direction)
                  (tset player-state :x
                        (- (. player-state :x) player-animate-speed))
                  (= :up direction)
                  (tset player-state :y
                        (+ (. player-state :y) player-animate-speed))
                  (= :down direction)
                  (tset player-state :y
                        (- (. player-state :y) player-animate-speed))))))))

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
      (each [_k sprite-batch (pairs (. area :sprite-batches))]
        (love.graphics.draw sprite-batch))
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
        (each [_k sprite-batch (pairs (-> game-state (. :leaving-area)
                                          (. :sprite-batches)))]
          (love.graphics.draw sprite-batch (or leaving-x-offset 0)
                              (or leaving-y-offset 0)))
        (each [_k sprite-batch (pairs (-> game-state (. :entering-area)
                                          (. :sprite-batches)))]
          (love.graphics.draw sprite-batch entering-x-offset entering-y-offset))))
  (ecs-world.update ecs-world [true nil]))
