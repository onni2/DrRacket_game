#lang racket

(require 2htdp/image)
(require 2htdp/universe)

;; Constants
(define WIDTH 930)   ; Game field size
(define HEIGHT 510)
(define CHARACTER-SIZE 15)  ; Slightly smaller character
(define MOVE-SPEED 5)       ; Smooth movement
(define CELL-SIZE 30)       ; Larger cell size for a better maze layout

;; Create a red square as the character
(define character (square CHARACTER-SIZE "solid" "red"))
(define exit-color (square CELL-SIZE "solid" "green"))  ; Exit square

;; New, more complex maze
(define maze
  (list
   "###############################"
   "#.....#..............#........#"
   "#..#..####..#..####..####..#..#"
   "#..#..#..#..#.....#.....#..#..#"
   "####..#..#..#..#######..####..#"
   "#.....#.....#.....#.....#.....#"
   "#..#..#..#..#############..####"
   "#..#.....#...........#........#"
   "#######..#..####..#..#######..#"
   "#..#.....#..#..#..#..#..#.....#"
   "#..####..####..#..#..#..#..#..#"
   "#...........#..#..#........#..#"
   "#..##########..#..#############"
   "#........#..#...........#E....#"
   "####..#..#..#..#..####..####..#"
   "#.....#..#.....#..#...........#"
   "###############################"))



;; Convert maze grid into a list of walls
(define (maze->walls maze)
  (foldl
   (lambda (row y acc)
     (foldl
      (lambda (cell x acc2)
        (cond
          [(char=? cell #\#) (cons (list (* x CELL-SIZE) (* y CELL-SIZE) CELL-SIZE CELL-SIZE) acc2)]
          [else acc2]))
      acc
      (string->list row)
      (range (string-length row))))
   '()
   maze
   (range (length maze))))

(define walls (maze->walls maze))

;; Define exit position (where 'E' is)
(define (find-exit maze)
  (let loop ((rows maze) (y 0))
    (if (null? rows)
        '()
        (let* ((row (car rows))
               (x (string-contains row "E")))
          (if x
              (list (* x CELL-SIZE) (* y CELL-SIZE))
              (loop (cdr rows) (+ y 1)))))))

;; Helper function to find column index of 'E'
(define (string-contains str char)
  (let loop ((lst (string->list str)) (i 0))
    (cond [(null? lst) #f]
          [(char=? (car lst) (string-ref char 0)) i]
          [else (loop (cdr lst) (+ i 1))])))

(define exit-pos (find-exit maze))

;; Initial character position (left-side open space)
(define initial-position (list (+ CELL-SIZE (/ CHARACTER-SIZE 2))
                               (+ CELL-SIZE (/ CHARACTER-SIZE 2))))

;; Function to check if two rectangles overlap
(define (rect-overlaps? x1 y1 w1 h1 x2 y2 w2 h2)
  (not (or (<= (+ x1 w1) x2)
           (>= x1 (+ x2 w2))
           (<= (+ y1 h1) y2)
           (>= y1 (+ y2 h2)))))

;; Function to check collision
(define (collides? new-x new-y)
  (ormap
   (lambda (wall)
     (rect-overlaps? (- new-x (/ CHARACTER-SIZE 2))
                     (- new-y (/ CHARACTER-SIZE 2))
                     CHARACTER-SIZE CHARACTER-SIZE
                     (first wall) (second wall) (third wall) (fourth wall)))
   walls))

;; Function to check if the character has reached the exit
(define (at-exit? pos)
  (rect-overlaps? (- (first pos) (/ CHARACTER-SIZE 2))
                  (- (second pos) (/ CHARACTER-SIZE 2))
                  CHARACTER-SIZE CHARACTER-SIZE
                  (first exit-pos) (second exit-pos) CELL-SIZE CELL-SIZE))

;; Function to move the character while checking for collisions
(define (move-character pos key)
  (if (equal? pos 'win)
      'win  ; Keep the win state unchanged
      (let* ((x (first pos))
             (y (second pos))
             (new-x (cond [(string=? key "left")  (- x MOVE-SPEED)]
                          [(string=? key "right") (+ x MOVE-SPEED)]
                          [else x]))
             (new-y (cond [(string=? key "up")    (- y MOVE-SPEED)]
                          [(string=? key "down")  (+ y MOVE-SPEED)]
                          [else y])))
        (cond
          [(collides? new-x y) (list x y)]  ; Block horizontal movement
          [(collides? x new-y) (list x y)]  ; Block vertical movement
          [(at-exit? (list new-x new-y)) 'win] ; Check if at exit
          [else (list new-x new-y)]))))  ; Move if no collision


;; Function to draw the game scene
(define (draw-world pos)
  (if (equal? pos 'win)
      (overlay (text "You Win!" 50 "green") (empty-scene WIDTH HEIGHT))
      (foldl
       (lambda (wall img)
         (place-image (rectangle (third wall) (fourth wall) "solid" "black")
                      (+ (first wall) (/ (third wall) 2))
                      (+ (second wall) (/ (fourth wall) 2))
                      img))
       (place-image exit-color
                    (+ (first exit-pos) (/ CELL-SIZE 2))
                    (+ (second exit-pos) (/ CELL-SIZE 2))
                    (place-image character (first pos) (second pos) (empty-scene WIDTH HEIGHT)))
       walls)))

;; Run the game
(big-bang initial-position
          [on-key move-character]
          [to-draw draw-world])
