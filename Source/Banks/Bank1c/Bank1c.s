;;; Phantasia Source/Banks/Bank1c/Bank1c.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $1c
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
