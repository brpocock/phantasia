;;; Phantasia Source/Routines/NMI.s
;;;; Copyright © 2022 Bruce-Robert Pocock

NMI:      .block

          pha
          lda NMINext + 1
          beq +

          pla
          jmp (NMINext)
+
          pla
          rti

          .bend
