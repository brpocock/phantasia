;;; Phantasia Source/Routines/GetPlayerFrame.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetPlayerFrame:     .block
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
          lda SpriteAction
          ;; cmp #ActionIdle ; unnecessary, it's zero
          bne NotIdle
          ldy # 2
          jmp SetSourceFrame

NotIdle:
          lda AnimationFrame
          and #$06
          lsr a
          tay
          lda FramePattern, y
          tay
SetSourceFrame:
          cpy # 0
          beq CopyTile
-
          inx
          inx
          inx
          inx
          dey
          bne -

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

FramePattern:
          .byte 0, 2, 1, 2

          .bend
