(local lua-star (require :lib.lua_star))
(local ecs (require :lib.ecs))
(local util (require :util))
(local player (require :player))

(var system nil)

(fn position-is-open-func [tiles x y tile-idx?]
  (let [tile-idx (or tile-idx 1)
        tile (. tiles tile-idx)
        next-tile-idx (+ tile-idx 1)
        does-collide (util.check-collision x y 64 64 (. tile :x) (. tile :y) 64
                                           64)]
    (if does-collide false
        (> next-tile-idx (length tiles)) true
        (position-is-open-func tiles x y next-tile-idx))))

(fn process-pathfinding-system [is-open _system entity [draw delta]]
  (if draw nil (let [player-x (-> player (. :player-state) (. :x))
                     player-y (-> player (. :player-state) (. :y))
                     entity-x (. entity :x)
                     entity-y (. entity :y)
                     path (lua-star:find 64 64 {:x entity-x :y entity-y}
                                         {:x player-x :y player-y} is-open true
                                         true)]
                 (print "GOT PATH" path))))

(fn init [world collision-tiles]
  (let [-system (ecs.processingSystem)
        is-open (partial position-is-open-func collision-tiles)]
    (tset -system :filter (ecs.requireAll :pathfinding-target))
    (tset -system :process (partial process-pathfinding-system is-open))
    (set system -system)
    (ecs.addSystem world -system)))

(fn deinit [world]
  (ecs.removeSystem world system))

{: init : deinit}

;; local luastar = require("lua-star")

;; function positionIsOpenFunc(x, y)
;;     -- should return true if the position is open to walk
;;     return mymap[x][y] == walkable
;; end
;; local path = luastar:find(width, height, start, goal, positionIsOpenFunc, useCache, excludeDiagonalMoving)
