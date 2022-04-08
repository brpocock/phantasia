;;; Phantasia Source/Source/Common/Enums.s
;;;; Copyright © 2022 Bruce-Robert Pocock


          ModePublisherPrelude = $10
          ModeAuthorPrelude = $11
          ModeTitleScreen = $12

          ModeMap = $80
;;; 
          MapOffsetWidth = 0
          MapOffsetHeight = 1
          MapOffsetArt = 2
          MapOffsetTileAttributes = 4
          MapOffsetAttributes = 6
          MapOffsetSprites = 8
          MapOffsetExits = 10
          MapOffsetTitle = 12
;;; 
          ControllerJoy2b = $01
          Controller7800 = $00
;;; 
          NumMapRows = 13       ; on screen at once
          MaxSprites = 16
;;; 
          PlayerMovementSpeed = $55

          PlayerFacingUp = 4 * 8 * 4
          PlayerFacingLeft = 4 * 8 * 5
          PlayerFacingRight = 4 * 8 * 6
          PlayerFacingDown = 4 * 8 * 7
;;; 
          ActionIdle = $00
          ActionWalking = $01
          ActionFlying = $02
          ActionSwimming = $03
          ActionUseEquipment = $04
          ActionClimbing = $05
          ActionKnockedBack = $06
          ActionWading = $07
;;; 
          ;; Byte 0
          AttrWallNorth = $01
          AttrWallSouth = $02
          AttrWallWest = $04
          AttrWallEast = $08
          AttrWallUnderNorth = $10
          AttrWallUnderSouth = $20
          AttrWallUnderWest = $40
          AttrWallUnderEast = $80
          ;; Byte 1
          ;; XXX what is in bit $01 here? ceiling?
          AttrWade = $02
          AttrSwim = $04
          AttrClimb = $08
          AttrPit = $10
          AttrDoor = $20
          AttrFlammable = $40
          AttrStairsDown = $80
          ;; Byte 2
          AttrIce = $01
          AttrFire = $02
          AttrTriggerMask = $0c
          AttrStepTrigger = $04
          AttrPullTrigger = $08
          AttrPushTrigger = $0c
          AttrIron = $10
          AttrPushMask = $60
          AttrPush = $20
          AttrPushHeavy = $40
          AttrPushVeryHeavy = $60
          AttrExit = $80
;;; 
          ShieldSmall = $01
          ShieldLarge = $02
          EquipKnife = $11
          EquipSword = $12
