;;; Phantasia Source/Routines/FrameService.s
;;; Copyright © 2022 Bruce-Robert Pocock

FrameService:       .block

          ;; jsr PlayMusic
          ;; jsr PlaySFX
          ;; jsr PlaySpeech

          jsr Clock
          jsr Alarm
          jmp ReadInputs        ; tail call
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
          dec AlarmSeconds
          lda AlarmSeconds
          beq AlarmNow

          lda #FramesPerSecond - 1
          sta AlarmFrames
AlarmDone:
          rts

AlarmNow:
          lda # 0
          sta AlarmEnabledP
          lda AlarmV + 1
          beq AlarmDone
          jmp (AlarmV)          ; tail call
;;; 

          .bend
