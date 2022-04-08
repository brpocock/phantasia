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
          beq +
          inx
          inx
          inx
          inx
+
          .mvaw Source, PlayerTiles
          txa
          .Add16a Source

          .mvaw Dest, AnimationBuffer + $1004
          jsr BlockCopy
          jmp AllReady

SetFrameForWalking:
          lda AnimationFrame
          and #$06
          lsr a
          tay
          lda SpriteFacing
          and #P0StickUp|P0StickDown
          beq +
          lda FramePatternUD, y
          jmp SetSourceFrame0

+
          lda FramePatternLR, y
SetSourceFrame0:
          ;; XXX handle not swinging the right arm when carrying a shield
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

          .mvaw Dest, AnimationBuffer + $1004
          jsr BlockCopy

          lda SpriteAction
          cmp #ActionWading
          bne DoneWading

WadingOverlay:
          lda AnimationFrame
          ldx # 0
          and #$01
          beq +
          ldx # 4
+
          jsr CopyStencil

DoneWading:
          lda CurrentShield
          beq AllReady

          cmp #ShieldSmall
          bne DoneSmallShield

          lda SpriteFacing
          and #P0StickDown | P0StickLeft | P0StickRight
          beq DoneShield
          .BitBit P0StickDown
          beq +
          ldx #$08 * 4
          gne ReadySmallShield
+
          .BitBit P0StickLeft
          beq +
          ldx #$09 * 4
          gne ReadySmallShield
+
          ldx #$0a * 4          ; must be facing right
          
ReadySmallShield:
          jsr CopyStencil

DoneSmallShield:
DoneShield:
          
AllReady:
          .mvaw Source, AnimationBuffer + $1004
          .mvaw Dest, AnimationBuffer + $1000
          jsr BlockCopy
Return:
          rts

BlockCopy:
          ldx # 16
BlockCopyLoop:
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
          bne BlockCopyLoop
          rts
;;; 
CopyStencil:
          .mvaw Source, PlayerEffectsTiles
          txa
          .Add16a Source

          .mvaw Dest, AnimationBuffer + $1004
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
;;; 
CopyMaskedByte:
          lda (Source), y
          beq Return

HasSomething:
          and #$cc
          beq RightOnly

HasLeft:
          lda (Source), y
          and #$33
          beq LeftOnly

HasBoth:
          lda (Source), y
          geq DoneMasked

LeftOnly:
          lda (Dest), y
          and #$cc
          ora (Source), y
          geq DoneMasked

RightOnly:
          lda (Dest), y
          and #$33
          ora (Source), y
DoneMasked:
          sta (Dest), y
          rts
;;; 
FramePatternLR:
          .byte 0, 2, 1, 3

FramePatternUD:
          .byte 0, 2, 1, 2

FramePatternRShield:
          .byte 1, 2, 1, 2

          .bend
