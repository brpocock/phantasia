;;; Phantasia Source/Routines/PublisherPrelude.s
;;;; Copyright © 2022 Bruce-Robert Pocock

PublisherPrelude:	.block

          .WaitForVBlank
          .mva CTRL, CTRLDMADisable

          ;; XXX Build the initial display lists
          PreludeDLL = SysRAMHigh
          BlankDList = SysRAMHigh + $40
          TitleTextDList = SysRAMHigh + $50
          SubtitleTextDList = SysRAMHigh + $50

          ;; Blank row display list is empty.
          .mva BlankDList, #0
          .mva BlankDList + 1, #0

          ;; Hello world text display list
          ldy # 0

          .mvayi TitleTextDList, #<TitleTextString+1
          .mvayi TitleTextDList, #DLExtMode(false, true)
          .mvayi TitleTextDList, #>TitleTextString+1
          .DLPalDynWidth 0, TitleTextString
          sta TitleTextDList, y
          iny
          .mvayi TitleTextDList, #16

          .mvayi TitleTextDList, #0
          .mvay TitleTextDList, #0

          .mvayi SubtitleTextDList, #<SubtitleTextString+1
          .mvayi SubtitleTextDList, #DLExtMode(false, true)
          .mvayi SubtitleTextDList, #>SubtitleTextString+1
          .DLPalDynWidth 0, SubtitleTextString
          sta SubtitleTextDList, y
          iny
          .mvayi SubtitleTextDList, #16

          .mvayi SubtitleTextDList, #0
          .mvay SubtitleTextDList, #0
          
          ;; Display List List
          ldy # 0

          ldx # 7
FillTopBlank:
          .mvayi PreludeDLL, #10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillTopBlank

TitleText:
          .mvayi PreludeDLL, #15 | DLLDLI | DLLHoley16
          .mvayi PreludeDLL, #>TitleTextDList
          .mvayi PreludeDLL, #<TitleTextDList
          
SubtitleText:
          .mvayi PreludeDLL, #7 | DLLDLI | DLLHoley8
          .mvayi PreludeDLL, #>SubtitleTextDList
          .mvayi PreludeDLL, #<SubtitleTextDList
          
          ldx # 10
FillBottomBlank:
          .mvayi PreludeDLL, #15
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillBottomBlank

          .mvayi PreludeDLL, #10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList


          .WaitForVBlank
          ;; Set up Maria controls
          .mva BACKGRND, #CoLu(COLYELLOW, $f)
          .mva P0C1, #CoLu(COLGRAY, $0)
          .mva P0C2, #CoLu(COLGRAY, $f)
          .mva P0C3, #CoLu(COLGRAY, $0)
          .mva DPPL, #<PreludeDLL
          .mva DPPH, #>PreludeDLL
          .mvaw NMINext, NMISwitchToBigFont
          ;; Turn on the Maria
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC

          ;; XXX Hang
Hang:
          jmp Hang

;;; 
          
NMISwitchToBigFont:
          .mvaw NMINext, NMISwitchToFont
          .mva BACKGRND, #CoLu(COLGREEN, $8)
          .mva CHARBASE, #>BigFont
          rti

NMISwitchToFont:
          .mvaw NMINext, NMISwitchToBigFont
          .mva BACKGRND, #CoLu(COLBLUE, $8)
          .mva CHARBASE, #>Font
          rti

;;; 
          
          .enc "minifont"

TitleTextString:
          .ptext "phantasia"
          .fill 50, 0           ; XXX

SubtitleTextString:
          .ptext "© 2022 bruce-robert pocock"

          .fill 50, 0           ; XXX
          .bend
