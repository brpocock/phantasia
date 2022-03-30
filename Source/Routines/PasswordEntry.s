;;; Phantasia Source/Routines/PasswordEntry.s
;;;; Copyright © 2022 Bruce-Robert Pocock

PasswordEntry:	.block

          brk
          rts

PasswordDictionary:
          .enc "minifont"
;; (loop repeat 16 collect (subseq (shuffle "012345679.-abcdefghijklmnpqrstuvwxyz!?:") 0 31))
          .text "!hy21namefu.dvizt7sr3w:cqk-?6x5"
          .text "irx:5vke7q26!.-l03cjdtg?pmwyzn9"
          .text "njvbfazxh4cq7di3!e:1.sl?gyt0u2m"
          .text "-tzqm2xc!w1lg?h4p5jknrs.dbe7va9"
          .text "ejv6pc?dnlq7rkx1.-gfw3suamy5:4t"
          .text "t30dzqmgaf.wpk2ju:v!y46-ncih9?7"
          .text "ytx5mig-plcsjeab9n32760:.!uq14v"
          .text "0txsipz64-erhk1ymlngw7a2u9b5!3c"
          .text "3:qvyidk!urc-0m9baz?ng2f4ptl.1s"
          .text "cds6qwp?rfx3:bl!-uza0yvtkmjn.49"
          .text "3?!sqra1.zfcv40:bg5xt7-k962ndmi"
          .text "ufls?!x0d345vye6mh7-.ckpngbwqr9"
          .text "!fr9?1klidq23hx-g6janetv5sz7cup"
          .text "a4gy:16feiwjpl?23b.7v!xzkt5u0-9"
          .text ":vz94-exy0flpju6.m5t!b3?gd17ach"
          .text "sc5btvh6:g4-u3panelk1dzrf2yw!mi"

          .bend
