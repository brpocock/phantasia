;;; Phantasia Source/Routines/FindMapSource.s
;;; Copyright © 2022 Bruce-Robert Pocock

FindMapSource:      .block
          lda MapTopRow
          sta MapNextY

          lda # 0
          sta Source + 1

          ;; multiply row × 32 and add to Source pointer
          lda MapTopRow
          asl a
          asl a
          asl a
          rol Source + 1
          asl a
          rol Source + 1
          asl a
          rol Source + 1
          adc #<MapArt          ; carry is clear
          sta Source
          lda Source + 1
          adc #>MapArt          ; carry from previous ADC
          sta Source + 1

          rts

          .bend
