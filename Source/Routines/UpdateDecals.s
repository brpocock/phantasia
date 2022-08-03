;;; Phantasia Source/Routines/UpdateDecals.s
;;; Copyright © 2022 Bruce-Robert Pocock

UpdateDecals:      .block
          ldy # 0
ClearDecalsFromDLs:
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
          bne ClearDecalsFromDLs

          ldx NumDecals
          beq DoneUpdatingDecals

AddOneDecal:
          lda DecalYH
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
          adc DecalYL
          sta (Pointer), y
          iny
          .mvapyi Pointer, #DLPalWidth(4, 4)
          lda DecalXH
          sec
          sbc MapLeftColumn
          asl a
          asl a
          asl a
          clc
          adc DecalXL
          sec
          sbc MapLeftPixel
          sta (Pointer), y

          lda DecalYL
          beq DonePlayer

          lda DecalYH
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
          adc DecalYL
          sta (Pointer), y
          iny
          .mvapyi Pointer, #DLPalWidth(4, 4)
          lda DecalXH
          sec
          sbc MapLeftColumn
          asl a
          asl a
          asl a
          clc
          adc DecalXL
          sec
          sbc MapLeftPixel
          sta (Pointer), y
          

DonePlayer:
          dex
          bne AddOneDecal

DoneUpdatingDecals:
          rts

FindBlankOnRow:
          ;; row in Y, returns pointer in Pointer and Y
          lda MapRowEndL, y
          sta Pointer
          lda MapRowEndH, y
          sta Pointer + 1
          ldy # 0
FindDecalBlanks:
          lda (Pointer), y
          bne NotFoundDecalBlanks

          iny
          lda (Pointer), y
          bne NotFound2

          geq FoundDecalBlanks

NotFoundDecalBlanks:
          iny
NotFound2:
          iny
          iny
          iny
          iny
          jmp FindDecalBlanks

FoundDecalBlanks:
          dey
          .mva DecalDLL, Pointer
          .mva DecalDLH, Pointer + 1
          rts

          .bend
