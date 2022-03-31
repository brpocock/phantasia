;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"
;;; 
BankEntry:
          .mva NMINext, # 0
          .mva CTRL, #CTRLDMADisable

          .mva CurrentMap, # 0
          ldy # 0
          ldx # 2
          jsr JFarCall

          .WaitForVBlank
          .mvaw NMINext, IBeginStats
          .mva BACKGRND, #CoLu(COLYELLOW, $f)

          DLL = SysRAMHigh
          DialogueDL = DLL + $100
          MapDLStart = DLL + $200
          MapStringsStart = DLL + $300

BuildDLL:
          .mvaw DLLTail, DLL
          lda # 192
          sec
          sbc StatsLines
          sbc DialogueLines
          sta MapLines
          
          ldy # 0

          .mvapyi DLLTail, # 11 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

StatsDLL:
          .mvapyi DLLTail, # 7 | DLLHoley8
          .mvapyi DLLTail, #>StatsDL1
          .mvapyi DLLTail, #<StatsDL1

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
          .mvaw DLTail, DialogueDL ; end of DialogueDLs
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
          .mvapyi DLLTail, #>DialogueDL
          .mvapyi DLLTail, #<DialogueDL

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

DrawMapSection:
          lda MapTopRow
          sta MapNextY

          ldy # 0
          sty ScreenNextY

          .mvaw DLTail, MapDLStart
          .mvaw StringsTail, MapStringsStart

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

MoreMapRows:
          ldy # 0
          lda # 15 | DLLHoley16
          ldx ScreenNextY
          bne +
          ora # DLLDLI
+
          sta DLLTail, y
          iny

          .mvapyi DLLTail, DLTail + 1
          .mvapyi DLLTail, DLTail

          tya
          .Add16a DLLTail

          ldy MapLeftColumn
          sty Swap
          ldx # 0               ; horizontal tile screen position index
CopyTiles:
          lda (Source), y
          bpl PaletteOK
          ;; XXX handle palette swap
PaletteOK:
          asl a                 ; tile byte address
          ldy # 0
          sta (StringsTail), y
          iny
          clc
          adc # 1
          sta (StringsTail), y
          inc Swap
          inc Swap

          .Add16 StringsTail, # 2
          inx
          cpx #$11              ; because of fine scrolling
          blt CopyTiles

          ldy # 0               ; drawing list index
          .mvapyi DLTail, StringsTail + 1
          .mvapyi DLTail, #DLExtMode(false, true)
          .mvapyi DLTail, StringsTail
          .mvapyi DLTail, DLPalWidth(2, 16) ; XXX palette
          .mvapyi DLTail, MapLeftPixel

          .mvapyi DLTail, # 0
          .mvapy DLTail, # 0

          .Add16 DLTail, # 7

          .Add16 Source, #$20   ; next row in map data too
          inc ScreenNextY
          lda ScreenNextY
          asl a
          asl a
          asl a
          asl a
          cmp MapLines
          blt MoreMapRows

DoneMap:
;;; 
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
          .mva DPPL, #<DLL
          .mva DPPH, #>DLL
          .mva CTRL, #CTRLDMAEnable
;;; 
Loop:
          jmp Loop
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
          .enc "minifont"
LocationNameString: .ptext "locale name here"

Dialogue2Text:      .ptext "hello, world."
Dialogue3Text:      .ptext "this is a test"
Dialogue4Text:      .ptext "this is only a test"

StatsDL1:
          .DLAltHeader DrawUI + $00, 0, 4, $04
          .DLAltHeader DrawUI + $02, 0, 4, $0c

          .DLStringHeader LocationNameString, 2, $50

          .DLAltHeader DrawUI + $00, 0, 4, $18
          .DLAltHeader DrawUI + $02, 0, 4, $20

BlankDL:
          .DLEnd

StatsDL2:
          .DLAltHeader DrawUI + $10, 0, 2, $04
          .DLAltHeader DrawUI + $14, 0, 2, $10

          .DLAltHeader Items + $00 * 2, 4, 4, $08

          .DLAltHeader DrawUI + $10, 0, 2, $18
          .DLAltHeader DrawUI + $14, 0, 2, $24

          .DLAltHeader Items + $02 * 2, 4, 4, $1c

          .DLEnd

StatsDL3:
          .DLAltHeader DrawUI + $10, 0, 2, $04
          .DLAltHeader DrawUI + $14, 0, 2, $10

          .DLAltHeader Items + $10 * 2, 4, 4, $08

          .DLAltHeader DrawUI + $10, 0, 2, $18
          .DLAltHeader DrawUI + $14, 0, 2, $24

          .DLAltHeader Items + $12 * 2, 4, 4, $1c

          .DLAltHeader Items + $2c * 2, 4, 2, $50
          .DLAltHeader Items + $0b * 2, 4, 2, $54
          .DLAltHeader Items + $0b * 2, 4, 2, $58
          .DLAltHeader Items + $0b * 2, 4, 2, $5c
          .DLAltHeader Items + $0b * 2, 4, 2, $60
          .DLAltHeader Items + $0b * 2, 4, 2, $64
          .DLAltHeader Items + $0c * 2, 4, 2, $68
          .DLAltHeader Items + $0f * 2, 4, 2, $6c
          .DLAltHeader Items + $0f * 2, 4, 2, $70
          .DLAltHeader Items + $2f * 2, 4, 2, $74
          .DLEnd

StatsDL4:
          .DLAltHeader DrawUI + $20, 0, 4, $04
          .DLAltHeader DrawUI + $22, 0, 4, $0c

          .DLAltHeader DrawUI + $20, 0, 4, $18
          .DLAltHeader DrawUI + $22, 0, 4, $20

          .DLAltHeader Items + $3c * 2, 4, 2, $50
          .DLAltHeader Items + $1b * 2, 4, 2, $54
          .DLAltHeader Items + $1b * 2, 4, 2, $58
          .DLAltHeader Items + $1b * 2, 4, 2, $5c
          .DLAltHeader Items + $1b * 2, 4, 2, $60
          .DLAltHeader Items + $1b * 2, 4, 2, $64
          .DLAltHeader Items + $1c * 2, 4, 2, $68
          .DLAltHeader Items + $1f * 2, 4, 2, $6c
          .DLAltHeader Items + $1f * 2, 4, 2, $70
          .DLAltHeader Items + $3f * 2, 4, 2, $74
          .DLEnd

DialogueTopDL:
          .DLAltHeader DrawUI + $03 * 2, 0, 8, $00
          .for x := $08, x < $90, x := x + 12
            .DLAltHeader DrawUI + $04 * 2, 0, 6, x
          .next
          .DLAltHeader DrawUI + $04 * 2, 0, 8, $90

          .DLEnd

DialogueMidDL:
          .DLAltHeader DrawUI + $0b * 2, 0, 2, $00
          ;; placeholder values $ff are overwritten when the DL is constructed
          .byte $ff, DLExtMode(false, true), $ff, $ff, $10
          .DLAltHeader DrawUI + $0f * 2, 0, 2, $9c

          .DLEnd

DialogueBottomDL:
          .DLAltHeader DrawUI + $13 * 2, 0, 6, $00
          .for x := $0c, x < $60, x := x + 12
            .DLAltHeader DrawUI + $14 * 2, 0, 6, x
          .next
          .DLAltHeader DrawUI + $1b * 2, 0, 10, $60
          .for x := $6a, x < $90, x := x + 12
            .DLAltHeader DrawUI + $14 * 2, 0, 6, x
          .next
          .DLAltHeader DrawUI + $14 * 2, 0, 8, $90

          .DLEnd

;;; 
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
