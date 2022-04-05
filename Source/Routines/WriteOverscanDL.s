;;; Phantasia Source/Routines/WriteOverscanDL.s
;;; Copyright © 2022 Bruce-Robert Pocock

WriteOverscanDL:    .block
          .mvapyi DLLTail, # 0 | DLLDLI
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 11
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 12
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          ;; These should not be necessary? XXX

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          .mvapyi DLLTail, # 15
          .mvapyi DLLTail, #>BlankDL
          .mvapyi DLLTail, #<BlankDL

          rts
          .bend
