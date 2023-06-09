(local enemy-sprite-sheet
       (love.graphics.newImage :assets/sprites/enemy_sprite_sheet.png))

(local charger-tile-id 2)

(fn init-charger [x y]
  (let [attrs {: x
               : y
               :touch-damage 1
               :shove-delta-x 0
               :shove-delta-y 0
               :shove-delta-per-frame 0
               :facing :up
               :action {:name :move-down :frames-per-quad 20 :animating true}
               :quad-sets {:move-down [(love.graphics.newQuad 120 120 16 16
                                                              enemy-sprite-sheet)
                                       (love.graphics.newQuad 120 150 16 16
                                                              enemy-sprite-sheet)]
                           :move-left [(love.graphics.newQuad 120 120 16 16
                                                              enemy-sprite-sheet)
                                       (love.graphics.newQuad 120 150 16 16
                                                              enemy-sprite-sheet)]
                           :move-right [(love.graphics.newQuad 120 120 16 16
                                                               enemy-sprite-sheet)
                                        (love.graphics.newQuad 120 150 16 16
                                                               enemy-sprite-sheet)]
                           :move-up [(love.graphics.newQuad 120 120 16 16
                                                            enemy-sprite-sheet)
                                     (love.graphics.newQuad 120 150 16 16
                                                            enemy-sprite-sheet)]}
               :draw nil}]
    (tset attrs :draw [enemy-sprite-sheet
                       (-> attrs
                           (. :quad-sets)
                           (. (-> attrs (. :action) (. :name)))
                           (. 1))])
    attrs))

{: init-charger : charger-tile-id}
