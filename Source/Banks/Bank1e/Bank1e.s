;;; Phantasia Source/Banks/Bank1e/Bank1e.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $1e
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
