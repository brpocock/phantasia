;;; Phantasia Source/Source/Banks/Bank06/Bank06.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 06

          .include "StartBank.s"

BankEntry:
          lda GameMode
          cmp #ModePublisherPrelude
          beq PublisherPrelude
          cmp #ModeTitleScreen
          beq TitleScreen          

          brk

          
          .include "PublisherPrelude.s"  ; XXX belongs in bank 6
          .include "AuthorPrelude.s"  ; XXX belongs in bank 6
          .include "TitleScreen.s"  ; XXX belongs in bank 6

          .align $800, 0
Font:
          .binary "UI.art.bin"

          .align $800, 0
BigFont:
          .binary "BigFont.art.bin"

          .include "EndBank.s"
