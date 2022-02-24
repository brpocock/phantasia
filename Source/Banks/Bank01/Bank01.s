;;; Phantasia Source/Source/Banks/Bank01/Bank01.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 01

          .include "StartBank.s"

BankEntry:
          
          
          brk

          .include "Font.320A.8.s"
          * = Font + 64                 ; Interleave BigFont between Font
          .include "BigFont.320A.16.s"
          ;; XXX * = Font + 192
          ;; XXX Could include another 64 bytes of interleaved data here

          .include "EndBank.s"
