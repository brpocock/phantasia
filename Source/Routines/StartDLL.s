;;; Phantasia Source/Routines/StartDLL.s
;;; Copyright © 2022 Bruce-Robert Pocock

StartDLL: .block
          lda NextMap
          cmp CurrentMap
          beq BuildDLL

          sta CurrentMap

          .mva CurrentMapBank, NextMapBank
          
          ;; Decompress the (now-)current map
          ldy # 0
          ldx CurrentMapBank
          jsr JFarCall

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

          iny
          iny
          iny

          .mvapyi DLLTail, # 11 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          rts
          .bend
