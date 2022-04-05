;;; Phantasia Source/Routines/EmitSpan.s
;;; Copyright © 2022 Bruce-Robert Pocock

EmitSpan: .block
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
          .bend
