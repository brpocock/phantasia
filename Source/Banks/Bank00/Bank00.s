;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"
;;; 
BankEntry:
          cpy # 0
          beq GenerateDrawingList
          brk

GenerateDrawingList:
          jsr StartDLL
          jsr StatsDL
          jsr DialogueDL
          jsr MapSectionDL
          jsr WriteOverscanDL
          jsr JGetPlayerFrame
          jsr UpdateSprites
          jsr SwitchToNewDLL
          .include "MainLoop.s"
;;; 
          .include "CopyToDL.s"
          .include "DialogueDL.s"
          .include "EmitSpan.s"
          .include "LookUpPalette.s"
          .include "MapSectionDL.s"
          .include "ScreenTopAssets.s"
          .include "StartDLL.s"
          .include "StatsDL.s"
          .include "SwitchToNewDLL.s"
          .include "UpdateSprites.s"
          .include "WriteOverscanDL.s"

;;; 
          * = $a000
Font:
          .binary "UI.art.bin"
          DrawUI = Font + 64
;;; 
          .align $1000
Items:
          .binary "Items.art.bin"
;;; 
          .include "EndBank.s"
