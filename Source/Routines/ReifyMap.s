;;; Phantasia Source/Routines/ReifyMap.s
;;;; Copyright © 2022 Bruce-Robert Pocock

ReifyMap:	.block

DecompressMapData:
          lda CurrentMap
          .if 0 < MapStartOffset
            sec
            sbc #MapStartOffset
          .fi
          asl a
          tay

          lda Maps, y
          sta Source
          lda Maps + 1, y
          sta Source + 1, y

          .mva Dest, #<Map
          .mva Dest + 1, #>Map

          jsr Inflate.Entry

SetUpPlayer:
          .mva SpriteXH, # 47 ; XXX from Entrance code
          .mvy SpriteXL, # 0
          sty SpriteXFraction
          .mva SpriteYH, # 6 ;  XXX from Entrance code
          sty SpriteYL
          sty SpriteYFraction
          .mva SpriteArtH, #>AnimationBufferPlayerNow
          .mva SpriteArtL, #<AnimationBufferPlayerNow

          rts

          .bend
