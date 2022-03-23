;;; Phantasia Source/Source/Common/ZeroPage.s
;;;; Copyright © 2022 Bruce-Robert Pocock


          * = $40

Temp:
          .byte ?

Counter:
          .byte ?

Swap:
          .byte ?

Pointer:
          .word ?

;;; Vector to the next NMI (presumably, DLI) handler
NMINext:
          .word ?

          .if * > $100
            .error format("Overran Zero Page, must end by $ff but ran to $%04x", *-1)
          .fi
