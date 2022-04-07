;;; Phantasia Source/Routines/Break.s
;;;; Copyright © 2022 Bruce-Robert Pocock

Break:      .block

          .mva NextMap, CurrentMap
          .mva CurrentMap, #$ff
          .mva CTRL, CTRLDMADisable
          ldx #$ff
          txs
          inx
          txa
          tay
          sta $8001
          jmp $8000

          .bend
