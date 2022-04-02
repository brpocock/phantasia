;;; Phantasia Source/Routines/UserInput.s
;;; Copyright © 2022 Bruce-Robert Pocock

UserInput:          .block
          lda StickY
          beq DoneUpDown

          bmi StickDown

StickUp:
          ldx MapTopRow
          beq DoneUpDown

          dex
          stx MapTopRow
          jmp DoneUpDown

StickDown:
          ldx MapTopRow
          inx
          cpx # 20
          bge DoneUpDown
          stx MapTopRow

DoneUpDown:
          lda StickX
          beq DoneLeftRight

          bpl StickRight

StickLeft:
          ldx MapLeftPixel
          dex
          bpl LeftOK
          txa
          clc
          adc # 8
          tax
          lda MapLeftColumn
          beq LeftOK
          sec
          sbc # 1
          sta MapLeftColumn
LeftOK:
          stx MapLeftPixel
DoneLeft:
          jmp DoneLeftRight

StickRight:
          ldx MapLeftPixel
          inx
          cpx # 8
          blt RightOK
          txa
          sec
          sbc # 8
          tax
          lda MapLeftColumn
          cmp # 11
          bge RightOK
          clc
          adc # 1
          sta MapLeftColumn
RightOK:
          stx MapLeftPixel
DoneRight:
DoneLeftRight:
DoneStick:
          inc ScreenChangedP

NoStick:
          rts

          .bend
