;;; Phantasia Source/Common/LastBank.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          .include "StartBank.s"

          * = $c000
          .offs $c000

          ;; This must be kept in sync with Source/Common/JumpTable.s
          ;; (ColdStart must stay the first entry as well)
JumpTable:
          jmp ColdStart
          jmp WarmStart
          jmp IRQ
          jmp NMI
          jmp Break
          jmp FarCall
          jmp FarJump
          jmp FrameService
          jmp TileDisplay
          jmp TileDLI
          jmp ReturnFromInterrupt
          jmp GetPlayerFrame
          jmp IBeginStats
;;; 
ReturnFromInterrupt:
          pla
          tay
          pla
          tax
          pla
          rti

          .include "ColdStart.s"
          ;; falls through to
          .include "WarmStart.s"
          .include "IRQ.s"
          .include "NMI.s"

          * = $c0de             ; XXX for debugging so I can find it

          .include "Break.s"
;;; 
          .include "BeginDialogue.s"
          .include "BeginStats.s"
          .include "CheckPlayerCollision.s"
          .include "CheckDecalCollision.s"
          .include "CheckWall.s"
          .include "FarCall.s"
          .include "FarJump.s"
          .include "FrameService.s"
          .include "FrameWork.s"
          .include "GetPlayerFrame.s"
          .include "GetTileAttributes.s"
          .include "MoveDecal.s"
          .include "MoveDecals.s"
          .include "PlayMusic.s"
          .include "PlaySFX.s"
          .include "PlaySpeech.s"
          .include "ReadInputs.s"
          .include "TileDLI.s"
          .include "TileDisplay.s"
          .include "UserInput.s"
          .include "ScrollMap.s"
          .include "FindMapSource.s"
;;; 
IBeginStats:
          .SaveRegs
          jsr BeginStats
          .mvaw NMINext, IEndStats
          jmp ReturnFromInterrupt

IEndStats:
          .SaveRegs
          lda DialogueLines
          beq DoBeginMap

          jsr BeginDialogue
          .mvaw NMINext, IEndDialogue
          jmp ReturnFromInterrupt

IEndDialogue:
          .SaveRegs
DoBeginMap:
          jmp JTileDLI
;;; 
PlayerTiles:
          ;; does not need to be aligned, since they are copied to RAM
          ;; actually also does not need to be in Bank 7 in that case.
          .binary "Art.PlayerTiles.o"
PlayerEffectsTiles: 
          .binary "Art.PlayerEffectsTiles.o"
;;; 
BitMask:
          .byte $01, $02, $04, $08, $10, $20, $40, $80
;;; 
          .warn format("Bank $%02x ends at $%04x (length $%04x, %d)", BANK, *-1, *-$c001, *-$c001)

          .if * > $ff80
            .error format("Overran Bank $%02x ROM, must end by $ff7f, ended at $%04x", BANK, *-1)
          .fi

          .enc "Unicode"
          .fill ($ff80 - *), format("star-hope.org/games/Phantasia%cBRPocock%c%s%c", 0, 0, BUILD, 0)

          ;; Cart signature space, leave zeros and fix up in build process
          .fill ($fff8 - *), 0

          ;; Country Code
          .byte $ff

          ;; Start (high nybble) of ROM for hashing and whether to show the Atari banner
          ;; I'm opting for $3 = No Atari, vs. $7 = rainbow Atari
          .byte $c3

          ;; NMI Vector
          .word NMI

          ;; RESET Vector
          .word ColdStart

          ;; IRQ Vector
          .word IRQ
