;;; Phantasia Source/Routines/TileDLI.s
;;; Copyright © 2022 Bruce-Robert Pocock

TileDLI:  .block

          .BankSwitch # 1

          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mva BACKGRND, $9000

          .for p := 0, p < 8, p := p + 1
            .for c := 0, c < 3, c := c + 1
              .mva P0C1 + p * 4 + c, $9000 + p * 3 + c
            .next
          .next

          .BankSwitch CurrentBank

          rts
          
          .bend
