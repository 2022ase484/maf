; Changes:
; * removed: 3
; * added: 3
; * swaps: 6
; * negated predicates: 0
; * swapped branches: 1
; * calls to id fun: 8
(letrec ((my-iota (lambda (n)
                    @sensitivity:FA
                    (letrec ((__do_loop (lambda (n list)
                                          (<change>
                                             @sensitivity:FA
                                             ())
                                          (if (zero? n)
                                             list
                                             (__do_loop (- n 1) (cons (- n 1) list))))))
                       (__do_loop n ()))))
         (size 511)
         (classmax 3)
         (typemax 12)
         (*iii* 0)
         (*kount* 0)
         (*d* 8)
         (*piececount* (make-vector (+ classmax 1) 0))
         (*class* (make-vector (+ typemax 1) 0))
         (*piecemax* (make-vector (+ typemax 1) 0))
         (*puzzle* (make-vector (+ size 1)))
         (*p* (make-vector (+ typemax 1)))
         (fit (lambda (i j)
                (<change>
                   @sensitivity:FA
                   (let ((end (vector-ref *piecemax* i)))
                      (letrec ((__do_loop (lambda (k)
                                            @sensitivity:No
                                            (if (let ((__or_res (> k end))) (if __or_res __or_res (if (vector-ref (vector-ref *p* i) k) (vector-ref *puzzle* (+ j k)) #f)))
                                               (if (> k end) #t #f)
                                               (__do_loop (+ k 1))))))
                         (__do_loop 0))))
                (<change>
                   (let ((end (vector-ref *piecemax* i)))
                      (letrec ((__do_loop (lambda (k)
                                            @sensitivity:No
                                            (if (let ((__or_res (> k end))) (if __or_res __or_res (if (vector-ref (vector-ref *p* i) k) (vector-ref *puzzle* (+ j k)) #f)))
                                               (if (> k end) #t #f)
                                               (__do_loop (+ k 1))))))
                         (__do_loop 0)))
                   @sensitivity:FA)))
         (place (lambda (i j)
                  (<change>
                     ()
                     k)
                  @sensitivity:FA
                  (let ((end (vector-ref *piecemax* i)))
                     (<change>
                        ()
                        (if (> k size) 0 k))
                     (letrec ((__do_loop (lambda (k)
                                           @sensitivity:FA
                                           (<change>
                                              (if (> k end)
                                                 #f
                                                 (begin
                                                    (if (vector-ref (vector-ref *p* i) k)
                                                       (begin
                                                          (vector-set! *puzzle* (+ j k) #t)
                                                          #t)
                                                       #f)
                                                    (__do_loop (+ k 1))))
                                              ((lambda (x) x)
                                                 (if (> k end)
                                                    #f
                                                    (begin
                                                       (<change>
                                                          (if (vector-ref (vector-ref *p* i) k)
                                                             (begin
                                                                (vector-set! *puzzle* (+ j k) #t)
                                                                #t)
                                                             #f)
                                                          ((lambda (x) x)
                                                             (if (vector-ref (vector-ref *p* i) k)
                                                                (begin
                                                                   (vector-set! *puzzle* (+ j k) #t)
                                                                   #t)
                                                                #f)))
                                                       (__do_loop (+ k 1)))))))))
                        (__do_loop 0))
                     (vector-set!
                        *piececount*
                        (vector-ref *class* i)
                        (- (vector-ref *piececount* (vector-ref *class* i)) 1))
                     (letrec ((__do_loop (lambda (k)
                                           @sensitivity:FA
                                           (if (let ((__or_res (> k size))) (if __or_res __or_res (not (vector-ref *puzzle* k))))
                                              (if (> k size) 0 k)
                                              (__do_loop (+ k 1))))))
                        (__do_loop j)))))
         (puzzle-remove (lambda (i j)
                          (<change>
                             @sensitivity:FA
                             ((lambda (x) x) @sensitivity:FA))
                          (let ((end (vector-ref *piecemax* i)))
                             (letrec ((__do_loop (lambda (k)
                                                   (<change>
                                                      @sensitivity:FA
                                                      ())
                                                   (if (> k end)
                                                      #f
                                                      (begin
                                                         (if (vector-ref (vector-ref *p* i) k)
                                                            (begin
                                                               (vector-set! *puzzle* (+ j k) #f)
                                                               #f)
                                                            #f)
                                                         (__do_loop (+ k 1)))))))
                                (__do_loop 0))
                             (<change>
                                (vector-set!
                                   *piececount*
                                   (vector-ref *class* i)
                                   (+ (vector-ref *piececount* (vector-ref *class* i)) 1))
                                ((lambda (x) x)
                                   (vector-set!
                                      *piececount*
                                      (vector-ref *class* i)
                                      (+ (vector-ref *piececount* (vector-ref *class* i)) 1)))))))
         (trial (lambda (j)
                  @sensitivity:FA
                  (let ((k 0)
                        (return #f))
                     (<change>
                        ()
                        (display *kount*))
                     (lambda (return)
                        (letrec ((__do_loop (lambda (i)
                                              @sensitivity:FA
                                              (if (let ((__or_res return)) (if __or_res __or_res (> i typemax)))
                                                 (begin
                                                    (set! *kount* (+ *kount* 1))
                                                    return)
                                                 (begin
                                                    (if (not (zero? (vector-ref *piececount* (vector-ref *class* i))))
                                                       (if (fit i j)
                                                          (begin
                                                             (set! k (place i j))
                                                             (if (let ((__or_res (trial k))) (if __or_res __or_res (zero? k)))
                                                                (begin
                                                                   (set! *kount* (+ *kount* 1))
                                                                   (set! return #t))
                                                                (puzzle-remove i j)))
                                                          #f)
                                                       #f)
                                                    (__do_loop (+ i 1)))))))
                           (__do_loop 0))))))
         (definePiece (lambda (iclass ii jj kk)
                        @sensitivity:FA
                        (<change>
                           (let ((index 0))
                              (letrec ((__do_loop (lambda (i)
                                                    @sensitivity:FA
                                                    (if (> i ii)
                                                       #f
                                                       (begin
                                                          (letrec ((__do_loop (lambda (j)
                                                                                @sensitivity:FA
                                                                                (if (> j jj)
                                                                                   #f
                                                                                   (begin
                                                                                      (letrec ((__do_loop (lambda (k)
                                                                                                            @sensitivity:FA
                                                                                                            (if (> k kk)
                                                                                                               #f
                                                                                                               (begin
                                                                                                                  (set! index (+ i (* *d* (+ j (* *d* k)))))
                                                                                                                  (vector-set! (vector-ref *p* *iii*) index #t)
                                                                                                                  (__do_loop (+ k 1)))))))
                                                                                         (__do_loop 0))
                                                                                      (__do_loop (+ j 1)))))))
                                                             (__do_loop 0))
                                                          (__do_loop (+ i 1)))))))
                                 (__do_loop 0))
                              (vector-set! *class* *iii* iclass)
                              (vector-set! *piecemax* *iii* index)
                              (if (not (= *iii* typemax))
                                 (set! *iii* (+ *iii* 1))
                                 #f))
                           ((lambda (x) x)
                              (let ((index 0))
                                 (<change>
                                    (letrec ((__do_loop (lambda (i)
                                                          @sensitivity:FA
                                                          (if (> i ii)
                                                             #f
                                                             (begin
                                                                (letrec ((__do_loop (lambda (j)
                                                                                      @sensitivity:FA
                                                                                      (if (> j jj)
                                                                                         #f
                                                                                         (begin
                                                                                            (letrec ((__do_loop (lambda (k)
                                                                                                                  @sensitivity:FA
                                                                                                                  (if (> k kk)
                                                                                                                     #f
                                                                                                                     (begin
                                                                                                                        (set! index (+ i (* *d* (+ j (* *d* k)))))
                                                                                                                        (vector-set! (vector-ref *p* *iii*) index #t)
                                                                                                                        (__do_loop (+ k 1)))))))
                                                                                               (__do_loop 0))
                                                                                            (__do_loop (+ j 1)))))))
                                                                   (__do_loop 0))
                                                                (__do_loop (+ i 1)))))))
                                       (__do_loop 0))
                                    (vector-set! *class* *iii* iclass))
                                 (<change>
                                    (vector-set! *class* *iii* iclass)
                                    (letrec ((__do_loop (lambda (i)
                                                          @sensitivity:FA
                                                          (if (> i ii)
                                                             (begin
                                                                (letrec ((__do_loop (lambda (j)
                                                                                      @sensitivity:FA
                                                                                      (if (> j jj)
                                                                                         #f
                                                                                         (begin
                                                                                            (letrec ((__do_loop (lambda (k)
                                                                                                                  @sensitivity:FA
                                                                                                                  (if (> k kk)
                                                                                                                     #f
                                                                                                                     (begin
                                                                                                                        (set! index (+ i (* *d* (+ j (* *d* k)))))
                                                                                                                        (vector-set! (vector-ref *p* *iii*) index #t)
                                                                                                                        (__do_loop (+ k 1)))))))
                                                                                               (__do_loop 0))
                                                                                            (__do_loop (+ j 1)))))))
                                                                   (__do_loop 0))
                                                                (__do_loop (+ i 1)))
                                                             #f))))
                                       (__do_loop 0)))
                                 (vector-set! *piecemax* *iii* index)
                                 (if (not (= *iii* typemax))
                                    (set! *iii* (+ *iii* 1))
                                    #f))))))
         (start (lambda ()
                  @sensitivity:FA
                  (set! *kount* 0)
                  (<change>
                     (letrec ((__do_loop (lambda (m)
                                           @sensitivity:FA
                                           (if (> m size)
                                              #f
                                              (begin
                                                 (vector-set! *puzzle* m #t)
                                                 (__do_loop (+ m 1)))))))
                        (__do_loop 0))
                     ())
                  (letrec ((__do_loop (lambda (i)
                                        @sensitivity:FA
                                        (if (> i 5)
                                           #f
                                           (begin
                                              (letrec ((__do_loop (lambda (j)
                                                                    @sensitivity:FA
                                                                    (if (> j 5)
                                                                       #f
                                                                       (begin
                                                                          (letrec ((__do_loop (lambda (k)
                                                                                                @sensitivity:FA
                                                                                                (if (> k 5)
                                                                                                   #f
                                                                                                   (begin
                                                                                                      (vector-set! *puzzle* (+ i (* *d* (+ j (* *d* k)))) #f)
                                                                                                      (__do_loop (+ k 1)))))))
                                                                             (__do_loop 1))
                                                                          (__do_loop (+ j 1)))))))
                                                 (__do_loop 1))
                                              (__do_loop (+ i 1)))))))
                     (__do_loop 1))
                  (letrec ((__do_loop (lambda (i)
                                        @sensitivity:FA
                                        (if (> i typemax)
                                           #f
                                           (begin
                                              (letrec ((__do_loop (lambda (m)
                                                                    @sensitivity:FA
                                                                    (if (> m size)
                                                                       #f
                                                                       (begin
                                                                          (vector-set! (vector-ref *p* i) m #f)
                                                                          (__do_loop (+ m 1)))))))
                                                 (__do_loop 0))
                                              (__do_loop (+ i 1)))))))
                     (__do_loop 0))
                  (set! *iii* 0)
                  (definePiece 0 3 1 0)
                  (definePiece 0 1 0 3)
                  (<change>
                     (definePiece 0 0 3 1)
                     (definePiece 0 1 3 0))
                  (<change>
                     (definePiece 0 1 3 0)
                     (definePiece 0 0 3 1))
                  (<change>
                     (definePiece 0 3 0 1)
                     ((lambda (x) x) (definePiece 0 3 0 1)))
                  (definePiece 0 0 1 3)
                  (<change>
                     (definePiece 1 2 0 0)
                     (definePiece 1 0 2 0))
                  (<change>
                     (definePiece 1 0 2 0)
                     (definePiece 1 2 0 0))
                  (<change>
                     (definePiece 1 0 0 2)
                     ((lambda (x) x) (definePiece 1 0 0 2)))
                  (definePiece 2 1 1 0)
                  (<change>
                     (definePiece 2 1 0 1)
                     (definePiece 2 0 1 1))
                  (<change>
                     (definePiece 2 0 1 1)
                     (definePiece 2 1 0 1))
                  (definePiece 3 1 1 1)
                  (vector-set! *piececount* 0 13)
                  (vector-set! *piececount* 1 3)
                  (<change>
                     (vector-set! *piececount* 2 1)
                     ((lambda (x) x) (vector-set! *piececount* 2 1)))
                  (vector-set! *piececount* 3 1)
                  (let ((m (+ (* *d* (+ *d* 1)) 1))
                        (n 0))
                     (if (fit 0 m)
                        (set! n (place 0 m))
                        (begin
                           (newline)
                           (display "Error.")))
                     (if (trial n) *kount* #f)))))
   (for-each
      (lambda (i)
         (<change>
            @sensitivity:FA
            (vector-set! *p* i (make-vector (+ size 1))))
         (<change>
            (vector-set! *p* i (make-vector (+ size 1)))
            @sensitivity:FA))
      (my-iota (+ typemax 1)))
   (= (start) 2005))