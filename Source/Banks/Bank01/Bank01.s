;;; Phantasia Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .binary "OverworldTiles.o"

          .align $2000
Sprites:
          .binary "OverworldSprites.o"

          .include "EndBank.s"
