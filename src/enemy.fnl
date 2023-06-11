(local torch-red-sprite-sheet (love.graphics.newImage :assets/Torch_Red.png))

(local torch-red-tile-id 1)

(fn offset-pairs-to-quads [sprite-sheet-dimensions offset-pairs]
  (icollect [_ [x y] (ipairs offset-pairs)]
    (love.graphics.newQuad x y 192 192 sprite-sheet-dimensions)))

(local torch-red-quad-sets
       {:idle (offset-pairs-to-quads (torch-red-sprite-sheet:getDimensions)
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
               :width 16
               :height 16
               :touch-damage 1
               :shove-delta-x 0
               :shove-delta-y 0
               :shove-delta-per-frame 0
               :facing :up
               :action {:name :idle :frames-per-quad 20 :animating true}
               :quad-sets torch-red-quad-sets
               :draw nil}]
    (tset attrs :draw [enemy-sprite-sheet
                       (-> attrs
                           (. :quad-sets)
                           (. (-> attrs (. :action) (. :name)))
                           (. 1))])
    attrs))

{: init-charger : charger-tile-id}
