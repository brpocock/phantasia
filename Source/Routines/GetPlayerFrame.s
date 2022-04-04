;;; Phantasia Source/Routines/GetPlayerFrame.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetPlayerFrame:     .block
          ;; XXX actually grab the right frame
          .mvaw Source, PlayerTiles + (8 * 6 + 2) * 4
          .mvaw Dest, AnimationBuffer
          ldx # 16
CopyPlayerSprite:
          ldy # 0
          .rept 4
            lda (Source), y
            sta (Dest), y
            iny
          .next
          inc Source + 1
          inc Dest + 1
          dex
          bne CopyPlayerSprite

          rts

          .bend
