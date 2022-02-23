;;; Phantasia Source/Routines/NMI.s
;;;; Copyright © 2022 Bruce-Robert Pocock

NMI:      .block

          jsr NMINextV
          rti

NMINextV:
          jmp (NMINext)         ; because there's no jsr (indirect)

          .bend
