;;; Phantasia Source/Routines/GenerateDrawingList.s
;;; Copyright © 2022 Bruce-Robert Pocock

GenerateDrawingList:          .block
          jsr StartDLL

          jsr StatsDL
          jsr DialogueDL
          jsr MapSectionDL
          jsr WriteOverscanDL

          jsr JGetPlayerFrame
          jsr UpdateDecals
          jmp SwitchToNewDLL    ; tail call
          .bend
