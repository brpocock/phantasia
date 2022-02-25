;;; InitialFantasy Source/Common/Macros.s
;;; Copyright © 2016,2017,2020-2022 Bruce-Robert Pocock (brpocock@star-hope.org)
;;;
;;;
Sleep:    .macro Cycles

          .if \Cycles < 0
          .error "Can't sleep back-in-time for ", \Cycles, " cycles"
          .else
          .switch \Cycles

          .case 0
          ;; sleep 0 = nothing

          .case 1
          .error "Cannot sleep 1 cycle (must be 2+)"

          .case 2
          nop

          .case 3
          nop $ea

          .case 4
          nop
          nop

          .case 5
          dec $2d

          .case 6
          nop $ea
          nop $ea

          .case 7
          dec $2d
          nop

          .case 8
          dec $2d
          nop $ea

          .case 9
          dec $2d
          nop
          nop

          .default
          .if 1 == \Cycles & 1
          ;; make sure we can't end up trying to sleep 1
          .Sleep 9
          .Sleep \Cycles - 9
          .else
          .Sleep 8
          .Sleep \Cycles - 8
          .fi
          .endswitch
          .fi
          .endm

          ;; Alternate sleep macro, which will use .x as a
          ;; countdown register. Exits with .x = 0
SleepX: .macro Cycles
          .block

          .if \Cycles < 10
          .Sleep \Cycles
          .else

          Loopable = \Cycles - 1
          .if (((* % $100) >= $fc) && ((* % $100) <= $fe))
          ;; going to cross page boundary on branch
          ;; so each loop takes 6 cycles instead of 5
          LoopCycles = Loopable / 6
          ModuloCycles = Loopable % 6 + 1
          .else                 ; no page cross
          LoopCycles = Loopable / 5
          ModuloCycles = Loopable % 5
          .fi

          .if ModuloCycles < 2
          .SleepX \Cycles - 2
          nop

          .else

          ldx #LoopCycles       ; 2
SleepLoop:
          dex                   ; 2
          bne SleepLoop         ; 2 (3+)
          ;; so overhead of +2 for ldx, -1 for no final branch
          ;; net overhead of +1, with 5 cycles per loop
          ;; if page boundary (dex occurs on $Xfd, $Xfe, $Xff)
          ;; then each loop is 6 cycles.
          .Sleep ModuloCycles

          .fi
          .fi

          .bend
          .endm

;;; 

Push16 .macro address
          lda \address +1
          pha
          lda \address
          pha
          .endm

Pull16 .macro address
          pla
          sta \address
          pla
          sta \address +1
          .endm

Mov16 .macro target, source
          lda \source
          sta \target
          lda \source + 1
          sta \target + 1
          .endm

Set16 .macro target, value
          lda #<(\value)
          sta \target
          lda #>(\value)
          sta \target + 1
          .endm         

;;; 

Locale .macro ThisLang, string
          .if \ThisLang == LANG
          .MiniText \string
          .fi
          .endm
;;; 
sound:    .macro volume, control, frequency, duration, end
          .switch FramesPerSecond
          .case 60
          .byte (\volume << 4) | \control, \frequency | ( \end << 7 ), \duration
          .case 50
          .byte (\volume << 4) | \control, \frequency | ( \end << 7 ), ceil( (\duration / 60.0) * 50)
          .default
          .error "Unsupported frame rate: ", FramesPerSecond
          .endswitch
          .endm
;;; 
KillMusic:          .macro
          lda # 0
          sta AUDC1
          sta AUDV1
          sta AUDF1
          sta NoteTimer
          .endm
;;; 
FarJSR:   .macro bank, service
          .proff
            .if \bank & $3f == BANK
              .error "Don't do FarJSR for the local bank for ", \service
            .fi
          .pron
          ldy #\service
          jsr JFarCall
          .endm

