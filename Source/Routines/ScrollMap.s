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
;;; 
FineScroll:
          .mvap DLLTail, MapDLLStart

          ldx #$ff

FineScrollZone:
          inx
          ldy # 1
          lda (DLLTail), y
          beq Return

          sta DLTail + 1
          iny
          lda (DLLTail), y
          sta DLTail

FineScrollStamp:
          ldy # 1
          lda (DLTail), y
          beq FineScrollDone

          ldy # 4               ; x position on 5-byte header
          and #$1f              ; zeroes mean 5-byte header
          beq +
          dey                  ; x position on 4-byte header
+
          lda (DLTail), y     ; x position
          sec
          sbc # 1
          sta (DLTail), y

          iny
          tya                   ; length of header in bytes
          .Add16a DLTail

          jmp FineScrollStamp

FineScrollDone:
          .Add16 DLLTail, #3

          jmp FineScrollZone

Return:
          rts
;;; 
CoarseScroll:
          .mvy MapLeftPixel, # 0
          inc MapLeftColumn

          .mvap DLLTail, MapDLLStart

ScrollStrings:
          ldx # 12              ; FIXME number of map rows

          .mvaw Source, $2501   ; FIXME is this really constant?
          .mvaw Dest, $2500
ScrollStringsOuterLoop:
          ldy # 0
ScrollStringsLoop:
          lda (Source), y
          sta (Dest), y
          iny
          cpy # 21              ; length of strings
          bne ScrollStringsLoop

          .Add16 Source, # 21
          .Add16 Dest, # 21
          dex
          bne ScrollStringsOuterLoop

          ldx #$ff              ; so inx → 0 in the first loop iteration

CoarseScrollZone:
          inx                   ; zone relative to screen
          ldy # 1               ; find start of zone DL from the DLL
          lda (DLLTail), y
          beq Return            ; end of DLL

          sta DLTail + 1
          iny
          lda (DLLTail), y
          sta DLTail

CoarseScrollFirstStamp:
          ;; First one is always an indirect extended stamp
          ldy # 3
          lda (DLTail), y     ; inverted width (& palette)
          and #$1f
          eor #$1f
          sec
          sbc # 1
          bmi EliminateFirstStamp

          eor #$1f
          sta Temp
          lda (DLTail), y
          and #$e0
          ora Temp
          sta (DLTail), y     ; width & palette value

          iny               ; Y = 4 = index of x position
          lda # 0
          sta (DLTail), y

          ldy # 0               ; pointer to strings
          lda (DLTail), y
          sta StringsTail
          ldy # 2
          lda (DLTail), y
          sta StringsTail + 1

          .Add16 StringsTail, # 20

          jsr FindNewTile

          ;; Need to iterate the indirects, fix the last one, and then
          ;; iterate any direct stamps as well.
CoarseScrollOneZone:
          ldy # 1
          lda (DLTail), y
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
;;; 
EliminateFirstStamp:
          lda DLTail
          sta Dest
          sta Source
          lda DLTail + 1
          sta Dest + 1
          sta Source + 1
          .Add16 Source, # 5

ShiftNextHeader:
          ldy # 1
          lda (Source), y
          beq EndOfShiftingStamps

          sta (Source), y
          and #$1f
          bne Shift4Bytes

Shift5Bytes:
          lda (Source), y
          and #$20             ; indirect mode?
          beq Shift5Direct

          dey                   ; Y = 0
          lda (Source), y       ; fix string pointer
          sec
          sbc # 1
          sta (Source), y
          ldy # 2
          lda (Source), y
          sbc # 0               ; carry from prior SBC
          sta (Source), y

Shift5Common:
          ldy # 3               ; palette & width
          lda (Source), y
          sta (Dest), y

          iny                   ; Y = 4, x position
          lda (Source), y
          sec
          sbc # 1
          sta (Dest), y

          .Add16 Source, # 5
          .Add16 Dest, # 5
          jmp ShiftNextHeader

