;;; Phantasia Source/Routines/GetPlayerFrame.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetPlayerFrame:     .block
          lda SpriteFacing
          ora #P0StickUp
          beq +
          ldx #PlayerFacingUp
          bne SetSource
+
          lda SpriteFacing
          ora #P0StickDown
          beq +
          ldx #PlayerFacingDown
          bne SetSource
+
          lda SpriteFacing
          ora #P0StickLeft
          beq +
          ldx #PlayerFacingLeft
          bne SetSource
+
          lda SpriteFacing
          ora #P0StickRight
          beq +
          ldx #PlayerFacingRight
          bne SetSource
+

SetSource:
          inx
          inx
          inx
          inx

          .mvaw Source, PlayerTiles
          txa
          .Add16a Source

          .mvaw Dest, AnimationBuffer + $1000
          ldx # 16
CopyPlayerSprite:
          ldy # 0
          .rept 3
            lda (Source), y
            sta (Dest), y
            iny
          .next
          lda (Source), y
          sta (Dest), y
          inc Source + 1
          inc Dest + 1
          dex
          bne CopyPlayerSprite

          rts

          .bend
