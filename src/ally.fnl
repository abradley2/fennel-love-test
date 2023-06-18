(local archer-blue-sprite-sheet
       (love.graphics.newImage :assets/Archer_Blue.png))

(fn offset-pairs-to-quads [sprite-sheet offset-pairs]
  (icollect [_ [x y] (ipairs offset-pairs)]
    (love.graphics.newQuad x y 192 192 (: sprite-sheet :getDimensions))))

(local archer-blue-quad-sets
       {:idle (offset-pairs-to-quads archer-blue-sprite-sheet
                                     [[0 0]
                                      [192 0]
                                      [384 0]
                                      [576 0]
                                      [768 0]
                                      [960 0]])})

(fn init-archer-blue [x y]
  (let [attrs {: x
               :to-x x
               : y
               :to-y y
               :width 64
               :height 64
               :zoom-mod (/ 64 92)
               :collision-box {:x-offset -32
                               :y-offset -32
                               :width 64
                               :height 64}
               :x-draw-offset -64
               :y-draw-offset -64
               :touch-damage 0
               :shove-delta-x 0
               :shove-delta-y 0
               :shove-delta-per-frame 0
               :facing :down
               :moving false
               :action {:name :idle :frames-per-quad 6 :animating true}
               :quad-sets archer-blue-quad-sets}]
    (tset attrs :draw [archer-blue-sprite-sheet
                       (-> attrs
                           (. :quad-sets)
                           (. (-> attrs (. :action) (. :name)))
                           (. 1))])
    attrs))

{: init-archer-blue}
