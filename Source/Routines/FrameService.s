;;; Phantasia Source/Routines/FrameService.s
;;; Copyright © 2022 Bruce-Robert Pocock

FrameService:       .block

          ;; jsr PlayMusic
          ;; jsr PlaySFX
          ;; jsr PlaySpeech

          jsr Clock
          jsr Alarm

          jsr ReadInputs

          rts
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
          jmp (AlarmV)          ; tail call
;;; 
ReadInputs:
          lda SWCHA
          cmp DebounceSWCHA
          beq SWCHAHeld
          eor DebounceSWCHA
          sta NewSWCHA
          jmp DoneSWCHA

SWCHAHeld:
          lda # 0
          sta NewSWCHA
          inc HeldSWCHA
          lda HeldSWCHA
          cmp #FramesPerSecond
          blt DoneSWCHA
          lda #FramesPerSecond
          sta HeldSWCHA
DoneSWCHA:

          lda SWCHB
          cmp DebounceSWCHB
          beq SWCHBHeld
          eor DebounceSWCHB
          sta NewSWCHB
          jmp DoneSWCHB

SWCHBHeld:
          lda # 0
          sta NewSWCHB
          inc HeldSWCHB
          lda HeldSWCHB
          cmp #FramesPerSecond
          blt DoneSWCHB
          lda #FramesPerSecond
          sta HeldSWCHB
DoneSWCHB:

          ldx # 4
Button:
          lda INPT0 - 1, x
          cmp DebounceINPT0 - 1, x
          beq ButtonHeld
          and #$80
          ora #$01
          sta NewINPT0 - 1, x
          jmp DoneButton

ButtonHeld:
          lda # 0
          sta NewINPT0 - 1, x
          inc HeldINPT0 - 1, x
          lda HeldINPT0 - 1, x
          cmp #FramesPerSecond
          blt DoneButton
          lda #FramesPerSecond
          sta HeldINPT0 - 1, x
DoneButton:
          dex
          bne Button

          rts

          .bend