FarJMP:   .macro bank, service
          .proff
            .if \bank & $3f == BANK
              .error "Don't do FarJMP for the local bank for ", \service
            .fi
          .pron
          ldy #\service
          lda #\bank
          jmp JFarJump
          .endm
;;; 
SkipLines:          .macro length

          .if \length < 4

          .rept \length
          stx WSYNC
          .next

          .else

          ldx # \length
-
          stx WSYNC
          dex
          bne -

          .fi
          .endm
;;; 
BitBit:   .macro constant
          .switch \constant

          .case $01
          bit BitMask

          .case $02
          bit BitMask + 1

          .case $04
          bit BitMask + 2

          .case $08
          bit BitMask + 3

          .case $10
          bit BitMask + 4

          .case $20
          bit BitMask + 5

          .case $40
          bit BitMask + 6

          .case $80
          bit BitMask + 7

          .default
          .error "Constant is not a power-of-two bit value: ", \constant
          .endswitch
          .endm
;;; 
SetBitFlag:         .macro flag
          lda \flag
          lsr a
          lsr a
          lsr a
          tay
          lda \flag
          and #$07
          tax
          lda BitMask, x
          ora GameFlags, y
          sta GameFlags, y
          .endm

ClearBitFlag:       .macro flag
          lda \flag
          lsr a
          lsr a
          lsr a
          tay
          lda \flag
          and #$07
          tax
          lda BitMask, x
          eor #$ff
          and GameFlags, y
          sta GameFlags, y
          .endm
;;; 
;;; From Ryan Witmer / PhaserCat

mva:      .macro dest, src
          lda \src
          sta \dest
          .endm

mvay:     .macro dest, src
          lda \src
          sta \dest, y
          .endm

mvayi:     .macro dest, src
          lda \src
          sta \dest, y
          iny
          .endm

mvax:     .macro dest, src
          lda \src
          sta \dest, x
          .endm

mvaxd:     .macro dest, src
          lda \src
          sta \dest, x
          dex
          .endm

mvx:      .macro dest, src
          ldx \src
          stx \dest
          .endm

mvy:      .macro dest, src
          ldy \src
          sty \dest
          .endm

mvaw:     .macro dest, word
          lda #<\word
          sta \dest
          lda #>\word
          sta \dest
          .endm

mvap:     .macro dest, source
          lda \source
          sta \dest
          lda \source + 1
          sta \dest + 1
          .endm
;;; 
;;; From Lee Davison

between:  .macro low, high
          clc
          adc #$ff - \high
          adc #\high - \low + 1
          ;; C is set iff (low < A < high)
          .endm
;;; 
;;; 7800-specific stuff here

;;; Combine palette and (inverted) width values
DLPalWidth:         .function palette, width
          .endf ((palette << 5) | ($1f ^ ($1f & (width - 1))))

;;; Create an extended header with the specific write mode and indirect mode bits
DLExtMode:   .function wmodep, indirectp
          .endf ((wmodep ? $80 : 0) | $40 | (indirectp ? $20 : 0))

DLHeader: .macro address, palette, width, xpos
          ;; address, palette/width, address, xpos
          .byte <\address, DLPalWidth(\palette, \width), >\address, \xpos
          .endm

DLExtHeader:       .macro address, palette, width, xpos, wmodep, indirectp
          ;; address, write mode/indirect, address
          .byte <\address, DLExtMode(\wmodep, \indirectp), >\address
          ;; palette/width, xpos
          .byte DLPalWidth(\palette, \width), \xpos
          .endm
          
;;; Combine base color and luminance. By using COL* constants these should
;;; translate OK to PAL colors as well.
CoLu:     .function color, lum
          .endf (color | lum)

BankSwitch:         .macro bank
          lda \bank
          sta $8001             ; bank switch “register”
          .endm

WaitForVBlank:      .macro
          .block
Wait0:
          bit MSTAT
          bmi Wait0
Wait1:
          bit MSTAT
          bpl Wait1
          .bend
          .endm

