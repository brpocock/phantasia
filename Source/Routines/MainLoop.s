;;; Phantasia Source/Routines/MainLoop.s
;;; Copyright © 2022 Bruce-Robert Pocock

MainLoop: .block
WaitForOverscan:
          bit MSTAT
          bpl WaitForOverscan

WaitForUnpaused:
          bit Paused
          bmi WaitForUnpaused

CheckForAlarm:
          lda AlarmEnabledP
          and AlarmV + 1
          beq AlarmDone

          lda AlarmSeconds
          ora AlarmFrames
          bne AlarmDone

          sta AlarmEnabledP     ; A = 0
          jsr CallAlarmFunction

AlarmDone:
          jsr UpdateDecals

          lda ScreenChangedP
          beq MainLoop

          jsr GenerateDrawingList

          jmp MainLoop

CallAlarmFunction:
          jmp (AlarmV)          ; should RTS when done
          
          .bend
