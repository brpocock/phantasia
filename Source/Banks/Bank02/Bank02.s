;;; Phantasia Source/Source/Banks/Bank02/Bank02.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 02

          .include "StartBank.s"

BankEntry:
          ;; TODO find the map from CurrentMap index

          ;; Copy map attributes table
          ;; TODO the source pointer
          .mvaw Pointer, Map_Atsirav.Attributes
          .mvaw Pointer2, MapAttributes - 1

          ldy # 0
          lax (Pointer), y
          beq DoneAttributes

          iny
CopyAttributesLoop:
          .rept 5
            lda (Pointer), y
            sta (Pointer2), y
            iny
          .next

          lda (Pointer), y
          sta (Pointer2), y
          ldy # 1

          .Add16 Pointer, # 6
          .Add16 Pointer2, # 6

          dex
          bne CopyAttributesLoop

DoneAttributes:

          ;; TODO copy sprites table

          ;; TODO the source pointer
          .mvaw Pointer, Map_Atsirav.Exits
          .mvaw Pointer2, MapExits

          ldy # 0
          lax (Pointer), y
          beq DoneExits
          iny
CopyExitsLoop:
          lda (Pointer), y
          sta (Pointer2), y
          iny
          lda (Pointer), y
          sta (Pointer2), y
          iny
          lda (Pointer), y
          sta (Pointer2), y
          
          ldy # 1
          .Add16 Pointer, # 6
          .Add16 Pointer2, # 6

          dex
          bne CopyExitsLoop

DoneExits:

          ;; Decompress map tile data
          ;; TODO the source pointer should come from Map_Atsirav + 2, 3
          .mvaw Pointer, Map_Atsirav.Art
          .mvaw Pointer2, MapArt
          jsr RLE
          ;; jsr Span32 ; expand to 32×32 sizexo

          ;; Decompress pointers to map attribute data
          ;; TODO the source pointer should come from Map_Atsirav + 4, 5
          .mvaw Pointer, Map_Atsirav.TileAttributes
          .mvaw Pointer2, MapTileAttributes
          jsr RLE
          ;; jsr Span32 ; expand to 32×32 size
          rts

          .include "RLE.s"
          .include "Atsirav.s"
          .include "PlayerHouse.s"
          .include "AtsiravTownHall.s"
          .include "Onetsur.s"

          .include "EndBank.s"
