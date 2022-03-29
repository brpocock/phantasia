;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"

BankEntry:

          .mva NMINext, 0
          .WaitForVBlank
          .mva CTRL, #CTRLDMADisable

          ;; Decompress map tile data
          ;; TODO the source pointer should come from Map_Atsirav + 2, 3
          .mvaw Pointer, Map_Atsirav.Art
          .mvaw Pointer2, MapArt
          jsr RLE

          ;; Decompress pointers to map attribute data
          ;; TODO the source pointer should come from Map_Atsirav + 4, 5
          .mvaw Pointer, Map_Atsirav.TileAttributes
          .mvaw Pointer2, MapTileAttributes
          jsr RLE

          ;; Back to setting up the screen

          .mvaw NMINext, BeginTopBar
          .mva BACKGRND, #CoLu(COLYELLOW, $f)

          DLL = SysRAMHigh

          ldy # 0

          .mvayi DLL, # 11
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

TopBarDLL:
          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>TopBarDL1
          .mvayi DLL, #<TopBarDL1

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>TopBarDL2
          .mvayi DLL, #<TopBarDL2

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>TopBarDL3
          .mvayi DLL, #<TopBarDL3

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>TopBarDL4
          .mvayi DLL, #<TopBarDL4

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL1
          .mvayi DLL, #<DialogueDL1

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL2
          .mvayi DLL, #<DialogueDL2

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL3
          .mvayi DLL, #<DialogueDL3

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL4
          .mvayi DLL, #<DialogueDL4

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL5
          .mvayi DLL, #<DialogueDL5

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL6
          .mvayi DLL, #<DialogueDL6

          .mvayi DLL, # 15 | DLLDLI
          .mvayi DLL, #>MapFillDL
          .mvayi DLL, #<MapFillDL

          ldx # 8
MapFillDLL:
          .mvayi DLL, # 15
          .mvayi DLL, #>MapFillDL
          .mvayi DLL, #<MapFillDL

          dex
          bne MapFillDLL

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 11
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 12
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mva P0C2, #CoLu(COLGRAY, $9)
          .mva P1C2, #CoLu(COLGRAY, $b)
          .mva P2C2, #CoLu(COLGRAY, $f)
          .mva P3C2, #CoLu(COLGRAY, $d)

          .mva P4C2, #CoLu(COLGRAY, $c)
          .mva P5C2, #CoLu(COLBLUE, $4)
          .mva P6C2, #CoLu(COLBROWN, $4)
          .mva P7C2, #CoLu(COLORANGE, $8)

          .WaitForVBlank
          .mva CTRL, #CTRLDMAEnable

Loop:
          jmp Loop
;;; 
BeginTopBar:
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mva P2C2, #CoLu(COLGRAY, $f)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>Font
          .mvaw NMINext, EndTopBar
          rti

EndTopBar:
          stx WSYNC
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGRAY, $c)
          .mva P2C2, #CoLu(COLGRAY, $0)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>Font
          .mvaw NMINext, EndDialogue
          rti

EndDialogue:
          stx WSYNC
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGREEN, $8)
          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mva CHARBASE, #>Tileset
          .mvaw NMINext, SwitchToOverscan
          rti

SwitchToOverscan:
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mvaw NMINext, BeginTopBar
          rti
;;; 
          .enc "minifont"
LocationNameString: .ptext "locale name here"

Dialogue2Text:      .ptext "hello, world."
Dialogue3Text:      .ptext "this is a test"
Dialogue4Text:      .ptext "this is only a test"

MapFillDL:
          .DLEnd

TopBarDL1:
          .DLAltHeader DrawUI + $00, 0, 4, $04
          .DLAltHeader DrawUI + $02, 0, 4, $0c

          .DLStringHeader LocationNameString, 2, $60

          .DLAltHeader DrawUI + $00, 0, 4, $18
          .DLAltHeader DrawUI + $02, 0, 4, $20

BlankDL:
          .DLEnd

TopBarDL2:
          .DLAltHeader DrawUI + $10, 0, 2, $04
          .DLAltHeader DrawUI + $14, 0, 2, $10

          .DLAltHeader Items + $00 * 2, 4, 4, $08

          .DLAltHeader DrawUI + $10, 0, 2, $18
          .DLAltHeader DrawUI + $14, 0, 2, $24

          .DLAltHeader Items + $02 * 2, 4, 4, $1c

          .DLEnd

