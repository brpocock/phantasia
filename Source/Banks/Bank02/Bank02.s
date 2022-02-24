;;; Phantasia Source/Source/Banks/Bank02/Bank02.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 02

          .include "StartBank.s"

BankEntry:
          
          

          brk

          .binary "Tileset.art.bin"

          .include "EndBank.s"
