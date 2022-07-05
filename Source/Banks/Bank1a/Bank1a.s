;;; Phantasia Source/Banks/Bank1a/Bank1a.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $1a
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
