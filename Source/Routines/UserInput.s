;;; Phantasia Source/Routines/UserInput.s
;;; Copyright © 2022 Bruce-Robert Pocock

UserInput:          .block

CheckButtons:
CheckButtonI:
          lda NewButtonI
          bpl DoneButtonI

DoneButtonI:
;;; 
CheckButtonII:
          lda NewButtonII
          bpl DoneButtonII

DoneButtonII:
;;; 
CheckStick:
          lda StickX
          ora StickY
          beq DoneStick

          lda # 0
          sta SpriteFacing

          ldy StickY
          beq DoneUpDown

          lda #PlayerMovementSpeed * 2
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

          lda #PlayerMovementSpeed
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
          bne DoneIdle

          inc IdleTime
          lda IdleTime
          cmp # FramesPerSecond / 10
          lda #ActionIdle
          sta SpriteAction

DoneIdle:
          lda SpriteXH
          sta CheckX
          lda SpriteYH
          sta CheckY
          inc CheckY
          jsr GetTileAttributes
          lda MapAttributes + 1, y
          and #AttrSwim
          beq +
          .mva SpriteAction, #ActionSwimming
+
          lda SpriteAction
          beq ReadyGetFrame

          lda MapAttributes + 1, y
          and #AttrWade
          beq +
          .mva SpriteAction, #ActionWading
+
          lda MapAttributes + 1, y
          and #AttrClimb
          beq +
          .mva SpriteAction, #ActionClimbing
+

ReadyGetFrame:
          jsr GetPlayerFrame

          lda SpriteXH
          sec
          sbc MapLeftColumn
          cmp # 4
          blt GoWestYoungMan

          cmp # 16
          blt EastWestOK

          jsr ScrollMapRight

          jmp EastWestOK

GoWestYoungMan:
          jsr ScrollMapLeft

EastWestOK:
          lda SpriteYH
          sec
          sbc MapTopRow
          cmp # 3
          blt GoNorth

          cmp #NumMapRows - 3
          blt NorthSouthOK

          jsr ScrollMapDown

          jmp NorthSouthOK

GoNorth:
          jsr ScrollMapUp

NorthSouthOK:
          rts

;;; 
ScrollMapLeft:
          lda MapLeftColumn
          beq Return

          ldx MapLeftPixel
          dex
          bpl LeftOK

          ldx # 7
          ldy MapLeftColumn
          dey
          sty MapLeftColumn
LeftOK:
          stx MapLeftPixel
          inc ScreenChangedP
Return:
          rts

ScrollMapRight:
          lda MapWidth
          sec
          sbc # 20
          cmp MapLeftColumn
          bge Return

          ldx MapLeftPixel
          inx
          cpx # 8
          blt RightOK

          ldx # 0
          ldy MapLeftColumn
          iny
          sty MapLeftColumn
RightOK:
          stx MapLeftPixel
          inc ScreenChangedP
          rts

ScrollMapUp:
          ldy MapTopRow
          beq Return

          ldx MapTopLine
          inx
          cpx #$10
          blt UpOK

          ldx # 0
          iny
          sty MapTopRow
UpOK:
          stx MapTopLine
          inc ScreenChangedP
          rts

ScrollMapDown:
          lda MapHeight
          sec
          sbc NumMapRows
          cmp MapTopRow
          bge Return

          ldx MapTopLine
          dex
          bpl DownOK

          ldx #$0f
          ldy MapTopRow
          dey
          sty MapTopRow
DownOK:
          stx MapTopLine
          inc ScreenChangedP
          rts
          
          .bend
