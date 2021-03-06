; Changes:
; * removed: 0
; * added: 1
; * swaps: 0
; * negated predicates: 0
; * swapped branches: 0
; * calls to id fun: 0
(letrec ((gen (lambda (n)
                (let* ((n/2 (quotient n 2))
                       (radicals (make-vector (+ n/2 1) (__toplevel_cons 'H ()))))
                   (letrec ((rads-of-size (lambda (n)
                                            ((letrec ((loop1 (lambda (ps lst)
                                                              (if (null? ps)
                                                                 lst
                                                                 (let* ((p (car ps))
                                                                        (nc1 (vector-ref p 0))
                                                                        (nc2 (vector-ref p 1))
                                                                        (nc3 (vector-ref p 2)))
                                                                    ((letrec ((loop2 (lambda (rads1 lst)
                                                                                      (if (null? rads1)
                                                                                         lst
                                                                                         ((letrec ((loop3 (lambda (rads2 lst)
                                                                                                           (if (null? rads2)
                                                                                                              lst
                                                                                                              ((letrec ((loop4 (lambda (rads3 lst)
                                                                                                                                (if (null? rads3)
                                                                                                                                   lst
                                                                                                                                   (cons (vector 'C (car rads1) (car rads2) (car rads3)) (loop4 (cdr rads3) lst))))))
                                                                                                                 loop4)
                                                                                                                 (if (= nc2 nc3) rads2 (vector-ref radicals nc3))
                                                                                                                 (loop3 (cdr rads2) lst))))))
                                                                                            loop3)
                                                                                            (if (= nc1 nc2) rads1 (vector-ref radicals nc2))
                                                                                            (loop2 (cdr rads1) lst))))))
                                                                       loop2)
                                                                       (vector-ref radicals nc1)
                                                                       (loop1 (cdr ps) lst)))))))
                                               loop1)
                                               (three-partitions (- n 1))
                                               ())))
                            (bcp-generator (lambda (j)
                                             (if (odd? j)
                                                ()
                                                ((letrec ((loop1 (lambda (rads1 lst)
                                                                  (if (null? rads1)
                                                                     lst
                                                                     ((letrec ((loop2 (lambda (rads2 lst)
                                                                                       (if (null? rads2)
                                                                                          lst
                                                                                          (cons (vector 'BCP (car rads1) (car rads2)) (loop2 (cdr rads2) lst))))))
                                                                        loop2)
                                                                        rads1
                                                                        (loop1 (cdr rads1) lst))))))
                                                   loop1)
                                                   (vector-ref radicals (quotient j 2))
                                                   ()))))
                            (ccp-generator (lambda (j)
                                             ((letrec ((loop1 (lambda (ps lst)
                                                               (if (null? ps)
                                                                  lst
                                                                  (let* ((p (car ps))
                                                                         (nc1 (vector-ref p 0))
                                                                         (nc2 (vector-ref p 1))
                                                                         (nc3 (vector-ref p 2))
                                                                         (nc4 (vector-ref p 3)))
                                                                     ((letrec ((loop2 (lambda (rads1 lst)
                                                                                       (if (null? rads1)
                                                                                          lst
                                                                                          ((letrec ((loop3 (lambda (rads2 lst)
                                                                                                            (if (null? rads2)
                                                                                                               lst
                                                                                                               ((letrec ((loop4 (lambda (rads3 lst)
                                                                                                                                 (if (null? rads3)
                                                                                                                                    lst
                                                                                                                                    ((letrec ((loop5 (lambda (rads4 lst)
                                                                                                                                                      (if (null? rads4)
                                                                                                                                                         lst
                                                                                                                                                         (cons (vector 'CCP (car rads1) (car rads2) (car rads3) (car rads4)) (loop5 (cdr rads4) lst))))))
                                                                                                                                       loop5)
                                                                                                                                       (if (= nc3 nc4) rads3 (vector-ref radicals nc4))
                                                                                                                                       (loop4 (cdr rads3) lst))))))
                                                                                                                  loop4)
                                                                                                                  (if (= nc2 nc3) rads2 (vector-ref radicals nc3))
                                                                                                                  (loop3 (cdr rads2) lst))))))
                                                                                             loop3)
                                                                                             (if (= nc1 nc2) rads1 (vector-ref radicals nc2))
                                                                                             (loop2 (cdr rads1) lst))))))
                                                                        loop2)
                                                                        (vector-ref radicals nc1)
                                                                        (loop1 (cdr ps) lst)))))))
                                                loop1)
                                                (four-partitions (- j 1))
                                                ()))))
                      ((letrec ((loop (lambda (i)
                                       (if (> i n/2)
                                          (vector (bcp-generator n) (ccp-generator n))
                                          (begin
                                             (vector-set! radicals i (rads-of-size i))
                                             (loop (+ i 1)))))))
                         loop)
                         1)))))
         (three-partitions (lambda (m)
                             (<change>
                                ()
                                (display +))
                             ((letrec ((loop1 (lambda (lst nc1)
                                               (if (< nc1 0)
                                                  lst
                                                  ((letrec ((loop2 (lambda (lst nc2)
                                                                    (if (< nc2 nc1)
                                                                       (loop1 lst (- nc1 1))
                                                                       (loop2 (cons (vector nc1 nc2 (- m (+ nc1 nc2))) lst) (- nc2 1))))))
                                                     loop2)
                                                     lst
                                                     (quotient (- m nc1) 2))))))
                                loop1)
                                ()
                                (quotient m 3))))
         (four-partitions (lambda (m)
                            ((letrec ((loop1 (lambda (lst nc1)
                                              (if (< nc1 0)
                                                 lst
                                                 ((letrec ((loop2 (lambda (lst nc2)
                                                                   (if (< nc2 nc1)
                                                                      (loop1 lst (- nc1 1))
                                                                      (let ((start (max nc2 (- (quotient (+ m 1) 2) (+ nc1 nc2)))))
                                                                         ((letrec ((loop3 (lambda (lst nc3)
                                                                                           (if (< nc3 start)
                                                                                              (loop2 lst (- nc2 1))
                                                                                              (loop3 (cons (vector nc1 nc2 nc3 (- m (+ nc1 (+ nc2 nc3)))) lst) (- nc3 1))))))
                                                                            loop3)
                                                                            lst
                                                                            (quotient (- m (+ nc1 nc2)) 2)))))))
                                                    loop2)
                                                    lst
                                                    (quotient (- m nc1) 3))))))
                               loop1)
                               ()
                               (quotient m 4))))
         (nb (lambda (n)
               (let ((x (gen n)))
                  (+ (length (vector-ref x 0)) (length (vector-ref x 1)))))))
   (= (nb 17) 24894))