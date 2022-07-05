;;; Phantasia Source/Banks/Bank0a/Bank0a.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0a
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
