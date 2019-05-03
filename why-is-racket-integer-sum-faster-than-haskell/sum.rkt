#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 444333222111)
(sum begin (+ begin 1234567890) 0)
