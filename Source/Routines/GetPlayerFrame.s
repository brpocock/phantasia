;;; Phantasia Source/Routines/GetPlayerFrame.s
;;; Copyright © 2022 Bruce-Robert Pocock

GetPlayerFrame:     .block
          ;; XXX actually grab the right frame
          ldx # 0
CopyPlayerSprite:
          lda PlayerTiles + (8 * 3 + 2) * 4 * 16, y
          iny
          sta PlayerSpriteArt, x
          inx
          cpx # 4 * 16
          blt CopyPlayerSprite

          rts

          .bend
