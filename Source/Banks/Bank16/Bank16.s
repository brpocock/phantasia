;;; Phantasia Source/Banks/Bank16/Bank16.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $16
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
