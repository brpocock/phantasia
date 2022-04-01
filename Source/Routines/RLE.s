;;; Phantasia Source/Routines/RLE.s
;;; Copyright © 2022 Bruce-Robert Pocock

RLE:      .block
          
          ldy # 0
          lda (Source), y
          sta Counter
          iny                   ; Y = 1
          lda (Source), y
          sta Counter + 1

          lda Source
          clc
          adc # 2
          bcc +
          inc Source + 1
+
          sta Source

          dey                   ; Y = 0

          lda (Source), y
          cmp #$ff
          bne Decompress

          ;; The data did not actually get compressed,
          ;; probably the “compressed” version would have been
          ;; longer than the original.
StraightCopy:
          lda (Source), y
          sta (Dest), y

          iny
          bne +

          inc Source + 1
          inc Dest + 1

+
          lda Counter
          bne +
          dec Counter + 1
+
          dec Counter

          lda Counter
          bne StraightCopy
          lda Counter + 1
          bne StraightCopy

          rts

Decompress:
          lda (Source), y      ; length of run (OR) $80 = repeated
          bmi RepeatSegment

CopySegment:
          tax                   ; length of run (-1)

          ldy # 1
          jsr FlattenSource

          txa                   ; length of run (-1)
          tay                   ; length of run (-1)
CopySegmentLoop:
          lda (Source), y
          sta (Dest), y

          dey

          bpl CopySegmentLoop

          txa                   ; length of run (-1)
          tay                   ; length of run (-1)
          iny
          jsr FlattenBothSources
          ;; fall through
;;; 
DecompressNext:
          lda Counter
          bne Decompress
          lda Counter + 1
          bne Decompress

          rts
;;; 
          
RepeatSegment:
          and #$7f
          tax                   ; length of run (-1)

          iny                   ; Y = 1
          jsr FlattenSource

          lda (Source), y      ; repeat count (-1)
          pha                  ; repeat count (-1)

          iny                   ; Y = 1
          jsr FlattenSource

          txa                   ; length of run (-1)
          tay                   ; length of run (-1)

          pla                   ; repeat count (-1)
          tax                   ; repeat count (-1)
          inx                   ; repeat count

          iny                   ; length of run
          sty Temp              ; length of run

RepeatSegmentHead:
          ldy # 0               ; index into run
RepeatSegmentLoop:
          lda (Source), y
          sta (Dest), y

          iny                   ; index into run
          cpy Temp              ; length of run
          bne RepeatSegmentLoop

          dex                   ; repeat count
          beq RepeatedSegment

          lda Temp              ; length of run
          clc
          adc Dest
          bcc +
          inc Dest + 1
+
          sta Dest

          jmp RepeatSegmentHead

RepeatedSegment:
          ldy Temp              ; length of run
          jsr FlattenBothSources

          jmp DecompressNext

;;; 
FlattenBothSources:
          tya
          clc
          adc Dest
          bcc +
          inc Dest + 1
+
          sta Dest

FlattenSource:
          tya
          clc
          adc Source
          bcc +
          inc Source + 1
+
          sta Source

          sty Temp
          lda Counter
          sec
          sbc Temp
          bcs +
          dec Counter + 1
+
          sta Counter

          ldy # 0

          rts
          
          .bend

;;; Tested and known to work 2022-03-29 BRPocock
