; Changes:
; * removed: 1
; * added: 1
; * swaps: 1
; * negated predicates: 0
; * swapped branches: 0
; * calls to id fun: 0
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
                                                        (set! ontvangen bedrag)
                                                        (error "wrong type")))))
                                         (enter (lambda ()
                                                  (if (eq? ingetoetst 'product)
                                                     (te-betalen 'lees)
                                                     (let ((wisselgeld (- ontvangen (te-betalen 'lees))))
                                                        ((saldo 'toets) (te-betalen 'lees))
                                                        (te-betalen 'reset)
                                                        wisselgeld))))
                                         (inhoud (lambda ()
                                                   (saldo 'lees)))
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
   (<change>
      ((teller 'toets) 20)
      ())
   ((winkelkassa 'toets) 'product 5)
   (<change>
      ()
      (= (winkelkassa 'enter) 25))
   (if (= (teller 'lees) 20)
      (if (begin (teller 'reset) (= (teller 'lees) 0))
         (if (= (winkelkassa 'enter) 25)
            (if (= (begin (<change> ((winkelkassa 'toets) 'product 10) (winkelkassa 'enter)) (<change> (winkelkassa 'enter) ((winkelkassa 'toets) 'product 10))) 35)
               (if (begin ((winkelkassa 'toets) 'ontvangen 50) (= (winkelkassa 'enter) 15))
                  (= (winkelkassa 'inhoud) 35)
                  #f)
               #f)
            #f)
         #f)
      #f))