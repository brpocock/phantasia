;;; Phantasia Source/Routines/StartNewGame.s
;;;; Copyright © 2022 Bruce-Robert Pocock

StartNewGame:	.block
          .mva CTRL, #CTRLDMADisable
          .mva GameMode, #ModeMap

          .mva StatsLines, #$20  ; 4 × 8
          .mva DialogueLines, # 0

          .mva MapLeftColumn, # 0
          .mva MapLeftPixel, # 0
          .mva MapTopRow, # 0
          .mva MapTopLine, # 0

          .mva CurrentMap, #$ff
          .mva CurrentMapBank, #$ff
          .mva NextMap, # 0
          .mva NextMapBank, # 3 ; FIXME look it up
          .mva ActiveDLL, # 0

          .mva PlayerSkinColor, #CoLu(COLBROWN, $7)
          .mva PlayerHairColor, #CoLu(COLYELLOW, $9)
          .mva PlayerClothesColor, #CoLu(COLPURPLE, $7)

          .enc "minifont"
          .mva PlayerNameLength, 4 ; FIXME
          .mva PlayerName, #"b"
          .mva PlayerName + 1, #"a"
          .mva PlayerName + 2, #"k"
          .mva PlayerName + 3, #"u"

          .mva CurrentShield, #ShieldSmall
          .mva CurrentEquip, #EquipKnife
          .mva CurrentHP, #$20
          .mva MaxHP, #$20

          ldx #$ff
          txs
          inx                   ; X = 0
          ldy # 0
          jmp JFarJump

          .bend
