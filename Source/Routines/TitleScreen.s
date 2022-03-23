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

          .mvaw AlarmV, ShowPressRightButton
          .mva AlarmSeconds, # 5
          .mva AlarmEnabledP, #$80
Loop:
          .WaitForVBlank
          jsr JFrameService

          lda NewINPT0
          bpl Loop

          ldy # 0
          sty NMINext + 1
          sty NMINext

          .mva GameMode, #ModeMap

          ;; FIXME clear the DLL before leaving the ROM bank

          ldx # 0
          jmp JFarJump
;;; 
ShowPressRightButton:
          ldy # 3 * 15
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>PressRightButtonDL
          .mvayi PreludeDLL, #<PressRightButtonDL

          .mvaw AlarmV, HidePressRightButton
          .mva AlarmSeconds, # 3
          .mva AlarmEnabledP, #$80
          rts

HidePressRightButton:
          ldy # 3 * 15
          .mvayi PreludeDLL, # 7
          .mvayi PreludeDLL, #>BlankDL
          .mvayi PreludeDLL, #<BlankDL

          .mvaw AlarmV, ShowPressRightButton
          .mva AlarmSeconds, # 3
          .mva AlarmEnabledP, #$80
          rts
;;; 
NMISwitchToBigFont:
          .mvaw NMINext, NMISwitchToFont
          .mva BACKGRND, #CoLu(COLGREEN, $8)
          .mva CHARBASE, #>BigFont
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC | CTRLCharWide
RTI:
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
TitleTextDL:
          .DLStringHeader TitleTextString, 0, 32
BlankDL:
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
