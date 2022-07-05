;;; Phantasia Source/Banks/Bank09/Bank09.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $09
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
