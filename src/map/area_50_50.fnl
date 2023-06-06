(local ecs (require :lib.ecs))

(local enemy-sprite-sheet
       (love.graphics.newImage :assets/sprites/enemy_sprite_sheet.png))

(fn init-charger [x y]
  (let [attrs {: x
               : y
               :action {:name :move-down :frames-per-quad 20 :animating true}
               :quad-sets {:move-down [(love.graphics.newQuad 120 120 16 16
                                                              enemy-sprite-sheet)
                                       (love.graphics.newQuad 120 150 16 16
                                                              enemy-sprite-sheet)]
                           :move-left []
                           :move-right []
                           :move-up []}
               :draw nil}]
    (tset attrs :draw [enemy-sprite-sheet
                       (-> attrs
                           (. :quad-sets)
                           (. (-> attrs (. :action) (. :name)))
                           (. 1))])
    attrs))

(local enemies [])

(fn init-enemies [entities]
  (each [_k entity (pairs entities)]
    (let [id (. entity :original-tile-id)
          x (. entity :x)
          y (. entity :y)]
      (if (= id 2) (table.insert enemies (init-charger x y)) nil))))

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
