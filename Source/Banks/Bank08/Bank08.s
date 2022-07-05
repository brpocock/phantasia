;;; Phantasia Source/Banks/Bank08/Bank08.s
;;;; Copyright © 2022 Bruce-Robert Pocock
          BANK = $08
          .include "StartBank.s"
BankEntry:
          brk
          .include "EndBank.s"
