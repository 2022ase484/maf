; Changes:
; * removed: 0
; * added: 0
; * swaps: 0
; * negated predicates: 1
; * swapped branches: 0
; * calls to id fun: 0
(letrec ((fib (lambda (n)
                (if (<change> (< n 2) (not (< n 2)))
                   n
                   (+ (fib (- n 1)) (fib (- n 2)))))))
   (fib 10))