;;; Phantasia Source/Routines/ReadInputs.s
;;; Copyright © 2022 Bruce-Robert Pocock

ReadInputs:         .block
          ldy # 0
          sty StickX
          sty StickY

          lda SWCHA
          and #P0StickUp
          bne +
          ldx #-1
          stx StickY
          bne DoneUpDown
+
          lda SWCHA
          and #P0StickDown
          bne DoneUpDown
          ldx # 1
          stx StickY
DoneUpDown:
          lda SWCHA
          and #P0StickRight
          bne +
          ldx # 1
          stx StickX
          bne DoneLeftRight
+
          lda SWCHA
          and #P0StickLeft
          bne DoneLeftRight
          ldx #-1
          stx StickX
DoneLeftRight:
          
          lda SWCHB
          and #SWCHBReset
          bne +
          ;; XXX Reset handler
          jmp JColdStart
+
          lda SWCHB
          and #SWCHBSelect
          bne +
          ;; XXX Select handler
          jmp JColdStart
+
          lda SWCHB
          and #SWCHBPause
          bne +
          ;; XXX Pause handler
          jmp JColdStart
+
DoneSWCHB:

          lda ControllerMode
          beq Read7800Controller

MapInput: .macro register, button, p7800
          .block

          buttonIndex := \button - 1

          lda \register
          and #$80
          .if !(\p7800)
          eor #$80
          .fi

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
          ldy # 0
          sty NewButtonI + buttonIndex
          cmp # 0
          beq ButtonDone

          lda HeldButtonI + buttonIndex
          bmi ButtonDone
          inc HeldButtonI + buttonIndex

ButtonDone:

          .bend
          .endm
          
ReadJoy2bController:
          .MapInput INPT4, 1, false
          .MapInput INPT1, 2, false
          .MapInput INPT0, 3, false

          rts

Read7800Controller:
          .MapInput INPT4L, 1, true
          .MapInput INPT4R, 2, true

          lda INPT4
          bmi DoneController

GoOneButton:
          lda #ControllerJoy2b
          sta ControllerMode

          lda # 0
          sta SWBCNT

DoneController:
          rts

          .bend
