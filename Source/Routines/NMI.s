;;; Phantasia Source/Routines/NMI.s
;;;; Copyright © 2022 Bruce-Robert Pocock

NMI:      .block

          lda NMINext
          beq +
          jmp (NMINext)
+
          rti

          .bend
