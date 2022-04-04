;;; Phantasia Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .include "OverworldTiles.s"

          .align $2000
Sprites:
          .include "OverworldSprites.s"

          .include "EndBank.s"
