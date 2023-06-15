(local torch-red-sprite-sheet (love.graphics.newImage :assets/Torch_Red.png))

(fn offset-pairs-to-quads [sprite-sheet offset-pairs]
  (icollect [_ [x y] (ipairs offset-pairs)]
    (love.graphics.newQuad x y 192 192 (: sprite-sheet :getDimensions))))

(local torch-red-quad-sets
       {:idle (offset-pairs-to-quads torch-red-sprite-sheet
                                     [[0 0]
                                      [192 0]
                                      [384 0]
                                      [576 0]
                                      [768 0]
                                      [960 0]
                                      [1152 0]])})

(fn init-torch-red [x y]
  (let [attrs {: x
               : y
               :to-x x
               :to-y y
               :width 64
               :height 64
               :health 2
               :flagged-for-removal false
               :collision-box {:x-offset -32
                               :y-offset -32
                               :width 64
                               :height 64}
               :zoom-mod (/ 64 92)
               :x-draw-offset -64
               :y-draw-offset -64
               :touch-damage 1
               :shove-delta-x 0
               :shove-delta-y 0
               :shove-delta-per-frame 0
               :facing :up
               :moving false
               :action {:name :idle :frames-per-quad 6 :animating true}
               :quad-sets torch-red-quad-sets
               :draw nil}]
    (tset attrs :draw [torch-red-sprite-sheet
                       (-> attrs
                           (. :quad-sets)
                           (. (-> attrs (. :action) (. :name)))
                           (. 1))])
    attrs))

(fn enemy-from-tile [tile]
  (if (= (. tile :original-tile-id) 1)
      (init-torch-red (. tile :x) (. tile :y))))

{: enemy-from-tile}
