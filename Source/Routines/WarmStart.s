;;; Phantasia Source/Routines/WarmStart.s
;;;; Copyright © 2022 Bruce-Robert Pocock

WarmStart:	.block

          ldy # 0
          sty AUDC0
          sty AUDC1
          sty AUDF0
          sty AUDF1
          sty AUDV0
          sty AUDV1

          .mvx s, #$ff          ; smash stack, if any
          .mva GameMode, #ModeTitleScreen

          .BankSwitch # 2
          jmp $8000

          .bend
