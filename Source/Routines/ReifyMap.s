;;; Phantasia Source/Routines/ReifyMap.s
;;;; Copyright © 2022 Bruce-Robert Pocock

ReifyMap:	.block

          ldy CurrentMap
          lda Maps, y


          .bend
