;;; Phantasia Source/Routines/StatsDL.s
;;; Copyright © 2022 Bruce-Robert Pocock

StatsDL:  .block
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

          rts
          .bend

