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
DebounceSWCHA:      .byte ?
DebounceSWCHB:      .byte ?
DebounceINPT0:      .byte ?
DebounceINPT1:      .byte ?

HeldSWCHA:      .byte ?
HeldSWCHB:      .byte ?
HeldINPT0:      .byte ?
HeldINPT1:      .byte ?

NewSWCHA:      .byte ?
NewSWCHB:      .byte ?
NewINPT0:      .byte ?
NewINPT1:      .byte ?
;;;
StatsLines:         .byte ?
DialogueLines:     .byte ?
MapLines:           .byte ?
;;; 
          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
