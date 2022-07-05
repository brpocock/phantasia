;;; Phantasia Source/Banks/Bank18/Bank18.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $18
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
