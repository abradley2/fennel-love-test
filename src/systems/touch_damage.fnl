(local ecs (require :lib.ecs))
(local player (require :player))
(local util (require :util))

(local player-state (. player :player-state))

(local touch-damage-system (ecs.processingSystem))

(fn process-touch-damage-system [_system entity [draw delta]]
  (if draw nil (let [collides-with-player (util.check-collision (. entity :x)
                                                                (. entity :y) 16
                                                                16 (. player-state :x)
                                                                (. player-state :y) 16
                                                                16)]
                 (if collides-with-player
                     (let []
                       (print "COLLISION DETECTED")
                       nil)
                     nil))))

(tset touch-damage-system :filter (ecs.requireAll :touch-damage :facing :x :y))
(tset touch-damage-system :process process-touch-damage-system)

(fn init [world]
  (ecs.addSystem world touch-damage-system)
  (ecs.setSystemIndex world touch-damage-system 2))

{: init}
