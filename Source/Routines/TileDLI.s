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
          
          ;; jsr FrameService

          ;; XXX do useful work while Maria is busy

          .WaitForVBlank

          .BankSwitch CurrentBank

          stx WSYNC
          .mva BACKGRND, # 0

          .mvaw NMINext, $9000
          jmp JReturnFromInterrupt
          
          .bend
