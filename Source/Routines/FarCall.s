;;; Phantasia Source/Routines/FarCall.s
;;;; Copyright © 2022 Bruce-Robert Pocock

FarCall:      .block

          lda CurrentBank
          pha
          stx CurrentBank
          stx $8001
          jsr $8000
          pla
          sta CurrentBank
          sta $8001
          rts

          .bend
