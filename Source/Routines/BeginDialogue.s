;;; Phantasia Source/Routines/BeginDialogue.s
;;; Copyright © 2022 Bruce-Robert Pocock

BeginDialogue:      .block
          .mva BACKGRND, #CoLu(COLGRAY, $0)
          .mva P0C2, #CoLu(COLGRAY, $9)
          .mva P1C2, #CoLu(COLGRAY, $b)
          .mva P2C2, #CoLu(COLGRAY, $f)
          .mva P3C2, #CoLu(COLGRAY, $d)
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC
          .mva CHARBASE, #>$a000
          stx WSYNC
          rts
          .bend
