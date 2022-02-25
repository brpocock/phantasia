;;; Phantasia Source/Routines/PublisherPrelude.s
;;;; Copyright © 2022 Bruce-Robert Pocock

PublisherPrelude:	.block

          .mva CTRL, CTRLDMADisable

          ;; Build the initial display lists

          PreludeDLL = SysRAMHigh
          BlankDList = SysRAMHigh + 64
          HelloWorldDList = SysRAMHigh + 128
          HelloWorldString = SysRAMHigh + 192

          .mva BlankDList, #0
          .mva BlankDList + 1, #0

          .mva HelloWorldDList, #<HelloWorldString
          .mva HelloWorldDList + 1, #DLMode(0, 1)
          .mva HelloWorldDList + 2, #>HelloWorldString
          .mva HelloWorldDList + 3, #DLPalWidth(0, 13)
          .mva HelloWorldDList + 4, #(160 - 13*16/2) ; centering

          .mva HelloWorldDList + 5, #0
          .mva HelloWorldDList + 6, #0

          ldx # 13
-
          lda HelloWorldText, x
          sta HelloWorldString, x
          dex
          bne -

          ;; Display List List
          ldy # 0               ; index into the DLL

          ldx # 6               ; scan lines 16 - 112
FillTopBlank:
          lda #16
          sta PreludeDLL, y
          iny
          lda #>BlankDList
          sta PreludeDLL, y
          iny
          lda #<BlankDList
          sta PreludeDLL, y
          iny

          dex
          bne FillTopBlank

HelloWorld:
          lda #16
          sta PreludeDLL, y
          iny
          lda #>HelloWorldDList
          sta PreludeDLL, y
          iny
          lda #<HelloWorldDList
          sta PreludeDLL, y
          iny
          
          ldx # 8               ; remaining zones to fill screen (and then a bit)
FillBottomBlank:
          lda #16
          sta PreludeDLL, y
          iny
          lda #>BlankDList
          sta PreludeDLL, y
          iny
          lda #<BlankDList
          sta PreludeDLL, y
          iny

          dex
          bne FillBottomBlank

          ;; Set up Maria controls
          .mva BACKGRND, CoLu(COLBLUE, $8)
          .mva OFFSET, #0
          .mva CHARBASE, #>BigFont
          .mva DPPL, #>PreludeDLL
          .mva DPPH, #<PreludeDLL
          ;; Turn it on
          .mva CTRL, CTRLDMAEnable


          ;; XXX Hang
Hang:
          jmp Hang

HelloWorldText:
          .enc "minifont"
          .text "hello, world."
          
          .bend
