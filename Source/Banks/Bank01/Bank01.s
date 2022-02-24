;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

BankEntry:
          
          
          brk

          .binary "Font.art.bin"
          .binary "BigFont.art.bin"

          .include "EndBank.s"
