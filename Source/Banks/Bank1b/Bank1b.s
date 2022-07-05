;;; Phantasia Source/Banks/Bank1b/Bank1b.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $1b
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
