; Changes:
; * removed: 1
; * added: 2
; * swaps: 0
; * negated predicates: 1
; * swapped branches: 1
; * calls to id fun: 1
(letrec ((maak-teller (lambda ()
                        (let ((result 0))
                           (letrec ((toets (lambda (bedrag)
                                             (set! result (+ result bedrag))))
                                    (reset (lambda ()
                                             (set! result 0)))
                                    (dispatch (lambda (msg)
                                                (if (eq? msg 'toets)
                                                   toets
                                                   (if (eq? msg 'lees)
                                                      result
                                                      (if (eq? msg 'reset)
                                                         (reset)
                                                         (error "wrong message")))))))
                              (<change>
                                 ()
                                 dispatch)
                              dispatch))))
         (maak-winkelkassa (lambda ()
                             (let ((saldo (maak-teller))
                                   (te-betalen (maak-teller))
                                   (ingetoetst 'product)
                                   (ontvangen 0))
                                (letrec ((toets (lambda (type bedrag)
                                                  (set! ingetoetst type)
                                                  (if (eq? type 'product)
                                                     ((te-betalen 'toets) bedrag)
                                                     (if (eq? type 'ontvangen)
                                                        (<change>
                                                           (set! ontvangen bedrag)
                                                           (error "wrong type"))
                                                        (<change>
                                                           (error "wrong type")
                                                           (set! ontvangen bedrag))))))
                                         (enter (lambda ()
                                                  (if (eq? ingetoetst 'product)
                                                     (te-betalen 'lees)
                                                     (let ((wisselgeld (- ontvangen (te-betalen 'lees))))
                                                        (<change>
                                                           ()
                                                           te-betalen)
                                                        ((saldo 'toets) (te-betalen 'lees))
                                                        (te-betalen 'reset)
                                                        wisselgeld))))
                                         (inhoud (lambda ()
                                                   (<change>
                                                      (saldo 'lees)
                                                      ((lambda (x) x) (saldo 'lees)))))
                                         (afsluiten (lambda ()
                                                      (let ((teruggeven saldo))
                                                         (set! saldo 0)
                                                         teruggeven)))
                                         (dispatch (lambda (msg)
                                                     (if (eq? msg 'toets)
                                                        toets
                                                        (if (eq? msg 'enter)
                                                           (enter)
                                                           (if (eq? msg 'inhoud)
                                                              (inhoud)
                                                              (if (eq? msg 'afsluiten)
                                                                 (afsluiten)
                                                                 (error "wrong message"))))))))
                                   dispatch))))
         (teller (maak-teller))
         (winkelkassa (maak-winkelkassa)))
   ((winkelkassa 'toets) 'product 20)
   ((teller 'toets) 20)
   ((winkelkassa 'toets) 'product 5)
   (if (<change> (= (teller 'lees) 20) (not (= (teller 'lees) 20)))
      (if (begin (teller 'reset) (= (teller 'lees) 0))
         (if (= (winkelkassa 'enter) 25)
            (if (= (begin ((winkelkassa 'toets) 'product 10) (winkelkassa 'enter)) 35)
               (if (begin (<change> ((winkelkassa 'toets) 'ontvangen 50) ()) (= (winkelkassa 'enter) 15))
                  (= (winkelkassa 'inhoud) 35)
                  #f)
               #f)
            #f)
         #f)
      #f))