(fn check-collision [x1 y1 w1 h1 x2 y2 w2 h2]
  (if (or (<= (+ x1 w1) x2) (<= (+ x2 w2) x1) (<= (+ y1 h1) y2)
          (<= (+ y2 h2) y1))
      false
      true))

(fn offset-pairs-to-quads [width height sheet]
  (fn [offset-pairs]
    (icollect [_ [x y] (ipairs offset-pairs)]
      (love.graphics.newQuad x y 128 128 (sheet:getDimensions)))))

{: check-collision : offset-pairs-to-quads}
