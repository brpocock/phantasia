;;; Phantasia Source/Routines/LookUpPalette.s
;;; Copyright © 2022 Bruce-Robert Pocock

LookUpPalette:      .block
          ;; Look up the palette
          ;; Source is exactly 1kiB below the place we want
          .mva Dest, Source
          lda Source + 1
          clc
          adc # 4
          sta Dest + 1

          lda (Dest), y
          ;; got the attribute indirect ID, multiply by 6
          asl a
          sta Dest              ; temp
          asl a
          clc
          adc Dest              ; temp
          ;; index into attributes table + 4 bytes to get palette ID
          tay
          lda MapAttributes + 4, y
          and #$e0
          sta SelectedPalette

          rts
          .bend