TopBarDL3:
          .DLAltHeader DrawUI + $10, 0, 2, $04
          .DLAltHeader DrawUI + $14, 0, 2, $10

          .DLAltHeader Items + $10 * 2, 4, 4, $08

          .DLAltHeader DrawUI + $10, 0, 2, $18
          .DLAltHeader DrawUI + $14, 0, 2, $24

          .DLAltHeader Items + $12 * 2, 4, 4, $1c

          .DLAltHeader Items + $2c * 2, 4, 2, $50
          .DLAltHeader Items + $0b * 2, 4, 2, $54
          .DLAltHeader Items + $0b * 2, 4, 2, $58
          .DLAltHeader Items + $0b * 2, 4, 2, $5c
          .DLAltHeader Items + $0b * 2, 4, 2, $60
          .DLAltHeader Items + $0b * 2, 4, 2, $64
          .DLAltHeader Items + $0c * 2, 4, 2, $68
          .DLAltHeader Items + $0f * 2, 4, 2, $6c
          .DLAltHeader Items + $0f * 2, 4, 2, $70
          .DLAltHeader Items + $2f * 2, 4, 2, $74
          .DLEnd

TopBarDL4:
          .DLAltHeader DrawUI + $20, 0, 4, $04
          .DLAltHeader DrawUI + $22, 0, 4, $0c

          .DLAltHeader DrawUI + $20, 0, 4, $18
          .DLAltHeader DrawUI + $22, 0, 4, $20

          .DLAltHeader Items + $3c * 2, 4, 2, $50
          .DLAltHeader Items + $1b * 2, 4, 2, $54
          .DLAltHeader Items + $1b * 2, 4, 2, $58
          .DLAltHeader Items + $1b * 2, 4, 2, $5c
          .DLAltHeader Items + $1b * 2, 4, 2, $60
          .DLAltHeader Items + $1b * 2, 4, 2, $64
          .DLAltHeader Items + $1c * 2, 4, 2, $68
          .DLAltHeader Items + $1f * 2, 4, 2, $6c
          .DLAltHeader Items + $1f * 2, 4, 2, $70
          .DLAltHeader Items + $3f * 2, 4, 2, $74
          .DLEnd

DialogueDL1:
          .DLAltHeader DrawUI + $03 * 2, 0, 8, $00
          .for x := $08, x < $9c, x := x + 12
            .DLAltHeader DrawUI + $04 * 2, 0, 6, x
          .next
          .DLAltHeader DrawUI + $04 * 2, 0, 8, $9b

          .DLEnd

DialogueDL2:
          .DLAltHeader DrawUI + $0b * 2, 0, 2, $00
          .DLStringHeader Dialogue2Text, 2, $06
          .DLAltHeader DrawUI + $0c * 2, 0, 2, $9b

          .DLEnd

DialogueDL3:
          .DLAltHeader DrawUI + $0b * 2, 0, 2, $00
          .DLStringHeader Dialogue3Text, 2, $06
          .DLAltHeader DrawUI + $0c * 2, 0, 2, $9b

          .DLEnd

DialogueDL4:
          .DLAltHeader DrawUI + $0b * 2, 0, 2, $00
          .DLStringHeader Dialogue4Text, 2, $06
          .DLAltHeader DrawUI + $0c * 2, 0, 2, $9b

          .DLEnd

DialogueDL5:
          .DLAltHeader DrawUI + $13 * 2, 0, 6, $00
          .for x := $0c, x < $9c, x := x + 12
            .DLAltHeader DrawUI + $14 * 2, 0, 6, x
          .next
          .DLAltHeader DrawUI + $1d * 2, 0, 2, $60
          .DLAltHeader DrawUI + $17 * 2, 0, 2, $9b

          .DLEnd

DialogueDL6:
          .DLAltHeader DrawUI + $1e * 2, 0, 2, $60

          .DLEnd

;;; 
          .align $1000
Font:
          .binary "UI.art.bin"
          DrawUI = Font + 64

          .align $1000
Items:
          .binary "Items.art.bin"
          
          .align $1000
Tileset:
          .binary "Tileset.art.bin"

          .include "RLE.s"
          .include "../Generated/Maps/Atsirav.s"

          .include "EndBank.s"
