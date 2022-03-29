;;; Phantasia Source/Routines/RLE.s
;;; Copyright © 2022 Bruce-Robert Pocock

RLE:      .block
          
          ldy # 0
          lda (Pointer), y
          sta Counter
          iny                   ; Y = 1
          lda (Pointer), y
          sta Counter + 1

          lda Pointer
          clc
          adc # 2
          bcc +
          inc Pointer + 1
+
          sta Pointer

          dey                   ; Y = 0

          lda (Pointer), y
          cmp #$ff
          bne Decompress

          ;; The data did not actually get compressed,
          ;; probably the “compressed” version would have been
          ;; longer than the original.
StraightCopy:
          lda (Pointer), y
          sta (Pointer2), y

          iny
          bne +

          inc Pointer + 1
          inc Pointer2 + 1

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
          lda (Pointer), y      ; length of run (OR) $80 = repeated
          bmi RepeatSegment

CopySegment:
          tax                   ; length of run (-1)

          ldy # 1
          jsr FlattenPointer

          txa                   ; length of run (-1)
          tay                   ; length of run (-1)
CopySegmentLoop:
          lda (Pointer), y
          sta (Pointer2), y

          dey

          bpl CopySegmentLoop

          txa                   ; length of run (-1)
          tay                   ; length of run (-1)
          iny
          jsr FlattenBothPointers
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
          jsr FlattenPointer

          lda (Pointer), y      ; repeat count (-1)
          pha                  ; repeat count (-1)

          iny                   ; Y = 1
          jsr FlattenPointer

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
          lda (Pointer), y
          sta (Pointer2), y

          iny                   ; index into run
          cpy Temp              ; length of run
          bne RepeatSegmentLoop

          dex                   ; repeat count
          beq RepeatedSegment

          lda Temp              ; length of run
          clc
          adc Pointer2
          bcc +
          inc Pointer2 + 1
+
          sta Pointer2

          jmp RepeatSegmentHead

RepeatedSegment:
          ldy Temp              ; length of run
          jsr FlattenBothPointers

          jmp DecompressNext

;;; 
FlattenBothPointers:
          tya
          clc
          adc Pointer2
          bcc +
          inc Pointer2 + 1
+
          sta Pointer2

FlattenPointer:
          tya
          clc
          adc Pointer
          bcc +
          inc Pointer + 1
+
          sta Pointer

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
