;;; Phantasia Source/Common/SysRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          * = $1800
SysRAMLow:

PlayerNameLength:   .byte ?
PlayerName:         .fill 12, ?
PlayerGender:       .byte ?
PlayerSkinColor:    .byte ?
PlayerHairColor:    .byte ?
PlayerClothesColor: .byte ?

CurrentHP:          .byte ?
MaxHP:    .byte ?

EquippedItem:       .byte ?
EquippedShield:     .byte ?
EquippedArmor:      .byte ?

ItemsInventory:     .byte ?
ShieldsInventory:   .byte ?
ConsumablesInventory:         .fill 8, ?
QuestItemsInventory:          .byte ?

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


          BlankDL = SysRAMHigh
          DLL = SysRAMHigh + $02
          DLSpace = SysRAMHigh + $80
          StringsStart = DLSpace + $280
          AltDLL = SysRAMMid
          AltDLSpace = AltDLL + $80
          AltStringsStart = SysRAMHigh + $400
