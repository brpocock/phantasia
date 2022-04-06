;;; Phantasia Source/Routines/GetTileAttributes.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetTileAttributes:  .block
          .mvaw Pointer, MapTileAttributes
          lda CheckY
          tax
          cpx # 0
-
          beq DoneMult
          .Add16 Pointer, MapWidth
          dex
          bne -
DoneMult:
          lda CheckX
          tay

          lda (Pointer), y
          asl a
          sta Temp
          asl a
          clc
          adc Temp
          tay

          rts
          .bend
