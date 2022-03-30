;;; Phantasia Source/Source/Banks/Bank00/Bank00.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 00

          .include "StartBank.s"

BankEntry:
          .mva StatsLines, #$20  ; 4 × 8
          .mva DialogueLines, #$28 ; 5 × 8

          .mva NMINext, # 0
          .mva CTRL, #CTRLDMADisable

          .mvaw NMINext, IBeginStats
          .mva BACKGRND, #CoLu(COLYELLOW, $f)

          DLL = SysRAMHigh
          DialogueDL = DLL + $200

BuildDLL:
          lda # 192
          sec
          sbc StatsLines
          sbc DialogueLines
          sta MapLines
          
          ldy # 0

          .mvayi DLL, # 11
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

StatsDLL:
          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>StatsDL1
          .mvayi DLL, #<StatsDL1

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>StatsDL2
          .mvayi DLL, #<StatsDL2

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>StatsDL3
          .mvayi DLL, #<StatsDL3

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>StatsDL4
          .mvayi DLL, #<StatsDL4

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

          .mvayi DLL, # 7 | DLLHoley8 | DLLDLI
          .mvayi DLL, #>DialogueTopDL
          .mvayi DLL, #<DialogueTopDL

          sty Temp              ; DLL index
          ldy # 0
          .mvaw Pointer, DialogueDL ; end of DialogueDLs
NextDialogueZone:
          ldx # 0
CopyDialogueMidDL:
          lda DialogueMidDL, x
          sta (Pointer), y
          iny
          inx
          cpx #DialogueBottomDL - DialogueMidDL + 1
          bne CopyDialogueMidDL

          sty Swap              ; DialogueDL index

          tya
          sec
          sbc # 13
          tay                   ; go back to string header padding
          
          lda #<Dialogue2Text + 1
          sta (Pointer), y
          iny
          iny                   ; skip over mode byte
          lda #>Dialogue2Text + 1
          sta (Pointer), y
          iny
          lda Dialogue2Text
          sec
          sbc # 1
          eor #$1f              ; encode width
          ora #$20              ; palette 2
          sta (Pointer), y

          ldy Temp              ; DLL index

          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueDL
          .mvayi DLL, #<DialogueDL

          sty Temp              ; DLL index
          ldy Swap              ; DialogueDL index
          tya
          clc
          adc Pointer           ; end of DialogueDLs
          bcc +
          inc Pointer + 1
+
          sta Pointer

          lda Counter
          sec
          sbc # 8
          sta Counter
          beq DoneDialogueMid
          bpl NextDialogueZone

          ;; ;; partial zone only
          ;; lda Temp              ; DLL index
          ;; sec
          ;; sbc # 2
          ;; tax
          ;; lda DLL, x
          ;; adc Counter           ; negative
          ;; sta DLL, x

          ldy Temp              ; DLL index

DoneDialogueMid:
          .mvayi DLL, # 7 | DLLHoley8
          .mvayi DLL, #>DialogueBottomDL
          .mvayi DLL, #<DialogueBottomDL

DoneDialogue:
          lda MapLines
          cmp #$10
          blt DoneMap

          .mvayi DLL, # 15 | DLLHoley16 | DLLDLI
          .mvayi DLL, #>MapFillDL
          .mvayi DLL, #<MapFillDL

          ldx # 10
MapFillDLL:
          .mvayi DLL, # 7
          .mvayi DLL, #>MapFillDL
          .mvayi DLL, #<MapFillDL

          dex
          bne MapFillDLL

          .mvayi DLL, # 0 | DLLDLI
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 11
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

          .mvayi DLL, # 12
          .mvayi DLL, #>BlankDL
          .mvayi DLL, #<BlankDL

DoneMap:

          ldx # 8 * 4
          lda #CoLu(COLGRAY, $0)
          sta BACKGRND

ZeroPalettes:
          sta P0C1, x
          sta P0C2, x
          sta P0C3, x

          dex
          dex
          dex
          dex
          bpl ZeroPalettes

          .WaitForVBlank
          .mva CTRL, #CTRLDMAEnable

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
          stx WSYNC
          stx WSYNC
          .mva P2C2, #CoLu(COLGRAY, $0)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>Font
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGRAY, $c)
          rts

IEndStats:
          .SaveRegs
          lda DialogueLines
          beq DoBeginMap

          jsr BeginDialogue
          .mvaw NMINext, IEndDialogue
          jmp JReturnFromInterrupt

BeginMap:
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGREEN, $8) ; MapBackground FIXME
          stx WSYNC
          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mva CHARBASE, #$ff ; FIXME
          rts

IEndDialogue:
          .SaveRegs
DoBeginMap:
          jsr BeginMap
          .mvaw NMINext, ISwitchToOverscan
          jmp JReturnFromInterrupt

ISwitchToOverscan:
          .SaveRegs
          stx WSYNC
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mvaw NMINext, IBeginStats
          jmp JReturnFromInterrupt
;;; 
          .enc "minifont"
LocationNameString: .ptext "locale name here"

Dialogue2Text:      .ptext "hello, world."
Dialogue3Text:      .ptext "this is a test"
Dialogue4Text:      .ptext "this is only a test"

MapFillDL:
          .DLEnd

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
          .align $1000
Font:
          .binary "UI.art.bin"
          DrawUI = Font + 64

          .align $1000
Items:
          .binary "Items.art.bin"
           
          .include "EndBank.s"
