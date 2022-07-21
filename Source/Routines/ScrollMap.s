;;; Phantasia Source/Routines/ScrollMap.s
;;; Copyright © 2022 Bruce-Robert Pocock

;;; There are 4 independent routines here for the 4 cardinal directions.

;;; 
ScrollMapRight:     .block
          lda MapWidth
          sec
          sbc # 20
          cmp MapLeftColumn
          blt Return

          inc MapLeftPixel
          ldx MapLeftPixel
          cpx # 8
          bge CoarseScroll

FineScroll:
          .mvap Pointer, MapDLLStart

          lda MapLines
          .rept 4
            lsr a
          .next
          tax                   ; zones to update

FineScrollZone:
          ldy # 1
          lda (Pointer), y
          sta Pointer2 + 1
          iny
          lda (Pointer), y
          sta Pointer2

FineScrollStamp:
          ldy # 1
          lda (Pointer2), y
          beq FineScrollDone

          ldy # 4               ; x position on 5-byte header
          and #$1f              ; zeroes mean 5-byte header
          beq +
          dey                  ; x position on 4-byte header
+
          lda (Pointer2), y     ; x position
          sec
          sbc # 1
          sta (Pointer2), y

          iny
          tya                   ; length of header in bytes
          .Add16a Pointer2

          jmp FineScrollStamp

FineScrollDone:

          .Add16 Pointer, #3

          dex
          bne FineScrollZone

          rts

CoarseScroll:
          ldx # 0
          stx MapLeftPixel
          ldx MapLeftColumn
          inx
          stx MapLeftColumn

          .mvap Pointer, MapDLLStart

          lda MapLines
          .rept 4
            lsr a
          .next
          tax                   ; zones to update

CoarseScrollZone:
          ldy # 1
          lda (Pointer), y
          sta Pointer2 + 1
          iny
          lda (Pointer), y
          sta Pointer2

CoarseScrollStamp:
          ldy # 1
          lda (Pointer2), y
          beq CoarseScrollDone

          ldy # 4               ; x position on 5-byte header
          and #$1f              ; zeroes mean 5-byte header
          beq CoarseScroll5Bytes

CoarseScroll4Bytes:
          dey                  ; x position on 4-byte header
          lda (Pointer2), y
          sec
          sbc # 1
          bpl CoarseScroll4Done

CoarseScroll5Bytes:
          lda (Pointer2), y     ; x position
          clc
          adc # 8
          sta (Pointer2), y

          ldy # 4
          lda (Pointer2), y     ; pal/width
          and #$1f              ; width bits only
          ;; TODO subtract 1 from width
          ;; TODO add 1 to string pointer
          ;; TODO on underflow, move all following stamps left

          ;; TODO find the next tile for the last span
          ;; TODO figure out which one is the last span
          ;; TODO append to string if palette matches
          ;; TODO create new indirect header if new palette is needed
          lda # 5
          jmp CoarseScrollNext

CoarseScroll4Done:
          lda # 4

CoarseScrollNext:
          .Add16a Pointer2

          jmp CoarseScrollStamp

CoarseScrollDone:
          ;; TODO garbage-collect strings list

          .Add16 Pointer, #3

          dex
          bne CoarseScrollZone

Return:
          rts
          .bend
