;;; Phantasia Source/Banks/Bank03/Bank03.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          BANK = 03

          .include "StartBank.s"

BankEntry:
          MapStartOffset = $10
          .include "LoadMap.s"

          .include "RLE.s"

Maps:
          .word Map_PlayerHouse
          .word Map_AtsiravTownHall

Map_PlayerHouse:
          .binary "PlayerHouse.deflate"
Map_AtsiravTownHall:
          .binary "AtsiravTownHall.deflate"

          .include "EndBank.s"
