;;; Phantasia Source/Routines/FarJump.s
;;;; Copyright © 2022 Bruce-Robert Pocock

FarJump:      .block

          stx CurrentBank
          stx $8001
          jmp $8000

          .bend
