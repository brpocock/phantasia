; 7800.h
; Version 1.0, 2019/12/13

; This file defines hardware registers and memory mapping for the
; Atari 7800. It is distributed as a companion machine-specific support package
; for the DASM compiler. Updates to this file, DASM, and associated tools are
; available at https://github.com/dasm-assembler/dasm


; ******************** 7800 Hardware Adresses ***************************
;
;       MEMORY MAP USAGE OF THE 7800
;
;	  00 -   1F	TIA REGISTERS
;	  20 -   3F	MARIA REGISTERS
;	  40 -   FF	RAM block 0 (zero page)
;	 100 -  11F	TIA   (mirror of 0000-001f)
;	 120 -  13F	MARIA (mirror of 0020-003f)
;	 140 -  1FF	RAM block 1 (stack)
;	 200 -  21F	TIA   (mirror of 0000-001f)
;	 220 -  23F	MARIA (mirror of 0020-003f)
;	 240 -  27F	???
;	 280 -  2FF	RIOT I/O ports and timers
;	 300 -  31F	TIA   (mirror of 0000-001f)
;	 320 -  33F	MARIA (mirror of 0020-003f)
;	 340 -  3FF	???
;	 400 -  47F	unused address space
;	 480 -  4FF	RIOT RAM
;	 500 -  57F	unused address space
;	 580 -  5FF	RIOT RAM (mirror of 0480-04ff)
;	 600 - 17FF	unused address space
;	1800 - 203F	RAM
;	2040 - 20FF	RAM block 0 (mirror of 0000-001f)
;	2100 - 213F	RAM
;	2140 - 21FF	RAM block 1 (mirror of 0140-01ff)
;	2200 - 27FF	RAM
;	2800 - 2FFF	mirror of 1800-27ff
;	3000 - 3FFF	unused address space
;	4000 - FF7F	potential cartridge address space
;	FF80 - FFF9	RESERVED FOR ENCRYPTION
;	FFFA - FFFF 	6502 VECTORS


;****** 00-1F ********* TIA REGISTERS ******************

INPTCTRL = $01     ;Input control. In same address space as TIA. write-only
VBLANK   = $01     ;VBLANK. D7=1:dump paddle caps to ground.     write-only
INPT0    = $08     ;Paddle Control Input 0                       read-only
INPT1    = $09     ;Paddle Control Input 1                       read-only
INPT2    = $0A     ;Paddle Control Input 2                       read-only
INPT3    = $0B     ;Paddle Control Input 3                       read-only

; ** some common alternate names for INPT0/1/2/3
INPT4B   = $08     ;Joystick 0 Fire 1                            read-only
INPT4A   = $09     ;Joystick 0 Fire 0                            read-only
INPT5B   = $0A     ;Joystick 1 Fire 1                            read-only
INPT5A   = $0B     ;Joystick 1 Fire 0                            read-only
INPT4R   = $08     ;Joystick 0 Fire 1                            read-only
INPT4L   = $09     ;Joystick 0 Fire 0                            read-only
INPT5R   = $0A     ;Joystick 1 Fire 1                            read-only
INPT5L   = $0B     ;Joystick 1 Fire 0                            read-only

INPT4    = $0C     ;Player 0 Fire Button Input                   read-only
INPT5    = $0D     ;Player 1 Fire Button Input                   read-only

AUDC0    = $15     ;Audio Control Channel   0                    write-only
AUDC1    = $16     ;Audio Control Channel   1                    write-only
AUDF0    = $17     ;Audio Frequency Channel 0                    write-only
AUDF1    = $18     ;Audio Frequency Channel 1                    write-only
AUDV0    = $19     ;Audio Volume Channel    0                    write-only
AUDV1    = $1A     ;Audio Volume Channel    1                    write-only

;****** 20-3F ********* MARIA REGISTERS ***************

