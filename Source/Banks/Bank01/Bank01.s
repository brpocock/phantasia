;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

BankEntry:
          
          
          brk

          .binclude "Font.art.bin"

          .binclude "BigFont.art.bin"

          .binclude "Tileset.art.bin"

          .include "EndBank.s"
