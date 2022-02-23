;;; Phantasia Source/Routines/ColdStart.s
;;;; Copyright © 2022 Bruce-Robert Pocock

ColdStart:	.block
          sei
          cld

          .mva INPTCTRL, #$17   ; set to 7800 mode
          .mva CTRL, #$7f       ; disable DMA
          ldx # 0
          stx OFFSET
          stx INPTCTRL
          dex                   ; X = $ff
          txs                   ; clear stack

ZeroRAM:

	ldx #$40
	lda # 0
ZeroLowMemory:
	sta $00, x
	sta $100,x
	inx
	bne ZeroLowMemory

          ldy # 0
ZeroSysRAMLow:

          ;; $1800-$19ff
          lda # 0
ZSRL:
          sta $1800, y
          sta $1900, y
          iny
          bne ZSRL

          ;; $2000-$203f and $2200-$223f
          ldy #$3f
ZSRL2:
          sta $2000, y
          sta $2200, y
          dey
          bpl ZSRL2

          .mva Pointer+1, #$22
          lda # 0
          tay
          ldx # 6               ; pages to clear: $2200-$27ff = 6pp
ZeroSysRAMHigh:
          sta (Pointer), y
          iny
          bne ZeroSysRAMHigh
          inc Pointer + 1
          dex
          bne ZeroSysRAMHigh
          
          .mva Pointer+1, $40
          txa                   ; A ← 0
          ldx #$20              ; pages to clear
ZeroCartRAM:
          sta (Pointer), y
          iny
          bne ZeroCartRAM
          inc Pointer + 1
          dex
          bne ZeroCartRAM

          ;; All RAM is finally cleared now! that was a long time.
          ;; Let's turn things on now.
          ;; Fall through to WarmStart.

          .bend
