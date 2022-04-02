;;; Phantasia Source/Routines/TileDLI.s
;;; Copyright © 2022 Bruce-Robert Pocock

TileDLI:  .block

          stx WSYNC
          .mva BACKGRND, # 0
          .mva CTRL, #CTRLDMADisable

          .BankSwitch # 1

          .mva CHARBASE, #>$8000

          .for p := 0, p < 8, p := p + 1
            .for c := 0, c < 3, c := c + 1
              .mva P0C1 + p * 4 + c, $9001 + p * 3 + c
            .next
          .next

          stx WSYNC
          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB | CTRLCharWide

          stx WSYNC
          stx WSYNC
          .mva BACKGRND, $9000

          ;; XXX AlarmV is probably in the other ROM bank?
          jsr FrameService

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
          ;; XXX do useful work while Maria is busy

          .WaitForVBlank

          .BankSwitch CurrentBank

          stx WSYNC
          .mva BACKGRND, # 0

          .mvaw NMINext, $9000
          jmp JReturnFromInterrupt
          
          .bend
