;;; Phantasia Source/Routines/LoadMap.s
;;; Copyright © 2022 Bruce-Robert Pocock

LoadMap:  .block
          lda CurrentMap
          ldy # 0

FindMap:
          cmp Maps, y
          beq FoundMap
          iny
          iny
          iny
          jmp FindMap

FoundMap:
          lda Maps + 1, y
          sta Pointer
          lda Maps + 2, y
          sta Pointer + 1

CopyMapDimensions:
          ldy #MapOffsetWidth
          lda (Pointer), y
          sta MapWidth
          ;; ldy #MapOffsetHeight
          iny
          lda (Pointer), y
          sta MapHeight
CopyMapAttributesTable:
          ldy #MapOffsetAttributes
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .AddWord Source, Pointer
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
;;; 
LoadPlayer:
          .mva DecalXH, # 14 ; TODO from Entrance code
          .mvy DecalXL, # 0
          sty DecalXFraction
          .mva DecalYH, # 6 ;  TODO from Entrance code
          sty DecalYL
          sty DecalYFraction
          .mva DecalArtH, #>AnimationBufferPlayerNow
          .mva DecalArtL, #<AnimationBufferPlayerNow

LoadMapDecals:
          ldx # 0
          inx
          stx NumDecals

          ldy # 0
          
          ;; TODO copy decals table

CopyMapExits:
          ldy # MapOffsetExits
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .AddWord Source, Pointer

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
;;; 
DecompressMapTile:
          ;; Decompress map tile data
          ldy #MapOffsetArt
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .AddWord Source, Pointer

          .mvaw Dest, MapArt
          jsr RLE

DecompressMapTileAttributes:
          ;; Decompress pointers to map attribute data
          ldy #MapOffsetTileAttributes
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
          .AddWord Source, Pointer

          .mvaw Dest, MapTileAttributes
          jsr RLE
;;; 
CopyMapNameString:
          ldy #MapOffsetTitle
          lda (Pointer), y
          sta MapNameString
          iny
          ldx # 0
CopyTitleLoop:
          inx
          lda (Pointer), y
          iny
          sta MapNameString, x
          cpx MapNameString
          bne CopyTitleLoop
;;; 
DoneLoadMap:
          clc
          rts

          .bend
