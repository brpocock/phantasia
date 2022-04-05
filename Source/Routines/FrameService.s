;;; Phantasia Source/Routines/FrameService.s
;;; Copyright © 2022 Bruce-Robert Pocock

FrameService:       .block

          jsr Clock
          jsr ReadInputs
          jsr PlayMusic
          jsr PlaySFX
          jsr PlaySpeech
          jmp Alarm             ; tail call
;;; 
Clock:
          ldy # 0

          inc ClockFrames
          lda ClockFrames
          cmp #FramesPerSecond
          blt ClockDone

          sty ClockFrames
          inc ClockSeconds
          lda ClockSeconds
          cmp # 60
          blt ClockDone

          sty ClockSeconds
          inc ClockMinutes
          lda ClockMinutes
          cmp # 60
          blt ClockDone

          sty ClockMinutes
          inc ClockHours
          lda ClockHours
          cmp # 24
          blt ClockDone

          sty ClockHours
          inc ClockDays
          ;; allow that to roll over … in 256 days.

ClockDone:
          rts
;;; 
Alarm:
          bit AlarmEnabledP
          bpl AlarmDone

          lda AlarmFrames
          beq +
          dec AlarmFrames
          rts
+
          lda AlarmSeconds
          beq AlarmDone

          dec AlarmSeconds
          .mva AlarmFrames, #FramesPerSecond - 1
AlarmDone:
          rts

;;; 

          .bend
