;;; Phantasia Source/Routines/CopyToDL.s
;;; Copyright © 2022 Bruce-Robert Pocock

CopyToDL: .block
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
          .bend
