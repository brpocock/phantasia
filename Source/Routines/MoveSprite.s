;;; Phantasia Source/Routines/MoveSprite.s
;;; Copyright © 2022 Bruce-Robert Pocock

MoveSprite:         .macro high, low, fraction, lowSize
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
          bcs DoneMath

          dec \low, x
          lda \low, x
          bpl DoneMath

          lda #\lowSize
          sta \low, x
          dec \high, x
          jmp DoneMath

MovePlus:
          clc
          adc \fraction, x
          sta \fraction, x
          bcc DoneMath

          inc \low, x
          lda \low, x
          cmp #\lowSize
          blt DoneMath

          lda # 0
          sta \low, x
          inc \high, x

DoneMath:

          rts
          .bend
          .endm

MoveSpriteX:
          .MoveSprite SpriteXH, SpriteXL, SpriteXFraction, 8

MoveSpriteY:
          .MoveSprite SpriteYH, SpriteYL, SpriteYFraction, 16
          
