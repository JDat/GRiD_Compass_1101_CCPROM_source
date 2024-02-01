match FALSE, _CCPROM_constants_inc
display 'Including contants!', 10

_CCPROM_constants_inc equ TRUE


SEG_FPU                         equ 0xFC00

SEG_MAIN                        equ 0xFC01
SEG_UNKOWN                      equ 0xFE2F
SEG_UNK_MUL                     equ 0xFE3B
SEG_BUBBLE                      equ 0xFE3C
        SEG_BUBBLE_WEIRD        equ 0xFF29

SEG_OSBOOT                      equ 0xFE7E

SEG_OS_DRIVER                   equ 0xFED3
SEG_FONT_ROM                    equ 0xFF32

SEG_PROM_JUMP_TABLE             equ 0xFFED
SEG_RESET                       equ 0xFFFF



SEG_VIDEO_RAM   equ 40h
    video_buff_size equ 2580h

SEG_CCPROM_RAM  equ 0x0298

SEG_DIAG_ROM    equ 0xC000
    diag_entry_point    equ 4h

hwUnknown       equ 0xDFE0
hwBubble        equ 0xDFE8
hwModem         equ 0xDFEC
hwUART          equ 0xDFF0
hwRTCmachineID  equ 0xDFF4
hwGPIB          equ 0xDFF8
regTMS9914_Int0_0               equ     00h
regTMS9914_Int1_1               equ     02h
regTMS9914_Addr_Status_2        equ     04h
regTMS9914_Aux_Cmd_Bus_Status_3 equ     06h
regTMS9914_Addr_4               equ     08h
regTMS9914_Serial_Pool_5        equ     0Ah
regTMS9914_Parallel_Pool_6      equ     0Ch
regTMS9914_Data_7               equ     0Eh

hwKeyboard      equ 0xDFFC
hwDMA           equ 0xE000

; enum enumBlockDeviceCommand, mappedto_1
ddInitialize     = 0
ddGetStatus      = 1
ddOpen           = 2
ddClose          = 3
ddRead           = 4
ddWrite          = 5                    ; XREF: bubbleDrvService:loc_FE3FE/s
ddSeek           = 6

; enum catch_all_constants, mappedto_14
catchReadDelayRepeat equ 0
catchWriteDelayRepeat equ 1
catchReadStatusKey equ 2        ; osKeyHandler+C/s
catchSysControl equ 3           ; setupSystem+75/s
catchRepeat     equ 4
catchKeyboard   equ 5           ; osSelectBootDevice+F1/s ...
catchWatchdog   equ 6           ; GPIBdisableWatchDog?+3/s
catchBlank      equ 7
catchInvert     equ 8
catchDma        equ 9
catchResetWatchDog equ 10
catchSetWatchDog equ 11         ; GPIBenableWatchDog?+3/s
catchReadKbdStatus equ 12 


end match
