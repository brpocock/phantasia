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

BuildDLL:
          .WaitForVBlank
          .mvaw NMINext, IBeginStats
          .mva BACKGRND, #CoLu(COLYELLOW, $f) ; XXX just for testing purposes

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

          iny
          iny
          iny

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
          ldy Swap              ; DLL index

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
          jsr DialogueDL
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
          ldy ScreenNextY
          lda DLTail
          sta MapRowEndL, y
          lda DLTail + 1
          sta MapRowEndH, y

          ldy # 0

          lda # 0
          ldx #$12              ; room for stamps + terminal $0000
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

          jsr JGetPlayerFrame

          jsr UpdateSprites

SwitchToNewDLL:
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
          .WaitForVBlank
          .mva CTRL, #CTRLDMAEnable
          .mva ScreenChangedP, # 0
;;; 
Loop:
          .WaitForVBlank
          jsr JGetPlayerFrame

          jsr UpdateSprites

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
          .include "UpdateSprites.s"
          .include "DialogueDL.s"
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
