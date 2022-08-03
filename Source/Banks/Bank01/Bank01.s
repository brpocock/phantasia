;;; Phantasia Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .binary "Tileset.OverworldTiles.o"

          .align $2000
Decals:
          .binary "Tileset.OverworldDecals.o"

          .include "EndBank.s"
