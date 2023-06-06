(local ecs (require :lib.ecs))

(local system (ecs.processingSystem))

(fn choose-sprite-quad [sprite-quads delta frames-per-quad]
  (let [cur-frame (+ 1 (math.floor (/ delta frames-per-quad)))]
    (if (. sprite-quads cur-frame)
        [(. sprite-quads cur-frame) delta]
        (choose-sprite-quad sprite-quads 0 frames-per-quad))))

(fn system-process [_ entity [love-draw delta]]
  (if love-draw nil
      (let [action (. entity :action)
            action-name (. action :name)
            animating (. action :animating)
            quad-sets (-> entity (. :quad-sets) (. action-name))
            frame-delta (+ (or (. action :frame-delta) 0)
                           (if animating delta 0))
            frames-per-quad (. action :frames-per-quad)
            [sprite-sheet _] (. entity :draw)
            [sprite-quad next-frame-delta] (choose-sprite-quad quad-sets
                                                               frame-delta
                                                               frames-per-quad)]
        (tset action :frame-delta next-frame-delta)
        (tset entity :draw [sprite-sheet sprite-quad]))))

(tset system :filter (ecs.requireAll :quad-sets :action :draw))
(tset system :process system-process)

{:sprite-sheet -sprite-sheet : system}
