;;; Phantasia Source/Source/Common/CartRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

;;; Cartridge RAM layout

          * = $4000

GameMode:
          .byte ?
          
SaveGameSlot:
          .byte ?

GameFlags:
          .fill 32, ?

;;; 
ClockFrames:        .byte ?
ClockSeconds:       .byte ?
ClockMinutes:       .byte ?
ClockHours:         .byte ?
ClockDays:          .byte ?

AlarmFrames:        .byte ?
AlarmSeconds:       .byte ?
AlarmEnabledP:      .byte ?
AlarmV:   .word ?
;;; 
ControllerMode:     .byte ?

StickX:   .byte ?
StickY:   .byte ?

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
;;;
StatsLines:         .byte ?
DialogueLines:     .byte ?
MapLines:           .byte ?
;;; 
Counter:          .word ?
Counter2:         .word ?

CurrentBank:        .byte ?
          
CurrentMap:         .byte ?

CurrentMapWidth:    .byte ?
CurrentMapHeight:   .byte ?
MapBackground:      .byte ?
MapPalettes:        .fill (8 * 3), ?
          
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
          .align $100
MapArt:
          .fill $400, ?
MapTileAttributes:
          .fill $400, ?
MapAttributes:
          .fill $600, ?

NumSprites:         .byte ?
MapSpritesXH:
          .fill MaxSprites, ?
MapSpritesXL:
          .fill MaxSprites, ?
MapSpritesXFraction:
          .fill MaxSprites, ?
MapSpritesYH:
          .fill MaxSprites, ?
MapSpritesYL:
          .fill MaxSprites, ?
MapSpritesYFraction:
          .fill MaxSprites, ?
MapSpritesArtH:
          .fill MaxSprites, ?
MapSpritesArtL:
          .fill MaxSprites, ?
MapExits:
          .fill $300, ?
          .align $2000
AnimationBuffer:
          .fill $1000, ?

          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
