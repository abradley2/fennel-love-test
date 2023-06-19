(local lua-star (require :lib.lua_star))
(local ecs (require :lib.ecs))
(local player (require :player))

(var system nil)

(fn create-tile-map [tiles]
  (accumulate [tile-map {} _ tile (pairs tiles)]
    (let [x (tostring (. tile :col-zidx))
          y (tostring (. tile :row-zidx))]
      (tset tile-map x (or (. tile-map x) {}))
      (-> (. tile-map x) (tset y true))
      tile-map)))

(fn position-is-open-func [tile-map x y tile-idx?]
  (or (-?> tile-map (. x) (. y)) true))

(fn process-pathfinding-system [is-open _system entity [draw delta]]
  (if draw nil (let [player-x (math.floor (-> player (. :player-state) (. :x)
                                              (/ 32)))
                     player-y (math.floor (-> player (. :player-state) (. :y)
                                              (/ 32)))
                     entity-x (math.floor (-> (. entity :x) (/ 32)))
                     entity-y (math.floor (-> (. entity :y) (/ 32)))
                     path (lua-star:find 32 32 {:x entity-x :y entity-y}
                                         {:x player-x :y player-y} is-open true
                                         true)]
                 (print "GOT PATH")
                 (when (not= false path)
                   (each [_ v (ipairs path)]
                     (print (. v :x) (. v :y)))))))

(fn init [world collision-tiles]
  (let [-system (ecs.processingSystem)
        is-open (partial position-is-open-func
                         (create-tile-map collision-tiles))]
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
