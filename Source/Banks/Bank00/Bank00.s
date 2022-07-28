;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = $00

          .include "StartBank.s"
;;; 
BankEntry:
          cpy # 0
          beq GamePlay
          brk

GamePlay:
          jsr GenerateDrawingList
          .include "MainLoop.s"
;;; 
          .include "CopyToDL.s"
          .include "DialogueDL.s"
          .include "EmitSpan.s"
          .include "GenerateDrawingList.s"
          .include "LookUpPalette.s"
          .include "MapSectionDL.s"
          .include "FindMapSource.s"          
          .include "ScreenTopAssets.s"
          .include "StartDLL.s"
          .include "StatsDL.s"
          .include "SwitchToNewDLL.s"
          .include "UpdateSprites.s"
          .include "WriteOverscanDL.s"
;;; 
          * = $a000
Font:
          .binary "Art.UI.o"
          DrawUI = Font + 64
;;; 
          .align $1000
Items:
          .binary "Art.Items.o"
;;; 
          .include "EndBank.s"
