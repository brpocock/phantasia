;;; Phantasia Source/Banks/Bank15/Bank15.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $15
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
