;;; Phantasia Source/Banks/Bank0c/Bank0c.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0c
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
