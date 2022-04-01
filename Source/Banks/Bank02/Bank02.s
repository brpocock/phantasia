;;; Phantasia Source/Source/Banks/Bank02/Bank02.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 02

          .include "StartBank.s"

BankEntry:
          ;; TODO find the map from CurrentMap index
          lda CurrentMap
          asl a
          tay

          lda Maps, y
          sta Pointer
          lda Maps + 1, y
          sta Pointer + 1

CopyMapDimensions:
          ldy #MapOffsetWidth
          lda (Pointer), y
          sta CurrentMapWidth
          ;; ldy #MapOffsetHeight
          iny
          lda (Pointer), y
          sta CurrentMapHeight
CopyMapAttributesTable:
          ldy # MapOffsetAttributes
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .mvaw Dest, MapAttributes - 1

          ldy # 0
          lax (Source), y
          beq DoneAttributes

          iny
CopyAttributesLoop:
          .rept 5
            lda (Source), y
            sta (Dest), y
            iny
          .next

          lda (Source), y
          sta (Dest), y
          ldy # 1

          .Add16 Source, # 6
          .Add16 Dest, # 6

          dex
          bne CopyAttributesLoop

DoneAttributes:

CopyMapSprites:
          ;; TODO copy sprites table

CopyMapExits:
          ldy # MapOffsetExits
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1

          .mvaw Dest, MapExits - 1

          ldy # 0
          lax (Source), y
          beq DoneExits
          iny
CopyExitsLoop:
          lda (Source), y
          sta (Dest), y
          iny
          lda (Source), y
          sta (Dest), y
          iny
          lda (Source), y
          sta (Dest), y
          
          ldy # 1
          .Add16 Source, # 6
          .Add16 Dest, # 6

          dex
          bne CopyExitsLoop

DoneExits:

          ;; Decompress map tile data
          ldy #MapOffsetArt
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .mvaw Dest, MapArt
          jsr RLE

          ;; Decompress pointers to map attribute data
          ldy #MapOffsetTileAttributes
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .mvaw Dest, MapTileAttributes
          jsr RLE
          rts

          .include "RLE.s"

Maps:
          .word Map_Atsirav
          .word Map_Onetsur
          
          .include "Atsirav.s"
          .include "Onetsur.s"

          .include "EndBank.s"
