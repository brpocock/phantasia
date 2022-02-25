;;; Phantasia Source/Routines/TitleScreen.s
;;;; Copyright © 2022 Bruce-Robert Pocock

TitleScreen:	.block

         .WaitForVBlank
          .mva CTRL, CTRLDMADisable

          ;; XXX Build the initial display lists
          PreludeDLL = SysRAMHigh
;;; 
          ;; Display List List
          ldy # 0

          ldx # 7
FillTopBlank:
          .mvayi PreludeDLL, # 10
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

          dex
          bne FillTopBlank

          .mvayi PreludeDLL, # 5 | DLLDLI
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

TitleText:
          .mvayi PreludeDLL, # 15
          .mvayi PreludeDLL, #>TitleTextDL
          .mvayi PreludeDLL, #<TitleTextDL
          
          .mvayi PreludeDLL, # 5
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

          .mvayi PreludeDLL, # 0 | DLLDLI
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>SubtitleTextDL
          .mvayi PreludeDLL, #<SubtitleTextDL

          ldx # 10
FillBottomBlank:
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

          dex
          bne FillBottomBlank

          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>CopyrightTextDL
          .mvayi PreludeDLL, #<CopyrightTextDL          
          
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>BuildTextDL
          .mvayi PreludeDLL, #<BuildTextDL          
          
          .mvayi PreludeDLL, # 15
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

;;; 
          .WaitForVBlank
          ;; Set up Maria controls
          .mva P0C2, #CoLu(COLGRAY, $f)
          .mva P1C2, #CoLu(COLGRAY, $f)
          .mva P2C2, #CoLu(COLBLUE, $2)
          .mva DPPL, #<PreludeDLL
          .mva DPPH, #>PreludeDLL

          ;; Duplicate this in the bottommost NMI routine as well
          .mvaw NMINext, NMISwitchToBigFont
          .mva BACKGRND, #CoLu(COLBLUE, $8)
          .mva CHARBASE, #>Font
          ;; Turn on the Maria
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC

          ldx # 60
Wait:
          .WaitForVBlank
          dex
          bne Wait

          ldy # 3 * 15
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>PressRightButtonDL
          .mvayi PreludeDLL, #<PressRightButtonDL

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
          .enc "minifont"

TitleTextString:      .bigptext "phantasia"
SubtitleTextString:   .ptext "an adventure"
BuildTextString:      .ptext format("build %s", BUILD)
CopyrightTextString:  .ptext "© 2022 bruce-robert pocock"
PressRightButtonString: .ptext "press right button to begin"
;;; 
BlankDL:
          .DLEnd
TitleTextDL:
          .DLStringHeader TitleTextString, 0, 32
          .DLEnd
SubtitleTextDL:
          .DLStringHeader SubtitleTextString, 1, 32
          .DLEnd
CopyrightTextDL:
          .DLStringHeader CopyrightTextString, 2, 52
          .DLEnd
BuildTextDL:
          .DLStringHeader BuildTextString, 2, 108
          .DLEnd
PressRightButtonDL:
          .DLStringHeader PressRightButtonString, 1, 32
          .DLEnd
;;; 

          .bend
