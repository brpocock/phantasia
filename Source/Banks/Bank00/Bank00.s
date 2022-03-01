;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"

BankEntry:

          .mva NMINext, 0
          .WaitForVBlank
          .mva CTRL, #CTRLDMADisable
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

          ldx # 12
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
          .mva P2C2, #CoLu(COLBLUE, $c)
          .mva P3C2, #CoLu(COLGRAY, $d)
          .WaitForVBlank
          .mva CTRL, #CTRLDMAEnable

Loop:
          jmp Loop
;;; 
BeginTopBar:
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mvaw NMINext, EndTopBar
          rti

EndTopBar:
          stx WSYNC
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGREEN, $8)
          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mvaw NMINext, SwitchToOverscan
          rti

SwitchToOverscan:
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mvaw NMINext, BeginTopBar
          rti
;;; 
MapFillDL:
          .DLEnd
TopBarDL1:
          .DLExtHeader DrawUI + $00, 0, 4, $04, true, false
          .DLExtHeader DrawUI + $02, 0, 4, $0c, true, false

BlankDL:
          .DLEnd
TopBarDL2:
          .DLExtHeader DrawUI + $10, 0, 2, $04, true, false
          .DLExtHeader DrawUI + $14, 0, 2, $10, true, false

          .DLExtHeader Items + $00 * 2, 1, 2, $08, true, false
          .DLExtHeader Items + $01 * 2, 1, 2, $0c, true, false

          .DLEnd
TopBarDL3:
          .DLExtHeader DrawUI + $10, 0, 2, $04, true, false
          .DLExtHeader DrawUI + $14, 0, 2, $10, true, false

          .DLExtHeader Items + $10 * 2, 1, 2, $08, true, false
          .DLExtHeader Items + $11 * 2, 1, 2, $0c, true, false

          .DLExtHeader Items + $2c * 2, 1, 2, $48, true, false
          .DLExtHeader Items + $0b * 2, 1, 2, $4c, true, false
          .DLExtHeader Items + $0b * 2, 1, 2, $50, true, false
          .DLExtHeader Items + $0b * 2, 1, 2, $54, true, false
          .DLExtHeader Items + $0b * 2, 1, 2, $58, true, false
          .DLExtHeader Items + $0b * 2, 1, 2, $5c, true, false
          .DLExtHeader Items + $0c * 2, 1, 2, $60, true, false
          .DLExtHeader Items + $0f * 2, 1, 2, $64, true, false
          .DLExtHeader Items + $0f * 2, 1, 2, $68, true, false
          .DLExtHeader Items + $2f * 2, 1, 2, $6c, true, false
          .DLEnd
TopBarDL4:
          .DLExtHeader DrawUI + $20, 0, 4, $04, true, false
          .DLExtHeader DrawUI + $22, 0, 4, $0c, true, false
          .DLExtHeader Items + $3c * 2, 1, 2, $48, true, false
          .DLExtHeader Items + $1b * 2, 1, 2, $4c, true, false
          .DLExtHeader Items + $1b * 2, 1, 2, $50, true, false
          .DLExtHeader Items + $1b * 2, 1, 2, $54, true, false
          .DLExtHeader Items + $1b * 2, 1, 2, $58, true, false
          .DLExtHeader Items + $1b * 2, 1, 2, $5c, true, false
          .DLExtHeader Items + $1c * 2, 1, 2, $60, true, false
          .DLExtHeader Items + $1f * 2, 1, 2, $64, true, false
          .DLExtHeader Items + $1f * 2, 1, 2, $68, true, false
          .DLExtHeader Items + $3f * 2, 1, 2, $6c, true, false
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

          .include "EndBank.s"
