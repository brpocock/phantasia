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
          lda AlarmV + 1
          beq AlarmDone
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

          lda ControllerMode
          beq Read7800Controller

MapInput: .macro register, button
          .block

          buttonIndex := \button - 1

          lda \register
          and #$80
          eor #$80

          cmp DebounceButtonI + buttonIndex
          beq ButtonSame

ButtonChanged:
          sta DebounceButtonI + buttonIndex
          ora # 1
          sta NewButtonI + buttonIndex
          ldy # 0
          sty HeldButtonI + buttonIndex
          geq ButtonDone

ButtonSame:
          cmp # 0
          beq ButtonDone

          lda HeldButtonI + buttonIndex
          bmi ButtonDone
          inc HeldButtonI + buttonIndex

ButtonDone:

          .bend
          .endm
          
ReadJoy2bController:
          .MapInput INPT4, 1
          .MapInput INPT0, 2
          .MapInput INPT1, 3

          rts

Read7800Controller:
          .MapInput INPT0, 1
          .MapInput INPT1, 2

          rts

          .bend
