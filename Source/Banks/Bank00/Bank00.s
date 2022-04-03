;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"
;;; 
BankEntry:
          .mva NMINext, # 0
          .mva CTRL, #CTRLDMADisable

          ;; Decompress the current map
          ldy # 0
          ldx # 2
          jsr JFarCall

          .WaitForVBlank
          .mvaw NMINext, IBeginStats
          .mva BACKGRND, #CoLu(COLYELLOW, $f)

          BlankDL = SysRAMHigh
          DLL = SysRAMHigh + $02
          DLSpace = SysRAMHigh + $80
          StringsStart = DLSpace + $280
          AltDLL = StringsStart + $200
          AltDLSpace = AltDLL + $80
          AltStringsStart = AltDLSpace + $280

BuildDLL:
          lda ActiveDLL
          beq +
          .mvaw DLLTail, AltDLL
          .mvaw DLTail, AltDLSpace
          .mvaw StringsTail, AltStringsStart
          jmp GotPointers
+
          .mvaw DLLTail, DLL
          .mvaw DLTail, DLSpace
          .mvaw StringsTail, StringsStart
GotPointers:
          lda ActiveDLL
          eor # 1
          sta ActiveDLL

          lda # 233
          sec
          sbc StatsLines
          sbc DialogueLines
          sta MapLines

          ldy # 0
          sty BlankDL
          sty BlankDL + 1

          .mvapyi DLLTail, # 11 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL
StatsDLL:

          sty Swap              ; DLL index
          ldy # 0               ; DL index

          .mvap Pointer, DLTail

          ldx # 5 * 4
          .mvaw Source, StatsDLTop
          jsr CopyToDL

          .mvapyi DLTail, #<MapNameString + 1
          .mvapyi DLTail, #DLExtMode(false, true)
          .mvapyi DLTail, #>MapNameString + 1
          lda MapNameString
          sec
          sbc # 1
          eor #$1f
          ora #(2 << 5)
          sta (DLTail), y
          iny
          .mvapyi DLTail, #DLPalWidth(2, MapNameString)
          .mvapyi DLTail, #$50

          .mvapyi DLTail, # 0
          sta (DLTail), y
          iny

          tya
          .Add16a DLTail
          ldy Swap

          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, Pointer + 1
          .mvapyi DLLTail, Pointer

          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, #>StatsDL2
          .mvapyi DLLTail, #<StatsDL2

          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, #>StatsDL3
          .mvapyi DLLTail, #<StatsDL3

          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, #>StatsDL4
          .mvapyi DLLTail, #<StatsDL4
;;; 
DialogueDLL:
          lda StatsLines
          cmp #$21
          bge DoneDialogue

          lda DialogueLines
          beq DoneDialogue

          .mvap Dest, DLTail
          sec
          sbc #$10              ; XXX minimum height
          bmi DoneDialogue

          lsr a
          lsr a
          lsr a
          sta Counter         ; lines in mid section @ 8px
          ;; XXX no partial zones

          .mvapyi DLLTail, # 7 | DLLHoley8 | DLLDLI
          .mvapyi DLLTail, #>DialogueTopDL
          .mvapyi DLLTail, #<DialogueTopDL

          tya
          .Add16a DLLTail
          ldy # 0
NextDialogueZone:
          ldx # 0
CopyDialogueMidDL:
          lda DialogueMidDL, x
          sta (DLTail), y
          iny
          inx
          cpx #DialogueBottomDL - DialogueMidDL + 1
          bne CopyDialogueMidDL

          tya
          sec
          sbc # 13
          tay                   ; go back to string header padding
          
          .mvapyi DLTail, #<Dialogue2Text + 1
          iny                   ; skip over mode byte
          .mvapyi DLTail, #>Dialogue2Text + 1
          lda Dialogue2Text
          sec
          sbc # 1
          eor #$1f              ; encode width
          ora #$20              ; palette 2
          sta (DLTail), y

          .Add16 DLTail, #DialogueBottomDL - DialogueMidDL + 1

          ldy # 0               ; DLL index

          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, Dest + 1
          .mvapyi DLLTail, Dest

          tya
          .Add16a DLLTail

          lda Counter
          sec
          sbc # 8
          sta Counter
          beq DoneDialogueMid
          bpl NextDialogueZone

          ;; XXX partial zone

DoneDialogueMid:
          ldy # 0
          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, #>DialogueBottomDL
          .mvapyi DLLTail, #<DialogueBottomDL

DoneDialogue:
          tya
          .Add16a DLLTail
;;; 
MapSectionDLL:
          lda MapLines
          cmp #$10
          blt DoneMap

          ldy # 0
          .mvapyi DLLTail, # 2 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL
          .mvapyi DLLTail, # 1
          .mvapyi DLLTail, #>BlankDL
          .mvapy DLLTail, #<BlankDL
          .Add16 DLLTail, # 3

DrawMapSection:
          lda MapTopRow
          sta MapNextY

          ldy # 0
          sty ScreenNextY

          lda #<MapArt
          sta Source
          lda #>MapArt
          sta Source + 1

          ;; multiply row × 32 and add to Source pointer
          lda MapTopRow
          asl a
          asl a
          asl a
          bcc +
          inc Source + 1
+
          asl a
          bcc +
          inc Source + 1
          clc
+
          adc Source
          sta Source

          ldy # 0
          jsr LookUpPalette

MoreMapRows:
          ldy # 0
          .mvapyi DLLTail, # 15 | DLLHoley16
          .mvapyi DLLTail, DLTail + 1
          .mvapyi DLLTail, DLTail

          tya
          .Add16a DLLTail

          .mvy Swap, MapLeftColumn
          .mvx SpanWidth, # 0
          .mvap Pointer, StringsTail
          .mva MapNextX, MapLeftPixel
