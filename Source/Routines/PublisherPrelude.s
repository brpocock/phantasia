;;; Phantasia Source/Routines/PublisherPrelude.s
;;;; Copyright © 2022 Bruce-Robert Pocock

PublisherPrelude:	.block

          .WaitForVBlank
          .mva CTRL, CTRLDMADisable

          ;; XXX Build the initial display lists
          PreludeDLL = SysRAMHigh
          BlankDList = SysRAMHigh + $40
          TitleTextDList = SysRAMHigh + $50
          SubtitleTextDList = SysRAMHigh + $70
          CopyrightTextDList = SysRAMHigh + $80
;;; 
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
          .mvayi TitleTextDList, # 32

          .mvayi TitleTextDList, # 0
          .mvay TitleTextDList, # 0

          .mvayi SubtitleTextDList, #<SubtitleTextString+1
          .mvayi SubtitleTextDList, #DLExtMode(false, true)
          .mvayi SubtitleTextDList, #>SubtitleTextString+1
          .DLPalDynWidth 1, SubtitleTextString
          sta SubtitleTextDList, y
          iny
          .mvayi SubtitleTextDList, # 50

          .mvayi SubtitleTextDList, # 0
          .mvay SubtitleTextDList, # 0

          .mvayi CopyrightTextDList, #<CopyrightTextString+1
          .mvayi CopyrightTextDList, #DLExtMode(false, true)
          .mvayi CopyrightTextDList, #>CopyrightTextString+1
          .DLPalDynWidth 2, CopyrightTextString
          sta CopyrightTextDList, y
          iny
          .mvayi CopyrightTextDList, # 50

          .mvayi CopyrightTextDList, # 0
          .mvay CopyrightTextDList, # 0
;;; 
          ;; Display List List
          ldy # 0

          ldx # 7
FillTopBlank:
          .mvayi PreludeDLL, # 10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillTopBlank

          .mvayi PreludeDLL, # 5 | DLLDLI
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

TitleText:
          .mvayi PreludeDLL, # 15
          .mvayi PreludeDLL, #>TitleTextDList
          .mvayi PreludeDLL, #<TitleTextDList
          
          .mvayi PreludeDLL, # 5
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          .mvayi PreludeDLL, # 0 | DLLDLI
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

SubtitleText:
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>SubtitleTextDList
          .mvayi PreludeDLL, #<SubtitleTextDList
          
          ldx # 10
FillBottomBlank:
          .mvayi PreludeDLL, # 15
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillBottomBlank

          .mvayi PreludeDLL, #10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList
;;; 
          .WaitForVBlank
          ;; Set up Maria controls
          .mva P0C2, #CoLu(COLGRAY, $f)
          .mva P1C2, #CoLu(COLGRAY, $f)
          .mva P2C2, #CoLu(COLGRAY, $0)
          .mva DPPL, #<PreludeDLL
          .mva DPPH, #>PreludeDLL

          ;; Duplicate this in the bottommost NMI routine as well
          .mvaw NMINext, NMISwitchToBigFont
          .mva BACKGRND, #CoLu(COLBLUE, $8)
          .mva CHARBASE, #>Font
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
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC | CTRLCharWide
          rti

NMISwitchToFont:
          .mvaw NMINext, NMISwitchToBigFont
          .mva BACKGRND, #CoLu(COLBLUE, $8)
          .mva CHARBASE, #>Font
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          rti
;;; 
TitleTextString:
          .enc "minifont"
          .bigptext "phantasia"

SubtitleTextString:
          .ptext "an adventure"

CopyrightTextString:
          .ptext "© 2022 bruce-robert pocock"

          .bend
