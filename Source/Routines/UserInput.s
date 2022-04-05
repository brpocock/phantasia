;;; Phantasia Source/Routines/UserInput.s
;;; Copyright © 2022 Bruce-Robert Pocock

UserInput:          .block
          ldy StickY
          beq DoneUpDown

          ldx # 0
          jsr MoveSpriteY

DoneUpDown:
          ldy StickX
          beq DoneStick

          ldx # 0
          jsr MoveSpriteX

DoneStick:

NoStick:
          rts

;;; 
ScrollMapLeft:
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
          inc ScreenChangedP
          rts

ScrollMapRight:
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
          inc ScreenChangedP

          rts

ScrollMapUp:
          ldx MapTopRow
          beq DoneUpDown

          dex
          stx MapTopRow
          inc ScreenChangedP

          rts

ScrollMapDown:
          ldx MapTopRow
          inx
          cpx # 20
          bge DoneUpDown
          stx MapTopRow
          inc ScreenChangedP

          rts
          
          .bend
