;;; Phantasia Source/Routines/ScrollMap.s
;;; Copyright © 2022 Bruce-Robert Pocock

;;; There are 4 independent routines here for the 4 cardinal directions.

;;; 
ScrollMapRight:     .block
          lda MapWidth
          sec
          sbc # 20              ; width of screen
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
          .mvy MapLeftPixel, # 0
          inc MapLeftColumn

          .mvap Pointer, MapDLLStart

          ldx #$ff              ; so inx → 0 in the first loop iteration

CoarseScrollZone:
          inx                   ; zone relative to screen
          ldy # 1               ; find start of zone DL from the DLL
          lda (Pointer), y
          beq Return            ; end of DLL
          sta Pointer2 + 1
          iny
          lda (Pointer), y
          sta Pointer2

          bne CoarseScrollFirstStamp

Return:
          rts

CoarseScrollFirstStamp:
          ;; First one is always an indirect extended stamp
          ldy # 3
          lda (Pointer2), y     ; inverted width (& palette)
          and #$1f
          eor #$1f
          sec
          sbc # 1
          bmi EliminateFirstStamp

          eor #$1f
          sta Temp
          lda (Pointer2), y
          and #$e0
          ora Temp
          sta (Pointer2), y     ; width & palette value

          iny               ; Y = 4 = index of x position
          lda # 0
          sta (Pointer2), y

          ldy # 0               ; pointer to strings
          lda (Pointer2), y
          sta Source
          sta Dest
          ldy # 2
          lda (Pointer2), y
          sta Source + 1
          sta Dest + 1

          .Add16 Source, # 1

ScrollStrings:
          ldy # 0
ScrollStringsLoop:
          lda (Source), y
          sta (Dest), y
          iny
          cpy # 21              ; length of strings
          bne ScrollStringsLoop

FindNewTile:
          ;; Dest pointer is the start of strings space
          ;; Source pointer will be the index into the map
          lda MapTopRow         ; save real top
          pha
          txa
          clc
          adc MapTopRow         ; get relative position of this zone
          sta MapTopRow
          jsr FindMapSource     ; does not alter X nor Y
          pla
          sta MapTopRow

          ;; save the new tile to the end of the strings buffer
          lda MapLeftColumn
          clc
          adc # 20
          tay
          lda (Source), y       ; map tile byte
          sta Swap              ; $80 set means palette changed
          asl a                 ; needs to be ×2
          ldy # 20              ; last byte of string buffer
          sta (Dest), y

          .Add16 Pointer2, # 5
          jmp CoarseScrollOneZone

EliminateFirstStamp:
          lda Pointer2
          sta Dest
          sta Source
          lda Pointer2 + 1
          sta Dest + 1
          sta Source + 1
          .Add16 Source, # 5

ShiftNextHeader:
          ldy # 1
          lda (Source), y
          beq EndOfShiftingStamps

          and #$1f
          beq Shift5Bytes

Shift4Bytes:
          ldy # 0
-
          lda (Source), y
          sta (Dest), y
          iny
          cpy # 4
          bne -

          .Add16 Source, # 4
          .Add16 Dest, # 4
          jmp ShiftNextHeader

Shift5Bytes:
          ldy # 0
-
          lda (Source), y
          sta (Dest), y
          iny
          cpy # 5
          bne -

          .Add16 Source, # 5
          .Add16 Dest, # 5
          jmp ShiftNextHeader

EndOfShiftingStamps:

Zero5Bytes:
          ldy # 5
          lda # 0
-
          sta (Source), y
          dey
          bne -

          ;; Need to iterate the indirects, fix the last one, and then
          ;; iterate any direct stamps as well.
CoarseScrollOneZone:
          ldy # 1
          lda (Pointer2), y
          beq CoarseScrollLastAndDone

          ;; not the end of the drawing list, is it an indirect still?
          and #$7f              ; ignore write mode bit (only)
          cmp #$60              ; indirect mode and no width bits
          beq CoarseScrollOneIndirectStamp

          ;; must have run into direct mode stamps, process them next
          jsr CoarseScrollLastIndirect
          jmp CoarseScrollDirectStamps

