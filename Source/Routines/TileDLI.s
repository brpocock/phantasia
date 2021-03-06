;;; Phantasia Source/Routines/TileDLI.s
;;; Copyright © 2022 Bruce-Robert Pocock

TileDLI:  .block

          stx WSYNC
          .mva BACKGRND, # 0
          .mva CTRL, #CTRLDMADisable

          .BankSwitch # 1

          .mva CHARBASE, #>$8000

          .for p := 0, p < 7, p := p + 1
            .for c := 0, c < 3, c := c + 1
              lda $9001 + p * 3 + c
              sta P0C1 + p * 4 + c 
            .next
          .next

          .mva P7C1, PlayerSkinColor
          .mva P7C2, PlayerHairColor
          .mva P7C3, PlayerClothesColor

          stx WSYNC
          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB | CTRLCharWide

          stx WSYNC
          stx WSYNC
          .mva BACKGRND, $9000

          jsr FrameService

          lda Paused
          bmi WaitForOverscan

          jsr UserInput
          jsr MoveDecals
          jsr CheckPlayerCollision
          jsr CheckDecalCollision
          jsr FrameWork

WaitForOverscan:
          bit MSTAT
          bpl WaitForOverscan

          .BankSwitch # 0
          .mvaw NMINext, IBeginStats

          jmp ReturnFromInterrupt
          
          .bend
