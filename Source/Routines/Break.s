;;; Phantasia Source/Routines/Break.s
;;;; Copyright © 2022 Bruce-Robert Pocock

Break:      .block

          sta CrashA
          stx CrashX
          sty CrashY
          pla
          sta CrashP
          pla
          sta CrashAddr
          pla
          sta CrashAddr + 1
          tsx
          stx CrashS
          

          .WaitForVBlank
          .mva CTRL, CTRLDMADisable

          ;; TODO: This is where we draw the crash screen.
          ;; TODO: show a sad face of some variety
          ;; TODO: Show registers and stack
          ;; TODO: button I to jump back to loading the current map over.beginn
          ;; TODO: button II to restart the system (warm start)
Restart:
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
