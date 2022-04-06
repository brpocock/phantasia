;;; Phantasia Source/Routines/CheckWall.s
;;; Copyright © 2022 Bruce-Robert Pocock

CheckWall:          .block
          ;; Sprite index in X
          ;; Returns carry clear if no wall or ignore wall

          lda SpriteAction, x
          cmp #ActionFlying
          beq IsOK

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
          lda MapAttributes, y
          and CheckMask
          beq IsOK

IsWall:
          sec
          rts
IsOK:
          clc
          rts

          .bend
