;;; Phantasia Source/Banks/Bank11/Bank11.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $11
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
