;;; Phantasia Source/Source/Common/CartRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

;;; Cartridge RAM layout

          * = $4000
;;; 
AnimationBuffer:
          .fill $3000, ?

HoleSum:  .var 0
LastHoleStart:      .var 0
Hole:     .macro offset
          .if * > ( \offset - $40 )
            .error format("Hole overflow at $%04x (limit $%04x)", *, \offset - $40)
          .fi

          * = \offset
          .endm
          * = $4000
;;; 
          .Hole $4040
SpriteXH:
          .fill MaxSprites, ?
SpriteXL:
          .fill MaxSprites, ?
SpriteXFraction:
          .fill MaxSprites, ?
SpriteYH:
          .fill MaxSprites, ?
SpriteYL:
          .fill MaxSprites, ?
SpriteYFraction:
          .fill MaxSprites, ?
SpriteArtH:
          .fill MaxSprites, ?
SpriteArtL:
          .fill MaxSprites, ?

PriorH:   .byte ?
PriorL:   .byte ?
CheckX:   .byte ?
CheckY:   .byte ?
CheckMask:          .byte ?
          HoleSum += * - $4040
;;; 

          .Hole $4140
SpriteDLH:
          .fill MaxSprites, ?
SpriteDLL:
          .fill MaxSprites, ?
SpriteFacing:
          .fill MaxSprites, ?
SpriteController:
          .fill MaxSprites, ?
SpriteDatum:
          .fill MaxSprites, ?
SpriteHP:
          .fill MaxSprites, ?
SpriteAction:
          .fill MaxSprites, ?
SpriteActionParam:
          .fill MaxSprites, ?
          HoleSum += * - $4140
;;; 
          .Hole $4240
GameMode:          .byte ?
SaveGameSlot:          .byte ?
GameFlags:          .fill 32, ?

AnimationFrame:     .byte ?
AnimationFrameFraction:     .byte ?

ClockFrames:        .byte ?
ClockSeconds:       .byte ?
ClockMinutes:       .byte ?
ClockHours:         .byte ?
ClockDays:          .byte ?

AlarmFrames:        .byte ?
AlarmSeconds:       .byte ?
AlarmEnabledP:      .byte ?
AlarmV:   .word ?
          HoleSum += * - 4240
;;; 
          .Hole $4340
ControllerMode:     .byte ?

StickX:   .byte ?
StickY:   .byte ?
IdleTime: .byte ?

DebounceSWCHB:      .byte ?
DebounceButtonI:      .byte ?
DebounceButtonII:      .byte ?
DebounceButtonIII:      .byte ?

HeldButtonI:      .byte ?
HeldButtonII:      .byte ?
HeldButtonIII:      .byte ?

NewButtonI:      .byte ?
NewButtonII:      .byte ?
NewButtonIII:       .byte ?
          HoleSum += * - $4340
;;; 
          .Hole $4440
CurrentBank:        .byte ?
          
CurrentMap:         .byte ?
NextMap:  .byte ?

MapWidth:    .byte ?
MapHeight:   .byte ?
MapBackground:      .byte ?
MapPalettes:        .fill (7 * 3), ?
          
MapTopRow:          .byte ?
MapTopLine:         .byte ?
MapLeftColumn:      .byte ?
MapLeftPixel:       .byte ?

MapNextY:         .byte ?
MapNextX:        .byte ?
SpanWidth:          .byte ?

ScreenNextY:        .byte ?
ScreenNextX:        .byte ?

SelectedPalette:    .byte ?
ActiveDLL:          .byte ?

MapRowEndL:          .fill NumMapRows, ?
MapRowEndH:          .fill NumMapRows, ?

MapNameString:      .fill 22, ?

ScreenChangedP:     .byte ?
          HoleSum += * - $4440
;;; 
          .Hole $4540
          HoleSum += * - $4540
          .Hole $4640
          HoleSum += * - $4640
          .Hole $4740
          HoleSum += * - $4740
          .Hole $4840
          HoleSum += * - $4840
          .Hole $4940
          HoleSum += * - $4940
          .Hole $4a40
          HoleSum += * - $4a40
          .Hole $4b40
          HoleSum += * - $4b40
          .Hole $4c40
          HoleSum += * - $4c40
          .Hole $4d40
          HoleSum += * - $4d40
          .Hole $4e40
          HoleSum += * - $4e40
          .Hole $4f40
          HoleSum += * - $4f40
;;; 
          .Hole $5040
Counter:          .word ?
Counter2:         .word ?

StatsLines:         .byte ?
DialogueLines:     .byte ?
MapLines:           .byte ?
NumSprites:         .byte ?
          HoleSum += * - $5040
;;; 
          .Hole $5140
          HoleSum += * - $5140
          .Hole $5240
          HoleSum += * - $5240
          .Hole $5340
          HoleSum += * - $5340
          .Hole $5440
          HoleSum += * - $5440
          .Hole $5540
          HoleSum += * - $5540
          .Hole $5640
          HoleSum += * - $5640
          .Hole $5740
          HoleSum += * - $5740
          .Hole $5840
          HoleSum += * - $5840
          .Hole $5940
          HoleSum += * - $5940
          .Hole $5a40
          HoleSum += * - $5a40
          .Hole $5b40
          HoleSum += * - $5b40
          .Hole $5c40
          HoleSum += * - $5c40
          .Hole $5d40
          HoleSum += * - $5d40
          .Hole $5e40
          HoleSum += * - $5e40
          .Hole $5f40
          HoleSum += * - $5f40
          .Hole $6040
          HoleSum += * - $6040
          .Hole $6140
          HoleSum += * - $6140
          .Hole $6240
          HoleSum += * - $6240
          .Hole $6340
          HoleSum += * - $6340
          .Hole $6440
          HoleSum += * - $6440
          .Hole $6540
          HoleSum += * - $6540
          .Hole $6640
          HoleSum += * - $6640
          .Hole $6740
          HoleSum += * - $6740
          .Hole $6840
          HoleSum += * - $6840
          .Hole $6940
          HoleSum += * - $6940
          .Hole $6a40
          HoleSum += * - $6a40
          .Hole $6b40
          HoleSum += * - $6b40
          .Hole $6c40
          HoleSum += * - $6c40
          .Hole $6d40
          HoleSum += * - $6d40
          .Hole $6e40
          HoleSum += * - $6e40
          .Hole $6f40
          HoleSum += * - $6f40
;;; 
          * = $7000
MapArt:
          .fill $400, ?
MapTileAttributes:
          .fill $400, ?
MapAttributes:
          .fill $500, ?
MapExits:
          .fill $300, ?

;;; 
          .warn format("Cart RAM has $%04x (%d) bytes free at end, $%04x (%d) bytes in holes", $8000 - *, $8000 - *, HoleSum, HoleSum)

          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
