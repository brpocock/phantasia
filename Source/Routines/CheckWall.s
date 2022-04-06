;;; Phantasia Source/Routines/CheckWall.s
;;; Copyright © 2022 Bruce-Robert Pocock

CheckWall:          .block
          ;; Sprite index in X
          ;; Returns carry clear if no wall or ignore wall

          lda SpriteAction, x
          cmp #ActionFlying
          beq IsOK

          jsr GetTileAttributes
          lda MapAttributes, y
          and CheckMask
          beq IsOK

IsWall:
          sec
          rts
IsOK:
          clc
          rts

          .bend