BACKGRND = $20     ;Background Color                             write-only
P0C1     = $21     ;Palette 0 - Color 1                          write-only
P0C2     = $22     ;Palette 0 - Color 2                          write-only
P0C3     = $23     ;Palette 0 - Color 3                          write-only
WSYNC    = $24     ;Wait For Sync                                write-only
P1C1     = $25     ;Palette 1 - Color 1                          write-only
P1C2     = $26     ;Palette 1 - Color 2                          write-only
P1C3     = $27     ;Palette 1 - Color 3                          write-only
MSTAT    = $28     ;Maria Status                                 read-only
P2C1     = $29     ;Palette 2 - Color 1                          write-only
P2C2     = $2A     ;Palette 2 - Color 2                          write-only
P2C3     = $2B     ;Palette 2 - Color 3                          write-only
          DPPH     = $2C     ;Display List List Pointer High               write-only
          
P3C1     = $2D     ;Palette 3 - Color 1                          write-only
P3C2     = $2E     ;Palette 3 - Color 2                          write-only
P3C3     = $2F     ;Palette 3 - Color 3                          write-only
DPPL     = $30     ;Display List List Pointer Low                write-only
P4C1     = $31     ;Palette 4 - Color 1                          write-only
P4C2     = $32     ;Palette 4 - Color 2                          write-only
P4C3     = $33     ;Palette 4 - Color 3                          write-only
CHARBASE = $34     ;Character Base Address                       write-only
CHBASE   = $34     ;Character Base Address                       write-only
P5C1     = $35     ;Palette 5 - Color 1                          write-only
P5C2     = $36     ;Palette 5 - Color 2                          write-only
P5C3     = $37     ;Palette 5 - Color 3                          write-only
OFFSET   = $38     ;Unused - Store zero here                     write-only
P6C1     = $39     ;Palette 6 - Color 1                          write-only
P6C2     = $3A     ;Palette 6 - Color 2                          write-only
P6C3     = $3B     ;Palette 6 - Color 3                          write-only
CTRL     = $3C     ;Maria Control Register                       write-only
P7C1     = $3D     ;Palette 7 - Color 1                          write-only
P7C2     = $3E     ;Palette 7 - Color 2                          write-only
P7C3     = $3F     ;Palette 7 - Color 3                          write-only


;****** 280-2FF ******* PIA PORTS AND TIMERS ************

SWCHA    = $280    ;P0+P1 Joystick Directional Input             read-write
CTLSWA   = $281    ;I/O Control for SCHWA                        read-write
SWACNT   = $281    ;VCS name for above                           read-write
SWCHB    = $282    ;Console Switches                             read-write
CTLSWB   = $283    ;I/O Control for SCHWB                        read-write
SWBCNT   = $283    ;VCS name for above                           read-write

INTIM    = $284    ;Interval Timer Read                          read-only
TIM1T    = $294    ;Set 1    CLK Interval (838   nsec/interval)  write-only
TIMINT   = $295    ;Interval Timer Interrupt                     read-only
TIM8T    = $295    ;Set 8    CLK Interval (6.7   usec/interval)  write-only
TIM64T   = $296    ;Set 64   CLK Interval (63.6  usec/interval)  write-only
T1024T   = $297    ;Set 1024 CLK Interval (858.2 usec/interval)  write-only
TIM64TI  = $29E    ;Interrupt timer 64T                          write-only

;XM
XCTRL    = $470    ; 7=YM2151 6=RAM@6k 5=RAM@4k 4=pokey@450 3=hsc 2=cart 1=RoF_bank1 0=RoF_bank2
XCTRL1    = $470
XCTRL2    = $478
XCTRL3    = $47c
XCTRL4    = $471
XCTRL5    = $472

; Pokey register relative locations, since its base may be different
; depending on the hardware.
PAUDF0   = $0    ; extra audio channels and frequencies
PAUDC0   = $1
PAUDF1   = $2
PAUDC1   = $3
PAUDF2   = $4
PAUDC2   = $5
PAUDF3   = $6
PAUDC3   = $7
PAUDCTL  = $8    ; Audio Control
PSTIMER  = $9
PRANDOM  = $A    ; 17 bit polycounter pseudo random
PSKCTL   = $F    ; Serial Port control

