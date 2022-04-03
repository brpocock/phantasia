;;; Phantasia Source/Common/SysRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          * = $1800
SysRAMLow:

PlayerName:         .fill 8, ?
PlayerSkinColor:    .byte ?
PlayerHairColor:    .byte ?
PlayerClothesColor: .byte ?

          .if * > $2040
            .error format("Overran RAM, must end by $203f, ended at $%04x", *-1)
          .fi

          * = $2100
SysRAMMid:

          .if * > $2140
            .error format("Overran RAM, must end by $213f, ended at $%04x", *-1)
          .fi

          * = $2200
SysRAMHigh:

          .if * > $2800
            .error format("Overran RAM, must end by $27ff, ended at $%04x", *-1)
          .fi

