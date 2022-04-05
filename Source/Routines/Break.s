;;; Phantasia Source/Routines/Break.s
;;;; Copyright © 2022 Bruce-Robert Pocock

Break:      .block

          jmp Break

          ;; XXX this should be unnecessary but let's do this thing
          .mva CurrentMap, #$ff
          .mva CTRL, CTRLDMADisable
          lda # 0
          tax
          tay
          sta $8001
          jmp $8000

          .bend
