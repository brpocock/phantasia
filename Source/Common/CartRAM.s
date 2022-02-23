;;; Phantasia Source/Source/Common/CartRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

;;; Cartridge RAM layout

          * = $4000




          
          .if * > $8000
            .error format("Overran Cart RAM, must end by $7fff, ended at $%04x", *-1)
          .fi
