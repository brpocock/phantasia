;;; Phantasia Source/Routines/UserInput.s
;;; Copyright © 2022 Bruce-Robert Pocock

UserInput:          .block
          lda NewSWCHA
          beq NoStick

          and #$10
          beq DoneUp
          ldx MapTopRow
          beq DoneUp
          dex
          stx MapTopRow
DoneUp:
          and #$20
          beq DoneDown
          ldx MapTopRow
          inx
          cpx # 20
          bge DoneDown
          stx MapTopRow
DoneDown:
          and #$40
          beq DoneLeft
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
          lda NewSWCHA
LeftOK:
          stx MapLeftPixel
DoneLeft:
          and #$80
          beq DoneRight
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
          lda NewSWCHA
RightOK:
          stx MapLeftPixel
DoneRight:
DoneStick:
          inc ScreenChangedP

NoStick:
          rts

          .bend
