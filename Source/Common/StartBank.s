;;; Phantasia Source/Common/StartBank.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          .enc "Unicode"
          .cdef $00, $1ffff, 0
          
          .include "7800.s"
          .include "Math.s"
          .include "Macros.s"
          .include "Enums.s"
          .include "Constants.s"
          .include "JumpTable.s"

          .include "RIOTRAM.s"
          .include "SysRAM.s"
          .include "CartRAM.s"

          .weak
            DEMO=false
            PUBLISHER=false
          .endweak

          * = $8000
          .offs -$8000
