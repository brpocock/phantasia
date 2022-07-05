;;; Phantasia Source/Banks/Bank0b/Bank0b.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0b
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
