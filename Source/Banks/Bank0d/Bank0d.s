;;; Phantasia Source/Banks/Bank0d/Bank0d.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0d
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