CopyTileSpan:
          lda SpanWidth
          cmp #$1f              ; is this string getting too long for one draw?
          bge EmitSpanMidLine
          
          ldy Swap              ; current column of source
          lda (Source), y
          bpl PaletteOK

          lda SpanWidth
          beq DoneEmittingSpan

EmitSpanMidLine:
          ;; Palette changed, what was it, what will it be?
          jsr EmitSpan

          ;; update left of next span
          lda SpanWidth
          asl a
          asl a
          asl a
          clc
          adc MapNextX
          sta MapNextX

          .mva SpanWidth, # 0

          .Add16 DLTail, # 5

          ldy Swap              ; column in source
DoneEmittingSpan:

ReadNextPalette:
          jsr LookUpPalette

          ldy Swap              ; column in source
          lda (Source), y
PaletteOK:
          asl a                 ; tile byte address
          ldy # 0
          sta (StringsTail), y
          inc Swap              ; column in map source
          inc SpanWidth

          .Add16 StringsTail, # 1
          inx
          cpx # 21
          blt CopyTileSpan

EmitFinalSpan:
          jsr EmitSpan

          .Add16 DLTail, # 5
SaveMapEnd:
          lda ScreenNextY
          asl a
          tay
          lda DLTail
          sta MapRowEnd, y
          iny
          lda DLTail + 1
          sta MapRowEnd, y

          ldy # 0

          lda # 0
          ldx #$12              ; XXX room for stamps + terminal $0000
FillSpanZeroes:
          sta (DLTail), y
          iny
          dex
          bne FillSpanZeroes

          tya
          .Add16a DLTail

          .Add16 Source, CurrentMapWidth
          inc ScreenNextY
          lda ScreenNextY
          asl a                 ; 16 lines per row
          asl a
          asl a
          asl a
          cmp MapLines
          bge DoneMap

          ldy # 0
          jsr LookUpPalette
          jmp MoreMapRows
DoneMap:
;;; 
WriteOverscanDLL:
          .mvapyi DLLTail, # 0 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 11
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 12
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          ;; These should not be necessary? XXX

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .WaitForVBlank
          lda ActiveDLL
          beq +
          .mva DPPL, #<DLL
          .mva DPPH, #>DLL
          jmp EnableDMA
+
          .mva DPPL, #<AltDLL
          .mva DPPH, #>AltDLL
EnableDMA:
          .mva CTRL, #CTRLDMAEnable
;;; 
Loop:
          lda ScreenChangedP
          beq Loop
          jmp BuildDLL
;;; 
CopyToDL:
          sty Temp
          ldy # 0
          lda (Source), y
          ldy Temp
          sta (DLTail), y
          iny
          .Add16 Source, # 1
          dex
          bne CopyToDL
          rts
;;; 
EmitSpan:
          ldy # 0
          .mvapyi DLTail, Pointer
          .mvapyi DLTail, #DLExtMode(false, true)
          .mvapyi DLTail, Pointer + 1
          ;; calculate palette + width value
          lda SpanWidth
          sec
          sbc # 1
          eor #$1f              ; encode span width
          ora SelectedPalette
          sta (DLTail), y
          iny
          .mvapyi DLTail, MapNextX
          .mvap Pointer, StringsTail

          rts
;;; 
LookUpPalette:
          ;; Look up the palette
          ;; Source is exactly 1kiB below the place we want
          .mva Dest, Source
          lda Source + 1
          clc
          adc # 4
          sta Dest + 1

          lda (Dest), y
          ;; got the attribute indirect ID, multiply by 6
          asl a
          sta Dest              ; temp
          asl a
          clc
          adc Dest              ; temp
          ;; index into attributes table + 4 bytes to get palette ID
          tay
          lda MapAttributes + 4, y
          and #$e0
          sta SelectedPalette

          rts
;;; 
BeginStats:
          .mva P0C2, #CoLu(COLGRAY, $9)
          .mva P1C2, #CoLu(COLGRAY, $b)
          .mva P2C2, #CoLu(COLGRAY, $f)
          .mva P3C2, #CoLu(COLGRAY, $d)

          .mva P4C2, #CoLu(COLGRAY, $c)
          .mva P5C2, #CoLu(COLBLUE, $4)
          .mva P6C2, #CoLu(COLBROWN, $4)
          .mva P7C2, #CoLu(COLORANGE, $8)

          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>Font
          rts

IBeginStats:
          .SaveRegs
          jsr BeginStats
          .mvaw NMINext, IEndStats
          jmp JReturnFromInterrupt

BeginDialogue:
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mva P0C2, #CoLu(COLGRAY, $9)
          .mva P1C2, #CoLu(COLGRAY, $b)
          .mva P2C2, #CoLu(COLGRAY, $f)
          .mva P3C2, #CoLu(COLGRAY, $d)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>Font
          stx WSYNC
          rts

IEndStats:
          .SaveRegs
          lda DialogueLines
          beq DoBeginMap

          jsr BeginDialogue
          .mvaw NMINext, IEndDialogue
          jmp JReturnFromInterrupt

IEndDialogue:
          .SaveRegs
DoBeginMap:
          jmp JTileDLI
;;; 

          .include "ScreenTopAssets.s"
          
          * = $9000
          jmp IBeginStats

;;; 
          .align $1000
Font:
          .binary "UI.art.bin"
          DrawUI = Font + 64
;;; 
          .align $1000
Items:
          .binary "Items.art.bin"
;;; 
          .include "EndBank.s"
