;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .include "OverworldTiles.s"

BankEntry:
          cpy # 0
          bne SetUp

          stx WSYNC
          stx WSYNC
          .mva BACKGRND, MapBackground

          .for i := 0, i < 24, i := i + 1
          .mva P0C1 + (i % 3) * 4 + (i - ((i % 3) * 3)), MapPalettes + i
          .next

          .mva CTRL, #CTRLDMAEnable | CTRLRead160AB
          .mva CHARBASE, #>OverworldTiles
          rts

SetUp:
          .mva MapBackground, Tileset + $1000

          ldx # 24
-
          lda Tileset + $1000, x
          sta MapPalettes, x
          dex
          bne -

          rts

          .align $2000
Sprites:
          .include "OverworldSprites.s"

          .include "EndBank.s"
