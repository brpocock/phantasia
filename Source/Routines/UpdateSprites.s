;;; Phantasia Source/Routines/UpdateSprites.s
;;; Copyright © 2022 Bruce-Robert Pocock

UpdateSprites:      .block
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
          cpy #NumMapRows
          bne ClearSpritesFromDLs

          ldx NumSprites
          beq DoneUpdatingSprites

AddOneSprite:
          lda SpriteYH
          sec
          sbc MapTopRow
          bmi DonePlayer

          cmp #NumMapRows
          bge DonePlayer

          tay
          jsr FindBlankOnRow
          .mvaw Source, AnimationBuffer + $1000
          .mvapyi Pointer, Source
          .mvapyi Pointer, #DLExtMode(true, false)
          lda Source + 1
          clc
          adc SpriteYL
          sta (Pointer), y
          iny
          .mvapyi Pointer, #DLPalWidth(4, 4)
          lda SpriteXH
          sec
          sbc MapLeftColumn
          asl a
          asl a
          asl a
          clc
          adc SpriteXL
          sec
          sbc MapLeftPixel
          sta (Pointer), y

          lda SpriteYL
          beq DonePlayer

          lda SpriteYH
          sec
          sbc MapTopRow
          tay
          iny

          cpy #NumMapRows
          bge DonePlayer

          jsr FindBlankOnRow
          .mvaw Source, AnimationBuffer
          .mvapyi Pointer, Source
          .mvapyi Pointer, #DLExtMode(true, false)
          lda Source + 1
          clc
          adc SpriteYL
          sta (Pointer), y
          iny
          .mvapyi Pointer, #DLPalWidth(4, 4)
          lda SpriteXH
          sec
          sbc MapLeftColumn
          asl a
          asl a
          asl a
          clc
          adc SpriteXL
          sec
          sbc MapLeftPixel
          sta (Pointer), y
          

DonePlayer:
          dex
          bne AddOneSprite

DoneUpdatingSprites:
          rts

FindBlankOnRow:
          ;; row in Y, returns pointer in Pointer and Y
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
          jmp FindSpriteBlanks

FoundSpriteBlanks:
          dey
          .mva SpriteDLL, Pointer
          .mva SpriteDLH, Pointer + 1
          rts

          .bend
