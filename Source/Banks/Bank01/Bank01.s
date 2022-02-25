;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

BankEntry:
          lda GameMode
          cmp #ModePublisherPrelude
          beq PublisherPrelude
          
          brk

          .include "PublisherPrelude.s"  ; XXX belongs in bank 6

          .align $800, 0
Font:
          .binary "Font.art.bin"

          .align $800, 0
BigFont:
          .binary "BigFont.art.bin"

          .include "EndBank.s"
