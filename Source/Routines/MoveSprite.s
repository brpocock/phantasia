;;; Phantasia Source/Routines/MoveSprite.s
;;; Copyright © 2022 Bruce-Robert Pocock

MoveSprite:         .macro high, low, fraction, lowSize, isX
          .block
          ;; X = sprite number
          ;; Y = Δx
          ;; A = speed

          cpy # 0
          bpl MovePlus

MoveMinus:
          sta Swap
          lda \fraction, x
          sec
          sbc Swap
          sta \fraction, x
          bcs DoneMath

          lda \low, x
          sta PriorL
          dec \low, x
          lda \high, x
          sta PriorH
          bpl DoneMinorMinus

          lda #\lowSize
          sta \low, x
          dec \high, x
DoneMinorMinus:
          .if \isX
            .mva CheckMask, #AttrWallEast
          .else
            .mva CheckMask, #AttrWallSouth
          .fi
          jmp DoneMath

MovePlus:
          clc
          adc \fraction, x
          sta \fraction, x
          bcc DoneMath

          lda \low, x
          sta PriorL
          inc \low, x
          lda \high, x
          sta PriorH
          lda \low, x
          cmp #\lowSize
          blt DoneMinorPlus

          lda # 0
          sta \low, x
          inc \high, x
DoneMinorPlus:
          .if \isX
            .mva CheckMask, #AttrWallWest
          .else
            .mva CheckMask, #AttrWallNorth
          .fi

BounceOffTheWalls:
          jsr GetCheckPoint
          .mva CheckMask, #$0f  ; XXX
          jsr CheckWall
          bcc DoneMath

          lda PriorH
          sta \high, x
          lda PriorL
          sta \low, x

DoneMath:
          rts
          .bend
          .endm

MoveSpriteX:
          .MoveSprite SpriteXH, SpriteXL, SpriteXFraction, 8, true

MoveSpriteY:
          .MoveSprite SpriteYH, SpriteYL, SpriteYFraction, 16, false

GetCheckPoint:      .block
          lda SpriteXH, x
          sta CheckX
          lda SpriteXL, x
          cmp # 4
          blt +
          inc CheckX
+
          lda SpriteYH, x
          sta CheckY
          lda SpriteYL, x
          cmp # 2
          blt +
          inc CheckY
+
          rts
          .bend
