;;; Phantasia Source/Routines/MainLoop.s
;;; Copyright © 2022 Bruce-Robert Pocock

MainLoop: .block
          ;; Check alarm for expiry
          lda # 0
          sta AlarmEnabledP
          lda AlarmV + 1
          beq AlarmDone

          lda AlarmSeconds
          ora AlarmFrames
          bne AlarmDone

          jsr CallAlarmFunction

AlarmDone:

          jsr JGetPlayerFrame
          jsr UpdateSprites

          lda ScreenChangedP
          beq MainLoop

          jmp GenerateDrawingList

CallAlarmFunction:
          jmp (AlarmV)          ; should RTS when done
          
          .bend
