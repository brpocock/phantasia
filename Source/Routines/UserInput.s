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
          sta DecalFacing

          ldy StickY
          beq DoneUpDown

          lda #PlayerMovementSpeed * 2
          ldx # 0               ; decal number
          jsr MoveDecalY

          ldx #P0StickUp
          ldy StickY
          bmi +
          ldx #P0StickDown
+
          stx DecalFacing
          lda #ActionWalking
          sta DecalAction

DoneUpDown:
          ldy StickX
          beq DoneStick

          lda #PlayerMovementSpeed
          ldx # 0               ; decal number
          jsr MoveDecalX

          ldx #P0StickLeft
          ldy StickX
          bmi +
          ldx #P0StickRight
+
          txa
          ora DecalFacing
          sta DecalFacing
          lda #ActionWalking
          sta DecalAction

DoneStick:
          lda StickX
          ora StickY
          bne DoneIdle

CountIdle:
          inc IdleTime
          lda IdleTime
          cmp # FramesPerSecond / 10
          lda #ActionIdle
          sta DecalAction

DoneIdle:
          lda DecalXH
          sta CheckX
          lda DecalXL
          cmp # 4
          blt +
          inc CheckX
+
          ldx DecalYH
          dex
          lda DecalYL
          beq +
          inx
+
          stx CheckY

          jsr GetTileAttributes

          lda MapAttributes + 1, y
          and #AttrSwim
          beq +
          .mva DecalAction, #ActionSwimming
+
          lda DecalAction
          beq ReadyGetFrame

          lda MapAttributes + 1, y
          and #AttrWade
          beq +
          .mva DecalAction, #ActionWading
+
          lda MapAttributes + 1, y
          and #AttrClimb
          beq +
          .mva DecalAction, #ActionClimbing
+

ReadyGetFrame:
          jsr GetPlayerFrame
;;; 
CheckForScrolling:
          lda DecalXH
          sec
          sbc MapLeftColumn
          cmp # 4               ; left margin, 4 tiles
          blt GoWestYoungMan

          cmp # 16              ; right margin, 4 tiles
          blt EastWestOK

          jsr ScrollMapRight
          jmp EastWestOK

GoWestYoungMan:
          jsr ScrollMapLeft

EastWestOK:
          lda DecalYH
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