Shift5Direct:
          dey                   ; Y = 0, pointer low byte
          lda (Source), y
          sta (Source), y
          ldy # 2               ; pointer high byte
          lda (Source), y
          sta (Source), y
          jmp Shift5Common

Shift4Bytes:
-
          lda (Source), y
          sta (Dest), y
          iny
          cpy # 3
          bne -

          lda (Source), y
          sec
          sbc # 1
          sta (Dest), y

          .Add16 Source, # 4
          .Add16 Dest, # 4
          jmp ShiftNextHeader

EndOfShiftingStamps:

Zero5Bytes:
          ldy # 5
          lda # 0
-
          sta (Dest), y
          dey
          bne -

          jsr FindNewTile
          jmp CoarseScrollDone
;;; 
CoarseScrollOneIndirectStamp:
          ldy # 4               ; x position
          lda (DLTail), y
          sec
          sbc # 1
          sta (DLTail), y

          ldy # 0               ; adjust string pointer
          lda (DLTail), y
          sec
          sbc # 1
          sta (DLTail), y
          bcs +
          ldy # 2               ; borrow from high byte
          lda (DLTail), y
          sbc # 0               ; because carry is clear
          sta (DLTail), y
+
          .Add16 DLTail, # 5
          jmp CoarseScrollOneZone

CoarseScrollDirectStamps:
          ldy # 1
          lda (DLTail), y
          beq CoarseScrollDone

          ldy # 4               ; x pos for extended header
          and #$1f
          beq ScrollStamp       ; is an extended header

          ldy # 3               ; x pos for short header
ScrollStamp:
          lda (DLTail), y
          sec
          sbc # 1
          sta (DLTail), y
          iny                   ; length of header = x pos + 1
          tya
          .Add16a DLTail
          jmp CoarseScrollDirectStamps

CoarseScrollDone:
          .Add16 DLLTail, #3

          jmp CoarseScrollZone

CoarseScrollLastIndirect:
          ;; DLTail is pointing to the header AFTER the last indirect,
          ;; which may be a direct stamp heador or an end header.
          ;; We know an indirect is 5 bytes long, let's just use Source
          ;; for this one.
          .mvap Source, DLTail
          .Sub16 Source, # 5

          ;; Did the palette change? If so, emit a new span; if not,
          ;; just extend the width of this one
          bit Swap
          bpl NoNewSpan
          bmi NoNewSpan         ; FIXME

AddNewSpan:
          ldy # 1               ; end of current header + 1
          lda (DLTail), y       ; is there a span following?
          beq AddSpanNow

          brk                   ; FIXME: need to make room
          ;; TODO move over subsequent spans
          ;; TODO possible shift the entire subsequent set of drawing lists
          ;; if we ran out of space or sommat

AddSpanNow:
          ;; Source = last actual header
          ;; DLTail = space for new header

          ldy # 1
          lda #$60              ; wmode = 0, indirect, extended
          sta (DLTail), y

          ldy # 3
          lda #$1f              ; width = 1 tile
          ;; FIXME, mark up palette correctly
          sta (DLTail), y

          ldy # 3               ; width/palette
          lda (Source), y
          and #$1f
          eor #$1f
          sta Temp
          inc Temp
          ldy # 2               ; string pointer
          lda (Source), y
          sta (DLTail), y
          ldy # 0
          lda (Source), y
          sta (DLTail), y
          lda (DLTail), y
          clc
          adc Temp
          sta (DLTail), y
          bcc +
          ldy # 2
          lda (DLTail), y
          adc # 0               ; carry is set
          sta (DLTail), y
+

          lda Temp              ; width in words
          asl a
          asl a
          asl a                 ; width in pixels
          ldy # 4
          adc (Source), y
          sta (DLLTail), y      ; x position

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
;;; 
FindNewTile:        .block
          ;; StringsTail pointer is the end of strings space
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
          ldy # 0               ; last byte of string buffer
          sta (StringsTail), y

          .Add16 DLTail, # 5

          rts
          .bend
          
