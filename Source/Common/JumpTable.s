;;; Phantasia Source/Common/JumpTable.s
;;;; Copyright © 2022 Bruce-Robert Pocock

          ;; The jump table begins at $c000 and provides access to
          ;; routines in bank 7 (always available) to banks 0-6

          ;; This is basically like the C=KERNAL jump table.

          ;; These constants provide other banks with visibility of it,
          ;; but must be kept in sync manually with the definitions
          ;; in Source/Banks/Bank07/Bank07.s

          JColdStart = $c000
          JWarmStart = $c003
          JIRQ = $c006
          JNMI = $c009
          JBreak = $c00c
          JFarCall = $c00f
          JFarJump = $c012
