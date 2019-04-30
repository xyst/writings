#lang racket/base
(define (sum i [s 0])
  (if (zero? i) s (sum (- i 1) (+ i s))) )
(sum 1234567890)