CoarseScrollLastAndDone:
          ;; end of the list without running into any direct mode stamps
          ;; just fix up the last indirect and move on
          jsr CoarseScrollLastIndirect
          jmp CoarseScrollDone

CoarseScrollOneIndirectStamp:
          ldy # 4               ; x position
          lda (Pointer2), y
          sec
          sbc # 1
          sta (Pointer2), y

          ldy # 0               ; adjust string pointer
          lda (Pointer2), y
          sec
          sbc # 1
          sta (Pointer2), y
          bcs +
          ldy # 2               ; borrow from high byte
          lda (Pointer2), y
          sbc # 0               ; because carry is clear
          sta (Pointer2), y
+
          .Add16 Pointer2, # 5
          jmp CoarseScrollOneZone

CoarseScrollDirectStamps:
          ldy # 1
          lda (Pointer2), y
          beq CoarseScrollDone

          ldy # 4               ; x pos for extended header
          and #$1f
          beq ScrollStamp

          ldy # 3               ; x pos for short header
ScrollStamp:
          lda (Pointer2), y
          sec
          sbc # 1
          sta (Pointer2), y
          iny                   ; length of header
          tya
          .Add16a Pointer2
          jmp CoarseScrollDirectStamps

CoarseScrollDone:
          .Add16 Pointer, #3

          jmp CoarseScrollZone

CoarseScrollLastIndirect:
          ;; Pointer2 is pointing to the header AFTER the last indirect,
          ;; which may be a direct stamp heador or an end header.
          ;; We know an indirect is 5 bytes long, let's just use Source
          ;; for this one.
          .mvap Source, Pointer2
          .Sub16 Source, # 5

          ;; Did the palette change? If so, emit a new span; if not,
          ;; just extend the width of this one
          bit Swap
          bpl NoNewSpan
          bmi NoNewSpan         ; FIXME

AddNewSpan:
          ldy # 1               ; end of current header + 1
          lda (Pointer2), y       ; is there a span following?
          beq AddSpanNow

          brk                   ; FIXME: need to make room
          ;; TODO move over subsequent spans
          ;; TODO possible shift the entire subsequent set of drawing lists
          ;; if we ran out of space or sommat

AddSpanNow:
          ;; Source = last actual header
          ;; Pointer2 = space for new header

          ldy # 1
          lda #$60              ; wmode = 0, indirect, extended
          sta (Pointer2), y
          
          ldy # 3
          lda #$1f              ; width = 1 tile
          ;; FIXME, mark up palette correctly
          sta (Pointer2), y

          ldy # 3               ; width/palette
          lda (Source), y
          and #$1f
          eor #$1f
          sta Temp
          inc Temp
          ldy # 2               ; string pointer
          lda (Source), y
          sta (Pointer2), y
          ldy # 0
          lda (Source), y
          sta (Pointer2), y
          lda (Pointer2), y
          clc
          adc Temp
          sta (Pointer2), y
          bcc +
          ldy # 2
          lda (Pointer2), y
          adc # 0               ; carry is set
          sta (Pointer2), y
+

          lda Temp              ; width in words
          asl a
          asl a
          asl a                 ; width in pixels
          ldy # 4
          adc (Source), y
          sta (Pointer), y      ; x position

          rts

NoNewSpan:
          ldy # 3               ; width of span, inverted (and palette)
          lda (Source), y
          and #$1f
          eor #$1f
          clc
          adc # 1
          cmp #$20
          bge AddNewSpan

          eor #$1f
          sta Temp
          lda (Source), y
          and #$e0
          ora Temp
          sta (Source), y       ; width += 1, palette unchanged.

          rts
          .bend
;;; 
FindLastStamp:      .block
          ldy # 1
Loop:
          lda (Source), y
          beq FoundLastStamp

          and #$1f
          bne Skip4

          iny
Skip4:
          iny
          iny
          iny
          iny
          jmp Loop

FoundLastStamp:
          dey
          ;;  (Source),y points to the last byte before the last stamp
          rts

          .bend
