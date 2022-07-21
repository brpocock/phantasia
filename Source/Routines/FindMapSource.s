;;; Phantasia Source/Routines/FindMapSource.s
;;; Copyright © 2022 Bruce-Robert Pocock

FindMapSource:      .block
          lda MapTopRow
          sta MapNextY

          lda #<MapArt
          sta Source
          lda #>MapArt
          sta Source + 1

          ;; multiply row × 32 and add to Source pointer
          lda MapTopRow
          asl a
          asl a
          asl a
          bcc +
          inc Source + 1
+
          asl a
          bcc +
          inc Source + 1
          clc
+
          adc Source
          sta Source

          rts

          .bend
