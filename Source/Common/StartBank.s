;;; Phantasia Source/Common/StartBank.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          .enc "Unicode"
          .cdef $00, $1ffff, 0
          
          .include "7800.s"
          .include "Math.s"
          .include "Macros.s"
          .include "Enums.s"
          .include "Constants.s"
          .include "JumpTable.s"

          .include "ZeroPage.s"
          .include "RIOTRAM.s"
          .include "SysRAM.s"
          .include "CartRAM.s"

          .weak
            DEMO=false
            PUBLISHER=false
          .endweak


	.enc "minifont"
	.cdef "09", 0
	.cdef "az", $0a
	.cdef "AZ", $0a
	.cdef "  ", $24
	.cdef ",,", $25
	.cdef "..", $26
	.cdef "??", $27
	.cdef "!!", $28
	.cdef "//", $29
	.cdef "&&", $2a
	.cdef "++", $2b
	.cdef "--", $2c
	.cdef "××", $2d
	.cdef "÷÷", $2e
	.cdef "==", $2f
	.cdef "““", $30
	.cdef "””", $31
	.cdef "’’", $32
	.cdef "''", $32
	.cdef "::", $33
	.cdef ";;", $34
          .cdef "……", $35       ; actually only the first two dots, follow with a .
          ;; …
	.cdef "©©", $3a
	.cdef "••", $3b
	.cdef "↑↑", $3c
	.cdef "↓↓", $3d
	.cdef "←←", $3e
	.cdef "→→", $3f

          .enc "Unicode"

bigptext:  .macro string
          .byte len(\string)
          .for i := 0, i < len(\string), i += 1
          .byte \string[i] * 2
          .next
          .endm
          
Pack6:   .macro byteA, byteB, byteC, byteD
          .byte ((\byteA & $3f) << 2) | ((\byteB & $30) >> 4)
          .byte ((\byteB & $0f) << 4) | ((\byteC & $3c) >> 2)
          .byte ((\byteC & $03) << 6) | (\byteD & $3f)
          .endm

          
          * = $8000
          .offs -$8000