;;; Constants for creating display lists

;;; DLL Header

          DLLDLI = $80
          DLLHoley16 = $40      ; treat odd 4kiB blocks as zeroes
          DLLHoley8 = $20       ; tread odd 2kiB blocks as zeroes

;;; Set to 7800 mode

          INPTCTRL7800 = $17
          
;;; MARIA CTRL port

          CTRLBW = $80          ; kill color
          CTRLDMAEnable = $40
          CTRLDMADisable = $60
          CTRLCharWide = $10    ; else 1 byte per char
          CTRLBlackBorder = $08 ; else background color
          CTRLKangaroo = $04
          CTRLRead160AB = $00
          CTRLRead320BD = $02
          CTRLRead320AC = $03

;;; TV Standards

          NTSC = $be
          PAL = $ef

;;; Sound chips

          TIA = $de
          POKEY = $ad
          YM = $1e
          
;;; Color Constants

          .switch TV
          .case NTSC
          COLGREY = 0
          COLYELLOW = $10
          COLBROWN = $20
          COLORANGE = $30
          COLRED = $40
          COLMAGENTA = $50
          COLPURPLE = $60
          COLINDIGO = $70
          COLBLUE = $80
          COLTURQUOISE = $90
          COLCYAN = $a0
          COLTEAL = $b0
          COLSEAFOAM = $c0
          COLGREEN = $d0
          COLSPRINGGREEN = $e0
          COLGOLD = $f0
          
          .case PAL
          COLGREY = 0
          COLGOLD = $20
          COLSPRINGGREEN = $30
          COLORANGE = $40
          COLGREEN = $50
          COLRED = $60
          COLTEAL = $70
          COLMAGENTA = $80
          COLCYAN = $90
          COLPURPLE = $a0
          COLTURQUOISE = $b0
          COLINDIGO = $c0
          COLBLUE = $d0
          ;; not actually available on PAL:
          COLYELLOW = COLGOLD
          COLSEAFOAM = COLSPRINGGREEN
          COLBROWN = COLORANGE

          .endswitch

          COLGRAY = COLGREY

          .if NTSC == TV
            FramesPerSecond=60
          .else
            FramesPerSecond=50
          .fi

          ;; read SWCHA
          P0StickUp = $10
          P0StickDown = $20
          P0StickLeft = $40
          P0StickRight = $80
          P0StickCentered = $f0
          P1StickUp = 1
          P1StickDown = 2
          P1StickLeft = 4
          P1StickRight = 8
          P1StickCentered = $f

          ;; read INPT4 (P0), INPT5 (P1) for stick fire button
          PRESSED = $80

          P0Fire = INPT4
          P1Fire = INPT5

          ;; Paddles: TODO.

          ;; Keypad
          ;; Set SWACNT ← $0f (for P1)
          SWACNTKeypadP0 = $f0
          SWACNTKeypadP1 = $0f
          P0KeypadRow1 = $10
          P0KeypadRow2 = $20
          P0KeypadRow3 = $40
          P0KeypadRow4 = $80
          P1KeypadRow1 = 1
          P1KeypadRow2 = 2
          P1KeypadRow3 = 4
          P1KeypadRow4 = 8
          P0KeypadLeftColumn = INPT0
          P0KeypadMiddleColumn = INPT1
          P0KeypadRightColumn = INPT4
          P1KeypadLeftColumn = INPT2
          P1KeypadMiddleColumn = INPT3
          P1KeypadRightColumn = INPT5

          ;; Console
          SWCHBReset = $01
          SWCHBSelect = $02
          SWCHBPause = $08
          SWCHBP0Advanced = $40
          SWCHBP1Advanced = $80
          SWCHBP1TwoButton = $10
          SWCHBP0TwoButton = $04
