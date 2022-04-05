;;; Phantasia Source/Routines/MainLoop.s
;;; Copyright © 2022 Bruce-Robert Pocock

MainLoop: .block
          .WaitForVBlank
          jsr JGetPlayerFrame

          jsr UpdateSprites

          lda ScreenChangedP
          beq MainLoop

          jmp GenerateDrawingList

          .bend
