;;; Phantasia Source/Routines/SwitchToNewDLL.s
;;; Copyright © 2022 Bruce-Robert Pocock

SwitchToNewDLL:     .block
          .WaitForVBlank
          lda ActiveDLL
          beq +
          .mva DPPL, #<DLL
          .mva DPPH, #>DLL
          jmp EnableDMA
+
          .mva DPPL, #<AltDLL
          .mva DPPH, #>AltDLL
EnableDMA:
          .mvaw NMINext, JBeginStats
          .mva CTRL, #CTRLDMAEnable
          .mva ScreenChangedP, # 0

          rts
          .bend
