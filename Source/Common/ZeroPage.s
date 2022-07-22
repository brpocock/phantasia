;;; Phantasia Source/Source/Common/ZeroPage.s
;;;; Copyright © 2022 Bruce-Robert Pocock


          * = $40

Temp:
          .byte ?

Swap:
          .byte ?

Pointer:
          .word ?

Pointer2:
          .word ?

;;; Vector to the next NMI (presumably, DLI) handler
NMINext:
          .word ?

Source:
          .word ?
Dest:
          .word ?

          ;; Pointers to the ends of the current drawing list or DLL,
          ;; used when building a screen or scrolling.
DLTail:    .word ?
StringsTail:         .word ?
DLLTail:  .word ?

          .if * > $100
            .error format("Overran Zero Page, must end by $ff but ran to $%04x", *-1)
          .fi
