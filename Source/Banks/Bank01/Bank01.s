;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

BankEntry:
          
          
          brk

          .include "Font.320A.8.s"
          .include "BigFont.320A.16.s"

          .include "EndBank.s"
