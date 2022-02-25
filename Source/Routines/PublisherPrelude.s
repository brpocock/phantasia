;;; Phantasia Source/Routines/PublisherPrelude.s
;;;; Copyright © 2022 Bruce-Robert Pocock

PublisherPrelude:	.block

          .WaitForVBlank
          .mva CTRL, CTRLDMADisable

          ;; XXX Build the initial display lists
          PreludeDLL = SysRAMHigh
          BlankDList = SysRAMHigh + $40
          HelloWorldDList = SysRAMHigh + $50
          HelloWorldString = SysRAMHigh + $60

          ;; Blank row display list is empty.
          .mva BlankDList, #0
          .mva BlankDList + 1, #0

          ;; Hello world text display list
          ldy # 0

          ;; ;; Random bit of data to display
          .mvayi HelloWorldDList, #<Font
          .mvayi HelloWorldDList, #DLPalWidth(0, 10)
          .mvayi HelloWorldDList, #>Font
          .mvayi HelloWorldDList, y
          ;; Hello, World string
          .mvayi HelloWorldDList, #<HelloWorldString
          .mvayi HelloWorldDList, #DLMode(0, 1)
          .mvayi HelloWorldDList, #>HelloWorldString
          .mvayi HelloWorldDList, #DLPalWidth(0, 13)
          .mvayi HelloWorldDList, #56
          ;; End of Hello World display list
          .mvayi HelloWorldDList, #0
          .mvay HelloWorldDList, #0

          ;; The actual character data for the string
          ldx # 13
-
          lda HelloWorldText - 1, x
          sta HelloWorldString - 1, x
          dex
          bne -

          ;; Display List List
          ldy # 0

          ldx # 4
FillTopBlank:
          .mvayi PreludeDLL, #10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillTopBlank

          ldx # 4
HelloWorld:
          .mvayi PreludeDLL, #7
          .mvayi PreludeDLL, #>HelloWorldDList
          .mvayi PreludeDLL, #<HelloWorldDList

          dex
          bne HelloWorld
          
          ldx # 10
FillBottomBlank:
          .mvayi PreludeDLL, #15
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList

          dex
          bne FillBottomBlank

          .mvayi PreludeDLL, #10
          .mvayi PreludeDLL, #>BlankDList
          .mvayi PreludeDLL, #<BlankDList


          .WaitForVBlank
          ;; Set up Maria controls
          .mva BACKGRND, #CoLu(COLBLUE, $8)
          ldy # 0
          ldx # 8
FillPals:
          .mvay P0C1, #CoLu(COLYELLOW, $f)
          .mvay P0C2, #CoLu(COLGRAY, $f)
          .mvay P0C3, #CoLu(COLGRAY, $0)
          iny
          iny
          iny
          iny
          dex
          bne FillPals
          .mva CHARBASE, #>BigFont
          .mva DPPL, #<PreludeDLL
          .mva DPPH, #>PreludeDLL
          ;; Turn on the Maria
          .mva CTRL, #CTRLDMAEnable | CTRLRead320AC

          ;; XXX Hang
Hang:
          jmp Hang

HelloWorldText:
          .enc "minifont"
          .text "hello, world." ; 13 characters

          .bend
