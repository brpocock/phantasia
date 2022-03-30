;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

Tileset:
          .include "OverworldTiles.s"

BankEntry:
          ;; Decompress map tile data
          ;; TODO the source pointer should come from Map_Atsirav + 2, 3
          .mvaw Pointer, Map_Atsirav.Art
          .mvaw Pointer2, MapArt
          jsr RLE

          ;; Decompress pointers to map attribute data
          ;; TODO the source pointer should come from Map_Atsirav + 4, 5
          .mvaw Pointer, Map_Atsirav.TileAttributes
          .mvaw Pointer2, MapTileAttributes
          jmp RLE               ; tail call

          .include "RLE.s"
          .include "Atsirav.s"


          
          .align $2000
Sprites:
          .include "OverworldSprites.s"

          .include "EndBank.s"
