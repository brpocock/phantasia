;;; Phantasia Source/Routines/TileDLI.s
;;; Copyright © 2022 Bruce-Robert Pocock

TileDLI:  .block

          ldx # 8
-
          stx WSYNC
          dex
          bne -

          .BankSwitch # 1

          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mva BACKGRND, $9000

          .for p := 0, p < 8, p := p + 1
            .for c := 0, c < 3, c := c + 1
              .mva P0C1 + p * 4 + c, $9001 + p * 3 + c
            .next
          .next

          .mva CHARBASE, #>$8000

          ;; XXX do useful work while Maria is busy

          .WaitForVBlank

          .BankSwitch CurrentBank

          stx WSYNC
          .mva BACKGRND, # 0

          .mvaw NMINext, $9000
          jmp JReturnFromInterrupt
          
          .bend
