;;; Phantasia Source/Banks/Bank13/Bank13.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $13
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
