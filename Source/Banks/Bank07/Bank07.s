;;; Phantasia Source/Source/Banks/Bank07/Bank07.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = $07

          .include "StartBank.s"

          .if DEMO
            .include "LastBank.s"
          .else
            .include "Bank07Game.s"
          .fi
