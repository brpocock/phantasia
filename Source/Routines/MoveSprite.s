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
          lda \high, x
          sta PriorH

          dec \low, x
          lda \low, x
          bpl DoneMinorMinus

          lda #\lowSize
          sta \low, x
          dec \high, x
DoneMinorMinus:
          jsr GetCheckPoint
          .if \isX
            .mva CheckMask, #AttrWallEast
          .else
            .mva CheckMask, #AttrWallSouth
          .fi
          jmp BounceOffTheWalls

MovePlus:
          clc
          adc \fraction, x
          sta \fraction, x
          bcc DoneMath

          lda \low, x
          sta PriorL
          lda \high, x
          sta PriorH

          inc \low, x
          lda \low, x
          cmp #\lowSize
          blt DoneMinorPlus

          lda # 0
          sta \low, x
          inc \high, x
DoneMinorPlus:
          jsr GetCheckPoint
          .if \isX
            inc CheckX
            .mva CheckMask, #AttrWallWest
          .else
            .mva CheckMask, #AttrWallNorth
          .fi

BounceOffTheWalls:
          .if !(\isX)
            lda SpriteXL, x
            cmp #4
            blt +
            inc CheckX
+
          .fi
          .mva CheckMask, #$0f  ; XXX TODO
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
          lda SpriteYH, x
          sta CheckY
          rts
          .bend
