(local ecs (require :lib.ecs))
(local util (require :util))

(local death-sprite-sheet (love.graphics.newImage :assets/Dead.png))

(local offset-pairs-to-quads
       (util.offset-pairs-to-quads 128 128 death-sprite-sheet))

(local graves [])

(local entity-death-system (ecs.processingSystem))

(tset entity-death-system :filter (ecs.requireAll :health))

(local quad-sets {:death (offset-pairs-to-quads [[0 0]
                                                 [128 0]
                                                 [256 0]
                                                 [384 0]
                                                 [512 0]
                                                 [640 0]
                                                 [768 0]
                                                 [768 0]
                                                 [768 0]
                                                 [768 0]
                                                 [0 128]
                                                 [128 128]
                                                 [256 128]
                                                 [384 128]
                                                 [512 128]
                                                 [640 128]
                                                 [768 128]])})

(fn process-entity-death [_system entity [draw delta]]
  (if draw nil
      (when (-> (= 0 (. entity :health))
                (and (not= true (. entity :dead))))
        (do
          (tset entity :dead true)
          (tset entity :flagged-for-removal true)
          (table.insert graves
                        {:original-entity entity
                         :added-to-world false
                         :is-grave true
                         :x (. entity :x)
                         :y (. entity :y)
                         :to-x (. entity :to-x)
                         :to-y (. entity :to-y)
                         :width 128
                         :height 128
                         :x-draw-offset (+ (. entity :x-draw-offset) 16)
                         :y-draw-offset (+ (. entity :y-draw-offset) 16)
                         :zoom-mod (/ 64 92)
                         :action {:name :death
                                  :frame-delta 0
                                  :frames-per-quad 8
                                  :no-loop true
                                  :animating true}
                         : quad-sets
                         :draw [death-sprite-sheet
                                (-> (. quad-sets :death) (. 1))]})))))

(tset entity-death-system :process process-entity-death)

(fn init [world]
  (tset entity-death-system :postWrap
        (fn []
          (each [i grave (pairs graves)]
            (do
              (when (= true (-> grave (. :action) (. :completed-loop)))
                (do
                  (table.remove graves i)
                  (ecs.removeEntity world grave)))
              (when (not= true (. grave :added-to-world))
                (do
                  (tset grave :added-to-world true)
                  (ecs.addEntity world grave)))))))
  (ecs.addSystem world entity-death-system))

{: init}
