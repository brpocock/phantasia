;;; Phantasia Source/Routines/DialogueDL.s
;;; Copyright © 2022 Bruce-Robert Pocock

DialogueDL:         .block
          lda StatsLines
          cmp #$21
          bge Done

          lda DialogueLines
          beq Done

          .mvap Dest, DLTail
          sec
          sbc #$10              ; XXX minimum height
          bmi Done

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
          lda (DialogueMidDL, x)
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
Done:
          tya
          .Add16a DLLTail

          rts
          .bend
