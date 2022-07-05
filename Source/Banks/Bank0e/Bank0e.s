;;; Phantasia Source/Banks/Bank0e/Bank0e.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0e
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
