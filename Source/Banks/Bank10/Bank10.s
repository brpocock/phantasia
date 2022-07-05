;;; Phantasia Source/Banks/Bank10/Bank10.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $10
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
