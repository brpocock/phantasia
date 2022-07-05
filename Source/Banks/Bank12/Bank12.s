;;; Phantasia Source/Banks/Bank12/Bank12.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $12
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
