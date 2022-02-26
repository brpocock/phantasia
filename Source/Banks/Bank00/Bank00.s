;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"

BankEntry:

          .WaitForVBlank
          .mva CTRL, #CTRLDMADisable
          .mva BACKGRND, #CoLu(COLYELLOW, $f)
          .mva NMINext, # 0

          DLL = SysRAMHigh

          ldy # 0
          
          .mvayi DLL, # 9
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          ldx # 4
TopBarDLL:
          .mvayi DLL, # 7
          .mvayi DLL, #>TopBarDL
          .mvayi DLL, #<TopBarDL

          dex
          bne TopBarDLL
          
          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          ldx # 12
MapFillDLL:
          .mvayi DLL, # 15
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          dex
          bne MapFillDLL

          .WaitForVBlank
          .mvaw NMINext, BeginTopBar
          .mva CTRL, #CTRLDMAEnable

Loop:
          jmp Loop

;;; 
BeginTopBar:
          .mva BACKGRND, #CoLu(COLYELLOW, $9)
          .mvaw NMINext, EndTopBar
          rti

EndTopBar:
          .mva BACKGRND, #CoLu(COLSPRINGGREEN, $f)
          .mvaw NMINext, BeginTopBar
          rti
;;; 
TopBarDL:
BlankDL:
          .DLEnd



;;; 

          .align $100
          .binary "Tileset.art.bin"

          .include "EndBank.s"
