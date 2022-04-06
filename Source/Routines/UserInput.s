;;; Phantasia Source/Routines/UserInput.s
;;; Copyright © 2022 Bruce-Robert Pocock

UserInput:          .block
          lda StickX
          ora StickY
          beq DoneStick

          lda # 0
          sta SpriteFacing

          ldy StickY
          beq DoneUpDown

          lda #PlayerMovementSpeed
          ldx # 0               ; sprite number
          jsr MoveSpriteY

          ldx #P0StickUp
          ldy StickY
          bmi +
          ldx #P0StickDown
+
          stx SpriteFacing
          lda #ActionWalking
          sta SpriteAction

DoneUpDown:
          ldy StickX
          beq DoneStick

          lda #PlayerMovementSpeed * 2
          ldx # 0               ; sprite number
          jsr MoveSpriteX

          ldx #P0StickLeft
          ldy StickX
          bmi +
          ldx #P0StickRight
+
          txa
          ora SpriteFacing
          sta SpriteFacing
          lda #ActionWalking
          sta SpriteAction

DoneStick:
          lda StickX
          ora StickY
          bne Leave

          inc IdleTime
          lda IdleTime
          cmp # FramesPerSecond / 10
          lda #ActionIdle
          sta SpriteAction

Leave:
          jmp GetPlayerFrame    ; tail call
;;; 
ScrollMapLeft:
          ldx MapLeftPixel
          dex
          bpl LeftOK
          txa
          clc
          adc # 8
          tax
          lda MapLeftColumn
          beq LeftOK
          sec
          sbc # 1
          sta MapLeftColumn
LeftOK:
          stx MapLeftPixel
          inc ScreenChangedP
          rts

ScrollMapRight:
          ldx MapLeftPixel
          inx
          cpx # 8
          blt RightOK
          txa
          sec
          sbc # 8
          tax
          lda MapLeftColumn
          cmp # 11
          bge RightOK
          clc
          adc # 1
          sta MapLeftColumn
RightOK:
          stx MapLeftPixel
          inc ScreenChangedP

          rts

ScrollMapUp:
          ldx MapTopRow
          beq DoneUpDown

          dex
          stx MapTopRow
          inc ScreenChangedP

          rts

ScrollMapDown:
          ldx MapTopRow
          inx
          cpx # 20
          bge DoneUpDown
          stx MapTopRow
          inc ScreenChangedP

          rts
          
          .bend
