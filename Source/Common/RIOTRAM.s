;;; Phantasia Source/Common/RIOTRAM.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          * = $0480

          ;; RIOT cannot be used while MARIA is running
          ;; Keeping it in a block makes it obvious when we try to use it
          ;; so we don't inadvertently put something precious here
RIOT:     .block

          .bend

          .if * > $0500
            .error format("Overran RIOT RAM, must end by $04ff, ended at $%04x", *-1)
          .fi

