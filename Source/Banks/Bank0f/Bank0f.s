;;; Phantasia Source/Banks/Bank0f/Bank0f.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $0f
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
