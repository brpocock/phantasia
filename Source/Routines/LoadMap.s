;;; Phantasia Source/Routines/LoadMap.s
;;; Copyright © 2022 Bruce-Robert Pocock

LoadMap:  .block
          lda CurrentMap
          .if 0 != MapStartOffset
            sec
            sbc #MapStartOffset
          .fi
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

          jsr JGetPlayerFrame

CopyMapSprites:
          lda # 4
          sta MapSpritesXH
          lda # 0
          sta MapSpritesXL
          sta MapSpritesXFraction
          lda # 4
          sta MapSpritesYH
          lda # 0
          sta MapSpritesYL
          sta MapSpritesYFraction
          lda #>PlayerSpriteArt
          sta MapSpritesArtH
          lda #<PlayerSpriteArt
          sta MapSpritesArtL

          ldx # 0
          inx
          stx NumSprites

          ldy # 0
          
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

DecompressMapTile:
          ;; Decompress map tile data
          ldy #MapOffsetArt
          lda (Pointer), y
          sta Source
          iny
          lda (Pointer), y
          sta Source + 1
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
          .mvaw Dest, MapTileAttributes
          jsr RLE

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

DoneLoadMap:
          rts

          .bend
