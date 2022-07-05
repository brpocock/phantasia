;;; Phantasia Source/Banks/Bank1d/Bank1d.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $1d
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
