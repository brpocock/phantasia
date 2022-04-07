;;; Phantasia Source/Routines/MainLoop.s
;;; Copyright © 2022 Bruce-Robert Pocock

MainLoop: .block
WaitForOverscan:
          bit MSTAT
          bpl WaitForOverscan

WaitForUnpaused:
          bit Paused
          bmi WaitForUnpaused
          
          ;; Check alarm for expiry
          lda AlarmEnabledP
          and AlarmV + 1
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

          jsr GenerateDrawingList

          jmp MainLoop

CallAlarmFunction:
          jmp (AlarmV)          ; should RTS when done
          
          .bend
