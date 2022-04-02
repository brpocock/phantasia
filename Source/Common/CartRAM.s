;;; Phantasia Source/Source/Common/CartRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

;;; Cartridge RAM layout

          * = $4000

GameMode:
          .byte ?
          
SaveGameSlot:
          .byte ?

PlayerName:
          .fill 8, ?


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

DebounceSWCHA:      .byte ?
DebounceSWCHB:      .byte ?
DebounceButtonI:      .byte ?
DebounceButtonII:      .byte ?
DebounceButtonIII:      .byte ?

HeldSWCHA:      .byte ?
HeldSWCHB:      .byte ?
HeldButtonI:      .byte ?
HeldButtonII:      .byte ?
HeldButtonIII:      .byte ?

NewSWCHA:      .byte ?
NewSWCHB:      .byte ?
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

MapRowEnd:          .fill (13 * 2), ?

MapNameString:      .fill 22, ?

ScreenChangedP:     .byte ?
          .align $100
MapArt:
          .fill $400, ?
MapTileAttributes:
          .fill $400, ?
MapAttributes:
          .fill $600, ?
MapSprites:
          .fill $800, ?
MapExits:
          .fill $300, ?


          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
