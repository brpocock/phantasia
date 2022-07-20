;;; Phantasia Source/Banks/Bank02/Bank02.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 02

          .include "StartBank.s"

BankEntry:
          MapStartOffset = $00
          .include "ReifyMap.s"

          .include "Inflate.s"

Maps:
          .word Map_Atsirav
          .word Map_Onetsur

Map_Atsirav:
          .binary "Atsirav.deflate"
Map_Onetsur:
          .binary "Onetsur.deflate"

          .include "EndBank.s"
