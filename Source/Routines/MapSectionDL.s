;;; Phantasia Source/Routines/MapSectionDL.s
;;; Copyright © 2022 Bruce-Robert Pocock

MapSectionDL:       .block
          lda MapLines
          cmp #$10
          bge +

          rts

+
          ldy # 0
          .mvapyi DLLTail, # 2 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL
          .mvapyi DLLTail, # 1
          .mvapyi DLLTail, #>BlankDL
          .mvapy DLLTail, #<BlankDL
          .Add16 DLLTail, # 3

DrawMapSection:
          .mvap MapDLLStart, DLLTail

          lda MapTopRow
          sta MapNextY

          ldy # 0
          sty ScreenNextY

          lda #<MapArt
          sta Source
          lda #>MapArt
          sta Source + 1

          ;; multiply row × 32 and add to Source pointer
          lda MapTopRow
          asl a
          asl a
          asl a
          bcc +
          inc Source + 1
+
          asl a
          bcc +
          inc Source + 1
          clc
+
          adc Source
          sta Source

          ldy # 0
          jsr LookUpPalette

MoreMapRows:
          ldy # 0
          .mvapyi DLLTail, # 15 | DLLHoley16
          .mvapyi DLLTail, DLTail + 1
          .mvapyi DLLTail, DLTail

          tya
          .Add16a DLLTail

          .mvy Swap, MapLeftColumn
          .mvx SpanWidth, # 0
          .mvap Pointer, StringsTail
          .mva MapNextX, MapLeftPixel
CopyTileSpan:
          lda SpanWidth
          cmp #$1f              ; is this string getting too long for one draw?
          bge EmitSpanMidLine
          
          ldy Swap              ; current column of source
          lda (Source), y
          bpl PaletteOK

          lda SpanWidth
          beq DoneEmittingSpan

EmitSpanMidLine:
          ;; Palette changed, what was it, what will it be?
          jsr EmitSpan

          ;; update left of next span
          lda SpanWidth
          asl a
          asl a
          asl a
          clc
          adc MapNextX
          sta MapNextX

          .mva SpanWidth, # 0

          .Add16 DLTail, # 5

          ldy Swap              ; column in source
DoneEmittingSpan:

ReadNextPalette:
          jsr LookUpPalette

          ldy Swap              ; column in source
          lda (Source), y
PaletteOK:
          asl a                 ; tile byte address
          ldy # 0
          sta (StringsTail), y
          inc Swap              ; column in map source
          inc SpanWidth

          .Add16 StringsTail, # 1
          inx
          cpx # 21
          blt CopyTileSpan

EmitFinalSpan:
          jsr EmitSpan

          .Add16 DLTail, # 5
SaveMapEnd:
          ldy ScreenNextY
          lda DLTail
          sta MapRowEndL, y
          lda DLTail + 1
          sta MapRowEndH, y

          ldy # 0

          lda # 0
          ldx #$12              ; room for stamps + terminal $0000
FillSpanZeroes:
          sta (DLTail), y
          iny
          dex
          bne FillSpanZeroes

          tya
          .Add16a DLTail

          .Add16 Source, MapWidth
          inc ScreenNextY
          lda ScreenNextY
          asl a                 ; 16 lines per row
          asl a
          asl a
          asl a
          cmp MapLines
          blt +

          rts
+
          ldy # 0
          jsr LookUpPalette
          jmp MoreMapRows

          .bend
