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
          cmp #ActionWalking
          beq SetFrameForWalking
          cmp #ActionWading
          beq SetFrameForWalking
          cmp #ActionSwimming
          beq SetFrameForSwimming
          cmp #ActionUseEquipment
          beq SetFrameForUsingEquipment
          cmp #ActionClimbing
          beq SetFrameForClimbing
          ;; fall through to walking for now XXX
          jmp SetFrameForWalking

SetFrameForClimbing:
          lda AnimationFrame
          and #$03
          asl a
          asl a
          clc
          adc # 4 * 4
          tax
          gne CopyTile

SetFrameForUsingEquipment:
          ;; XXX TODO
          jmp CopyTile

SetFrameForSwimming:
          txa
          sec
          sbc # 4 * 8 * 4
          tax
          lda AnimationFrame
          and #$04
          beq CopyTile
          inx
          inx
          inx
          inx
          gne CopyTile

SetFrameForWalking:
          lda AnimationFrame
          and #$06
          lsr a
          tay
          lda SpriteFacing
          and #P0StickUp|P0StickDown
          beq +
          lda FramePatternUD, y
          tay
          jmp SetSourceFrame

+
          lda FramePatternLR, y
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

          lda SpriteAction
          cmp #ActionWading
          bne Return

WadingOverlay:
          lda AnimationFrame
          ldx # 0
          and #$01
          beq +
          inx
+
          jsr CopyStencil

Return:
          rts

CopyStencil:
          .mvaw Source, PlayerEffectsTiles
          txa
          .Add16a Source

          .mvaw Dest, AnimationBuffer + $1000
          ldx # 16
CopyStencilLoop:
          ldy # 0
          .rept 3
            jsr CopyMaskedByte
            iny
          .next
          jsr CopyMaskedByte
          inc Source + 1
          inc Dest + 1
          dex
          bne CopyStencilLoop

          rts

CopyMaskedByte:
          lda (Source), y
          beq Return

          and #$f0
          beq NoLeft

          lda (Source), y
          and #$0f
          beq LeftOnly

          ;; Left and right both have pixels
          sta (Dest), y
          rts

LeftOnly:
          ;; only set the left pixel
          lda (Dest), y
          and #$0f
          ora (Source), y
          sta (Dest), y
          rts

NoLeft:
          ;; only set the right pixel
          lda (Dest), y
          and #$f0
          ora (Source), y
          sta (Dest), y
          rts

FramePatternLR:
          .byte 0, 2, 1, 3

FramePatternUD:
          .byte 0, 2, 1, 2

          .bend
