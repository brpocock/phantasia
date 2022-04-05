;;; Phantasia Source/Source/Common/CartRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

;;; Cartridge RAM layout

          * = $4000
;;; 
AnimationBuffer:
          .fill $1000, ?
;;; 
GameMode:          .byte ?
SaveGameSlot:          .byte ?
GameFlags:          .fill 32, ?
;;; 
Counter:          .word ?
Counter2:         .word ?
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
CurrentBank:        .byte ?
          
CurrentMap:         .byte ?
NextMap:  .byte ?

CurrentMapWidth:    .byte ?
CurrentMapHeight:   .byte ?
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
;;; 
          .align $100
MapArt:
          .fill $400, ?
MapTileAttributes:
          .fill $400, ?
MapAttributes:
          .fill $600, ?
;;; 
NumSprites:         .byte ?
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
SpriteDLH:
          .fill MaxSprites, ?
SpriteDLL:
          .fill MaxSprites, ?
;;; 
MapExits:
          .fill $300, ?
;;; 
          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
