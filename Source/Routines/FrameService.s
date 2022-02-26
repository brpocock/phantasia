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

ReadINPT0:
          lda INPT0 
          and #$80
          cmp DebounceINPT0 
          beq INPT0Held
          ora #$01
          sta NewINPT0 
          jmp DoneINPT0

INPT0Held:
          lda # 0
          sta NewINPT0 
          inc HeldINPT0 
          lda HeldINPT0 
          cmp #FramesPerSecond
          blt DoneINPT0
          lda #FramesPerSecond
          sta HeldINPT0 
DoneINPT0:

ReadINPT1:
          lda INPT1 
          and #$80
          cmp DebounceINPT1 
          beq INPT1Held
          ora #$01
          sta NewINPT1 
          jmp DoneINPT1

INPT1Held:
          lda # 0
          sta NewINPT1 
          inc HeldINPT1 
          lda HeldINPT1 
          cmp #FramesPerSecond
          blt DoneINPT1
          lda #FramesPerSecond
          sta HeldINPT1 
DoneINPT1:

          rts

          .bend
