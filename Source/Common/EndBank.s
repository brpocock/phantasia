;;; Phantasia Source/Common/EndBank.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          .warn format("Bank %d ends at $%04x (length $%04x, %d)", BANK, *-1, *-$8001, *-$8001)
          
          .if * > $c000
            .error format("Bank %02x overran ROM, must end by $bfff, ended at $%04x", BANK, *-1)
          .fi

          .enc "Unicode"
          .fill $c000-*, format("https://star-hope.org/games/Phantasia%cBRPocock%c%s%c", 0, 0, BUILD, 0)

          * = $bfff
          .byte $b9
