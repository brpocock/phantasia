;;; Phantasia Source/Routines/StartNewGame.s
;;;; Copyright © 2022 Bruce-Robert Pocock

StartNewGame:	.block
          .mva GameMode, #ModeMap

          .mva StatsLines, #$20  ; 4 × 8
          .mva DialogueLines, # 0

          .mva MapTopRow, # 2
          .mva MapLeftColumn, # 2
          .mva MapTopLine, # 0
          .mva MapLeftPixel, # 0

          .mva CurrentMap, #$ff
          .mva NextMap, # 0
          .mva ActiveDLL, # 0

          .mva PlayerSkinColor, #CoLu(COLBROWN, $7)
          .mva PlayerHairColor, #CoLu(COLYELLOW, $9)
          .mva PlayerClothesColor, #CoLu(COLPURPLE, $7)

          .enc "minifont"
          .mva PlayerNameLength, 4
          .mva PlayerName, #"b"
          .mva PlayerName + 1, #"a"
          .mva PlayerName + 2, #"k"
          .mva PlayerName + 3, #"u"

          ldx #$ff
          txs
          inx
          ldy # 0
          jmp JFarJump

          .bend
