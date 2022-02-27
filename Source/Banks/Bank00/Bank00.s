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
          .mvayi DLL, # 7
          .mvayi DLL, #>TopBarDL1
          .mvayi DLL, #<TopBarDL1

          .mvayi DLL, # 7
          .mvayi DLL, #>TopBarDL2
          .mvayi DLL, #<TopBarDL2

          .mvayi DLL, # 7
          .mvayi DLL, #>TopBarDL3
          .mvayi DLL, #<TopBarDL3

          .mvayi DLL, # 7
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

          .mva P6C1, #CoLu(COLGRAY, $0)
          .mva P6C2, #CoLu(COLGRAY, $c)
          .mva P6C3, #CoLu(COLGRAY, $f)
          .WaitForVBlank
          .mva CTRL, #CTRLDMAEnable

Loop:
          jmp Loop
;;; 
BeginTopBar:
          stx WSYNC
          .mva BACKGRND, #CoLu(COLYELLOW, $9)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320BD
          .mvaw NMINext, EndTopBar
          rti

EndTopBar:
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGREEN, $f)
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
          .DLHeader DrawUI + $00, 6, 4, $00
          ;; .DLHeader DrawUI + $02, 6, 2, $08
          .DLHeader DrawUI + $02, 6, 4, $10
          ;; .DLHeader DrawUI + $04, 6, 2, $18
BlankDL:
          .DLEnd
TopBarDL2:
          .DLHeader DrawUI + $10, 6, 2, $00
          .DLHeader DrawUI + $14, 6, 2, $18
          .DLEnd
TopBarDL3:
          .DLHeader DrawUI + $10, 6, 2, $00
          .DLHeader DrawUI + $14, 6, 2, $18
          .DLEnd
TopBarDL4:
          .DLHeader DrawUI + $20, 6, 2, $00
          .DLHeader DrawUI + $22, 6, 2, $08
          .DLHeader DrawUI + $22, 6, 2, $10
          .DLHeader DrawUI + $24, 6, 2, $18
          .DLEnd
;;; 
          .align $100
Font:
          .binary "UI.art.bin"
          DrawUI = Font + 64

          .align $100
          .binary "Tileset.art.bin"

          .include "EndBank.s"
