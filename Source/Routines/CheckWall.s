;;; Phantasia Source/Routines/CheckWall.s
;;; Copyright © 2022 Bruce-Robert Pocock

CheckWall:          .block
          ;; Decal index in X
          ;; Returns carry clear if no wall or ignore wall

          lda DecalAction, x
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
