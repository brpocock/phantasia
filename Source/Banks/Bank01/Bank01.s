;;; Phantasia Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .binary "Tileset.OverworldTiles.o"

          .align $2000
Sprites:
          .binary "Tileset.OverworldSprites.o"

          .include "EndBank.s"
