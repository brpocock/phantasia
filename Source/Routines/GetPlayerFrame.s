;;; Phantasia Source/Routines/GetPlayerFrame.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetPlayerFrame:     .block
          lda SpriteAction

          cmp #ActionIdle
          bne NotIdle
          ldx #PlayerIdle
          jmp CopyTile
          
NotIdle:
          ldx #PlayerFacingDown

SetFacing:          .macro stick, art
          .block
          lda SpriteFacing
          and #\stick
          beq NoArt
          ldx #\art
          bne SetSourceWalk
NoArt:
          .bend
          .endm

          .SetFacing P0StickDown, PlayerFacingDown
          .SetFacing P0StickLeft, PlayerFacingLeft
          .SetFacing P0StickRight, PlayerFacingRight
          .SetFacing P0StickUp, PlayerFacingUp

SetSourceWalk:
          lda AnimationFrame
          and # 4
          beq +
          inx
          inx
          inx
          inx
+

CopyTile:
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
