;;; Phantasia Source/Routines/UpdateSprites.s
;;; Copyright © 2022 Bruce-Robert Pocock

UpdateSprites:
          ldy # 0
ClearSpritesFromDLs:
          lda MapRowEndL, y
          sta Pointer
          lda MapRowEndH, y
          sta Pointer + 1
          iny
          sty Swap              ; map row being cleared

          ldy # 0
          tya
          sta (Pointer), y
          iny
          sta (Pointer), y

          ldy Swap              ; map row being cleared
          cpy # NumMapRows
          bne ClearSpritesFromDLs

          ldx NumSprites
          beq DoneUpdatingSprites

AddOneSprite:
          ldy MapSpritesYH
          lda MapRowEndL, y
          sta Pointer
          lda MapRowEndH, y
          sta Pointer + 1
          ldy # 0
FindSpriteBlanks:
          lda (Pointer), y
          bne NotFoundSpriteBlanks
          iny
          lda (Pointer), y
          bne NotFound2
          geq FoundSpriteBlanks

NotFoundSpriteBlanks:
          iny
NotFound2:
          iny
          iny
          iny
          iny
          gne FindSpriteBlanks

FoundSpriteBlanks:
          .mvapyi Pointer, #<AnimationBuffer
          .mvapyi Pointer, #DLExtMode(true, false)
          .mvapyi Pointer, #>AnimationBuffer
          .mvapyi Pointer, #DLPalWidth(1, 4)
          .mvapyi Pointer, MapSpritesXL

          dex
          bne AddOneSprite

DoneUpdatingSprites:
          rts
