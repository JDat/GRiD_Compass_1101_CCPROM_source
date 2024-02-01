match FALSE, _CCPROM_Main_asm
display 'Including CCPROM Main segment', 10

_CCPROM_Main_asm equ TRUE


;=======================================================================
;segment SEG_MAIN
org 0
DataFrame       dw 298h
tickGranularity dw 10h

interruptTable  db 6
                db 5
                db 4
                db 3
                db 2
                db 1
                db 0
                db 7
interruptMask:   db 40h
                db 20h
word_FC01E      dw 810h

                db 4
                db 2
                db 1
                db 80h

rtcTable        db 1
                db 3
                db 5
                db 7
                db 9
                db 11
                db 13
                db 15
                db 17
                db 19
                db 21
                db 23
                db 25
                db 27
                db 29
                db 31

; =============== S U B R O U T I N E =======================================

; DI = data/command port select (set in entry point)
; AL = data

;keyboardWritePort_CommandPort proc near
keyboardWritePort_CommandPort:
                mov     di, 2           ; DI = Command port

KeyboardReady_SetSegment:
                push    ds
                mov     bx, hwKeyboard
                mov     ds, bx
                ;assume ds:hwKeyboard

.WaitForKeyboardReady_Loop:
                test    byte [keyboardCommandPort], 2 ; 2 = keyboard Ready
                jnz     short .WaitForKeyboardReady_Loop
                mov     [di], al
                pop     ds
                ;assume ds:nothing
                retn
; ---------------------------------------------------------------------------
keyboardWritePort_DataPort:
                mov     di, 0           ; DI = data port
                jmp     short KeyboardReady_SetSegment
;keyboardWritePort_CommandPort endp

; =============== S U B R O U T I N E =======================================
;keyboardSendCommand proc near
keyboardSendCommand:
                push    ds
                mov     ds, word [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                cmp     ah, 1
                jz      short .loc_FC060
                not     al
                and     al, [keyboardCommandLow]
                jmp     short .loc_FC064
; ---------------------------------------------------------------------------

.loc_FC060:
                or      al, [keyboardCommandLow]

.loc_FC064:
                mov     [keyboardCommandLow], al
                call    keyboardWritePort_CommandPort   ; DI = data/command port select (set in entry point)
                                                        ; AL = data
                pop     ds
                ;assume ds:nothing
                retn
;keyboardSendCommand endp

; =============== S U B R O U T I N E =======================================
;NullInterruptRoutine proc far
NullInterruptRoutine:
                iret
;NullInterruptRoutine endp


; =============== S U B R O U T I N E =======================================
;NullRoutine     proc far
NullRoutine:
                retf
;NullRoutine     endp

; =============== S U B R O U T I N E =======================================
;InitInterruptController proc near
InitInterruptController:
        {rmsrc} xor     ax, ax
                mov     ds, ax
                ;assume ds:IDT
        {rmsrc} xor     bx, bx
                mov     cx, 100h

.InitInterruptFillIDTLoop:
                mov     word [bx], NullInterruptRoutine
                mov     word [bx + 2], SEG_MAIN
                add     bx, 4
                loop    .InitInterruptFillIDTLoop
                mov     al, 13h         ; PIC, 8259A.
                                        ; Command register
                out     0, al
                mov     al, 20h ; ' '   ; PIC, 8259A.
                                        ; Data register
                out     2, al
                mov     al, 0Dh         ; PIC, 8259A.
                                        ; Data register
                out     2, al
                mov     al, 0FFh        ; PIC, 8259A.
                                        ; Data register
                out     2, al
                retn
;InitInterruptController endp

; =============== S U B R O U T I N E =======================================
;CpEnableInterrupt proc far
CpEnableInterrupt:

;interruptID     = byte ptr  0Ah
interruptID     equ 0Ah

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     bl, [bp + interruptID]
                mov     bh, 0
                ;mov     al, [cs:bx + interruptMask]
                ;db      00h
                db      2Eh, 8Ah, 87h, 0Ch, 00h    ; hack for "mov al, [cs:interruptMask + bx]"
                not     al
        {rmsrc} mov     ah, al
                in      al, 2           ; get current mask
        {rmsrc} and     al, ah
                out     2, al           ; AND then output it
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;CpEnableInterrupt endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpDisableInterrupt proc far
CpDisableInterrupt:

interruptID     equ 08h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     bl, [bp+interruptID]
                mov     bh, 0
                ;mov     al, [cs:bx+0Ch]
                db      2Eh, 8Ah, 87h, 0Ch, 00h    ; hack for "mov al, [cs:bx+0Ch]"      
        {rmsrc} mov     ah, al
                in      al, 2           ; PIC, 8259A.
                                        ; Data register
        {rmsrc} or      al, ah
                out     2, al           ; PIC, 8259A.
                                        ; Data register
                pop     bp
                pop     ds
                retf    2
;CpDisableInterrupt endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpSetInterrupt(__int32 pRoutine, char interruptID)
;CpSetInterrupt  proc far
CpSetInterrupt:

pRoutine        equ 8
interruptID     equ 0Ch

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
        {rmsrc} xor     bx, bx
                mov     ds, bx
                ;assume ds:IDT
                mov     bl, [bp+interruptID]
                ;mov     bl, [cs:bx+4]
                db      2Eh, 8Ah, 9Fh, 04h, 00h     ; hack for "mov bl, [cs:bx+4]" 
                shl     bx, 1
                shl     bx, 1
                add     bx, 80h
                les     cx, [bx]
                push    es
                les     dx, [bp+pRoutine]
                mov     [bx], dx
                mov     word [bx+2], es
                pop     es
        {rmsrc} mov     bx, cx
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    6
;CpSetInterrupt  endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpEndOfInterrupt proc far
CpEndOfInterrupt:

interruptID     equ 8

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     bh, 0
                mov     bl, [bp+interruptID]
                mov     al, 60h ; '`'
                ;or      al, [cs:interruptTable+bx]
                db      2Eh, 0Ah, 87h, 04h, 00h     ; hack for "or al, [cs:interruptTable+bx]" 
                out     0, al           ; i8259 Write EOI
                pop     bp
                pop     ds
                retf    2
;CpEndOfInterrupt endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpSetKeyHandler(__int32 pRoutine)
;CpSetKeyHandler proc far
CpSetKeyHandler:

pRoutine        equ 8

                push    ds
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                mov     dx, [keyHandlerSeg]
                les     bx, [bp+pRoutine]
        {rmsrc} xchg    bx, [keyHandlerOff]
                mov     word [keyHandlerSeg], es
                mov     es, dx
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;CpSetKeyHandler endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpSetWatchDogHandler(__int32 pRoutine)
;CpSetWatchDogHandler proc far
CpSetWatchDogHandler:

;pRoutine        = dword ptr  8
pRoutine        equ 8
                push    ds
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                mov     dx, word [watchDogHandlerSeg]
                les     bx, [bp+pRoutine]
                xchg    bx, word [watchDogHandlerOff]
                mov     word [watchDogHandlerSeg], es
                mov     es, dx
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;CpSetWatchDogHandler endp

; =============== S U B R O U T I N E =======================================


;OnIrq3_timer    proc far
OnIrq3_timer:

                push    es
                push    ds
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                push    ax
                push    cx
                push    dx
                push    bx
                push    si
                push    di
                push    bp
                mov     al, 3
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                mov     ax, [cs:tickGranularity]
                add     word [sysCounter], ax
                adc     word [sysCounter+2], 0
                call    SEG_MAIN:TimerInterrupt
                pop     bp
                pop     di
                pop     si
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                pop     ds
                ;assume ds:nothing
                pop     es
                iretw
;OnIrq3_timer    endp

; =============== S U B R O U T I N E =======================================


;OnIrq7_Ring     proc far
OnIrq7_Ring:

                push    es
                push    ds
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                push    ax
                push    cx
                push    dx
                push    bx
                push    si
                push    di
                push    bp
                mov     al, 7
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                pop     bp
                pop     di
                pop     si
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                pop     ds
                ;assume ds:nothing
                pop     es
                iretw
;OnIrq7_Ring     endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpSystemTick(char mode)
;CpSystemTick    proc far
CpSystemTick:

MODE        equ 8

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                cmp     byte [bp + MODE], 2
                jnb     short .CpSystemCont
                mov     ax, 3
                push    ax
                cmp     byte [bp + MODE], 0

.CpSystemSomething:
                jz      short .CpSystemOff
                push    ax
                call    SEG_MAIN:CpEnableInterrupt
                jmp     short .CpSystemCont
; ---------------------------------------------------------------------------

.CpSystemOff:
                call    SEG_MAIN:CpDisableInterrupt

.CpSystemCont:

                mov     ax, [cs:tickGranularity]
                pop     bp
                pop     ds
                retf    2
;CpSystemTick    endp

; =============== S U B R O U T I N E =======================================

; ;    CpMachineID: PROCEDURE (pMachineID) CLEAN;
; ;        DCL pMachineID PTR;
; ;
; ;    This will return the 8 byte machine ID
;
; Attributes: bp-based frame

; int __stdcall __far CpMachineID(__int32 pMachineID)
;CpMachineID     proc far                ; CODE XREF: j_CpMachineID↓J
CpMachineID:

pMachineID      equ 8

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                les     di, [bp + pMachineID]
                mov     ax, hwRTCmachineID
                mov     ds, ax          ; DS:SI ^ machine ID
                ;assume ds:hwRTCmachineID
                mov     si, 1           ; machIdStart
                mov     cx, 8           ; loop 8 times

.CpMachineLoop:                          ; CODE XREF: CpMachineID+2E↓j
                mov     al, [si]        ; get 4 bits in high nibble
                add     si, 2           ; SI ^ next 4 bits
                shr     al, 1
                shr     al, 1
                shr     al, 1           ; move into low nibble
                shr     al, 1           ; high nibble gets zero
        {rmsrc} mov     dl, al
                mov     al, [si]        ; get next 4 bits
                add     si, 2
                and     al, 0F0h        ; clear low nibble
        {rmsrc} or      al, dl          ; add in low order nibble
                mov     [es:di], al     ; store in users buffer
                inc     di
                loop    .CpMachineLoop   ; get 4 bits in high nibble
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;CpMachineID     endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpRealTimeClock(char mode)
;CpRealTimeClock proc far                ; CODE XREF: j_CpRealTimeClock↓J
CpRealTimeClock:

MODE            equ 8

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, hwRTCmachineID
                mov     ds, ax
                ;assume ds:hwRTCmachineID
                ;mov     byte ptr unk_DFF5D, 1
                mov     byte [1Dh], 1
                mov     bl, byte [bp + MODE]
                mov     bh, 0
                ;mov     bl, [cs:rtcTable + bx]
                db      2Eh, 8Ah, 9Fh, 14h, 00h    ; hack for "mov bl, [cs:rtcTable + bx]" 
                mov     cx, 5000            ; try this many times : const rtcLoopCount

.CpRealLoop:                             ; CODE XREF: CpRealTimeClock+21↓j
                mov     al, byte [bx]
                and     al, 0Fh
                cmp     al, 0Fh
                loope   .CpRealLoop
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    2
;CpRealTimeClock endp

; =============== S U B R O U T I N E =======================================


;SomeModemRelatedShit proc near
SomeModemRelatedShit:
                push    ds
                mov     ax, hwModem
                mov     ds, ax
                ;assume ds:nothing
                mov     byte [ds:6], 0C0h
                mov     byte [ds:2], 7Fh
                mov     byte [ds:6], 3
                mov     byte [ds:6], 0
                mov     ax, 4
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                pop     ds
                ;assume ds:nothing
                retn
;SomeModemRelatedShit endp

; =============== S U B R O U T I N E =======================================

; ;    CpAddressOf : PROCEDURE PTR CLEAN;
; ;
; ;    This will return the start of the block
; ;    of variables of the prom in ES:BX

;CpAddressOf     proc far
CpAddressOf:
                mov     ax, SEG_CCPROM_RAM
                mov     es, ax
                ;assume es:CCPROM_RAM
                mov     bx, OsProcessQ
                retf
;CpAddressOf     endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpCatchAll(int theData, char command)
;CpCatchAll      proc far
CpCatchAll:

theData         equ 8
command         equ 0Ah

                push    ds
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                mov     ah, byte [bp+theData]
                mov     al, [bp+command]
                cmp     al, catchReadDelayRepeat
                jnz     short .loc_FC26E
                mov     ax, [keyboardDelayRepeat]
                jmp     .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC26E:                              ; CODE XREF: CpCatchAll+11↑j
                cmp     al, catchWriteDelayRepeat
                jnz     short .loc_FC292
                mov     al, 81h
                call    keyboardSendCommand
                mov     al, [bp + theData + 1]
        {rmsrc} mov     dh, al
                call    keyboardWritePort_DataPort ; DI = data port
                mov     al, 82h
                call    keyboardSendCommand
                mov     al, [bp + theData]
        {rmsrc} mov     dl, al
                call    keyboardWritePort_DataPort ; DI = data port
                mov     [keyboardDelayRepeat], dx
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC292:                              ; CODE XREF: CpCatchAll+1B↑j
                cmp     al, catchReadStatusKey
                jnz     short .loc_FC29B
                mov     ax, [keyboardStatusKey]
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC29B:                              ; CODE XREF: CpCatchAll+3F↑j
                cmp     al, catchSysControl
                jnz     short .loc_FC2AB
                mov     bx, hwUnknown
                mov     ds, bx
                ;assume ds:nothing
                and     al, 1
                mov     [ds:6], al
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2AB:                              ; CODE XREF: CpCatchAll+48↑j
                cmp     al, catchRepeat
                jnz     short .loc_FC2B6
                mov     al, 8
                call    keyboardSendCommand
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2B6:                              ; CODE XREF: CpCatchAll+58↑j
                cmp     al, catchKeyboard
                jnz     short .loc_FC2C1
                mov     al, 1
                call    keyboardSendCommand
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2C1:                              ; CODE XREF: CpCatchAll+63↑j
                cmp     al, catchWatchdog
                jnz     short .loc_FC2CC
                mov     al, 2
                call    keyboardSendCommand
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2CC:                              ; CODE XREF: CpCatchAll+6E↑j
                cmp     al, catchBlank
                jnz     short .loc_FC2D2
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2D2:                              ; CODE XREF: CpCatchAll+79↑j
                cmp     al, catchInvert
                jnz     short .loc_FC2D8
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2D8:                              ; CODE XREF: CpCatchAll+7F↑j
                cmp     al, catchDma
                jnz     short .loc_FC2E3
                mov     al, 10h
                call    keyboardSendCommand
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2E3:                              ; CODE XREF: CpCatchAll+85↑j
                cmp     al, catchResetWatchDog
                jnz     short .loc_FC2EE
                mov     al, 0C0h
                call    keyboardWritePort_CommandPort ; DI = data/command port select (set in entry point)
                                        ; AL = data
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2EE:                              ; CODE XREF: CpCatchAll+90↑j
                cmp     al, catchSetWatchDog
                jnz     short .loc_FC2FF
                mov     al, 83h
                call    keyboardWritePort_CommandPort ; DI = data/command port select (set in entry point)
                                        ; AL = data
                mov     al, byte [bp + theData]
                call    keyboardWritePort_DataPort ; DI = data port
                jmp     short .CpCatchDone
; ---------------------------------------------------------------------------

.loc_FC2FF:                              ; CODE XREF: CpCatchAll+9B↑j
                cmp     al, catchReadKbdStatus
                jnz     short .CpCatchDone
        {rmsrc} xor     ax, ax
                mov     al, [ds:0Ch]
                jmp     short $+2
; ---------------------------------------------------------------------------

.CpCatchDone:                            ; CODE XREF: CpCatchAll+16↑j
                                        ; CpCatchAll+3B↑j ...
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;CpCatchAll      endp


; =============== S U B R O U T I N E =======================================


;setupSystem     proc near
setupSystem:
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                ;mov     ax, 30h ; '0'
                mov     ax, ROMfontOffsetConst ; '0'
                mov     [ROMfontOffset], ax ; ROM font related stuff
                mov     ax, SEG_FONT_ROM
                mov     [ROMfontSegment], ax ; ROM font related stuff
                mov     al, 0
                call    keyboardWritePort_CommandPort ; DI = data/command port select (set in entry point)
                                        ; AL = data
                mov     ax, word hwKeyboard
                mov     es, ax
                ;assume es:hwKeyboard
                mov     al, byte [es:keyboardDataPort]
                mov     al, 18h
                mov     [keyboardCommandLow], al
                call    keyboardWritePort_CommandPort ; DI = data/command port select (set in entry point)
                                        ; AL = data
                mov     [keyboardDelayRepeat], word 1905h
                mov     al, 2
                push    ax              ; interruptID
                mov     ax, SEG_MAIN
                push    ax
                mov     ax, word OnIrq2_keyboard
                ;db      0B8h, 0A4h, 03h            ; hack for "mov ax, word OnIrq2_keyboard"
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetInterrupt
                mov     al, 2
                push    ax
                push    ax
                call    SEG_MAIN:CpEnableInterrupt
                mov     [keyHandlerOff], word NullRoutine
                mov     [keyHandlerSeg], word SEG_MAIN
                mov     [watchDogHandlerOff], word NullRoutine
                mov     [watchDogHandlerSeg], word SEG_MAIN
                mov     [keyboardStatusKey], word 0
                mov     [gpibJump], byte 0EAh  ; jmp instruction
                mov     [gpibOff], word GPIBdriver
                mov     [gpibSeg], word SEG_MAIN
                mov     ax, catchSysControl
                push    ax              ; command
                mov     ax, 1
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                mov     ax, 3
                push    ax              ; interruptID
                mov     ax, word SEG_MAIN
                push    ax
                mov     ax, OnIrq3_timer
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetInterrupt
                mov     ax, 7
                push    ax              ; interruptID
                mov     ax, word SEG_MAIN
                push    ax
                mov     ax, OnIrq7_Ring
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetInterrupt
                retn
;setupSystem     endp

; =============== S U B R O U T I N E =======================================


;OnIrq2_keyboard proc far                ; DATA XREF: setupSystem+34↑o
OnIrq2_keyboard:

                push    es
                push    ds
                mov     ds, [cs:DataFrame]
                push    ax
                push    cx
                push    dx
                push    bx
                push    si
                push    di
                push    bp
                mov     al, 2
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                mov     ax, hwKeyboard
                mov     es, ax
                mov     ah, byte [es:keyboardCommandPort]
                mov     al, byte [es:keyboardDataPort]
                cmp     al, 0FFh
                jnz     short .loc_FC3DE
                jmp     short .OnIrq2exit
; ---------------------------------------------------------------------------

.loc_FC3DE:                              ; CODE XREF: OnIrq2_keyboard+26↑j
                cmp     al, 0FEh
                jnz     short .loc_FC3E4
                jmp     short .OnIrq2exit
; ---------------------------------------------------------------------------

.loc_FC3E4:                              ; CODE XREF: OnIrq2_keyboard+2C↑j
                cmp     al, 0FDh
                jnz     short .loc_FC3F5
                mov     ah, 1
                mov     al, 10h
                call    keyboardSendCommand
                call    dword ptr watchDogHandlerOff
                jmp     short .OnIrq2exit
; ---------------------------------------------------------------------------

.loc_FC3F5:                              ; CODE XREF: OnIrq2_keyboard+32↑j
                mov     [keyboardStatusKey], ax
                call    dword ptr keyHandlerOff

.OnIrq2exit:                             ; CODE XREF: OnIrq2_keyboard+28↑j
                                        ; OnIrq2_keyboard+2E↑j ...
                pop     bp
                pop     di
                pop     si
                pop     bx
                pop     dx
                pop     cx
                pop     ax
                pop     ds
                ;assume ds:nothing
                pop     es
                ;assume es:nothing
                iret
;OnIrq2_keyboard endp

; =============== S U B R O U T I N E =======================================
;setupUART       proc near
setupUART:
                push    ds
                mov     ax, hwUART
                mov     ds, ax
                ;assume ds:nothing
                mov     byte ptr ds:4, 18h
                mov     byte ptr ds:6, 18h
                ;mov     ax, hwUnknown
                ;patch for rev4
                mov     ax, 0DFE1h
                ;end patch
                mov     ds, ax
                ;assume ds:nothing
                mov     byte ptr ds:0, 0
                mov     byte ptr ds:2, 0FFh
                mov     byte ptr ds:4, 0FFh
                mov     byte ptr ds:6, 0
                pop     ds
                ;assume ds:nothing
                retn
;setupUART       endp

; =============== S U B R O U T I N E =======================================
;CompassPromStart proc far
CompassPromStart:
                cli
                mov     ax, SEG_DIAG_ROM
                mov     ds, ax
                ;assume ds:diag_ROM
        {rmsrc} xor     bx, bx
                cmp     word [bx], 4554h
                jnz     short .noDiagROM
                cmp     word [bx+2], 5048h
                jnz     short .noDiagROM
                jmp     SEG_DIAG_ROM:diag_entry_point
; ---------------------------------------------------------------------------

.noDiagROM:                              ; CODE XREF: CompassPromStart+C↑j
                                        ; CompassPromStart+13↑j
                mov     ax, SEG_CCPROM_RAM
                mov     es, ax
                ;assume es:CCPROM_RAM
        {rmsrc} xor     di, di          ; Clear CCPROM data area
                mov     al, 0
                mov     cx, 400h
                cld
                rep stosb
                
                mov     ax, SEG_VIDEO_RAM ; '@'
                mov     es, ax
                ;assume es:video_ram
        {rmsrc} xor     di, di          ; Clear video buffer
                mov     al, 0
                mov     cx, video_buff_size
                cld
                rep stosb
                
                mov     ax, 3000h
                mov     ss, ax
                ;assume ss:nothing
                mov     ax, 3000h
        {rmsrc} mov     sp, ax          ; CCPROM stack?
                mov     ds, [cs:DataFrame]
                ;assume ds:CCPROM_RAM
                call    InitInterruptController
                call    setupSystem
                call    setupUART
                call    SomeModemRelatedShit
                call    SEG_MAIN:initMultitasking
                retf
;CompassPromStart endp
                repeat 480h - $
                    db 0
                end repeat
DataFrame1      dw SEG_CCPROM_RAM

                repeat 49Bh - $
                    db 0
                end repeat

include 'tasktext.asm'
                repeat 0DD0h - $
                    db 00h
                end repeat
                
DataFrame_0     dw  SEG_CCPROM_RAM

include 'memmgr.asm'
                repeat 1230h - $
                    db 00h
                end repeat

include 'queue.asm'
                repeat 1520h - $
                    db 00h
                end repeat

; =============== S U B R O U T I N E =======================================
; int __stdcall __far MakeChecksum(int len, __int32 pBuf)
;MakeChecksum    proc far
MakeChecksum:

len             equ     06h
pBuf            equ     08h

                push    bp
        {rmsrc} mov     bp, sp
                mov     cx, [bp+len]    ; get length
                mov     ax, 0           ; init sum
                jcxz    short .Done      ; done if length = 0
                les     bx, [bp+pBuf]   ; get pointer
                mov     dl, 0           ; assume evnn ; evnn   EQU 0    ; length is evnn
                shr     cx, 1           ; cx := cx/2
                jnb     short .EvenLength ; done if length = 1
                mov     dl, 1           ; odd    EQU 1    ; length is odd

.EvenLength:                             ; CODE XREF: MakeChecksum+12↑j
                jcxz    short .CheckOdd  ; done if length = 1

.CheckLoop:                              ; CODE XREF: MakeChecksum+1D↓j
                add     ax, [es:bx]     ; subtotal
                inc     bx
                inc     bx              ; bump pointer
                loop    .CheckLoop       ; subtotal

.CheckOdd:                               ; CODE XREF: MakeChecksum:EvenLength↑j
        {rmsrc} and     dl, dl          ; is dl = 0 ?
                jz      short .Done
                mov     dl, [es:bx]     ; if odd then add in
                mov     dh, 0           ; last byte
        {rmsrc} add     ax, dx

.Done:                                   ; CODE XREF: MakeChecksum+9↑j
                                        ; MakeChecksum+21↑j
                pop     bp
                retf    6               ; 6 bytes of parameters
;MakeChecksum    endp

                repeat 1550h - $
                    db 00h
                end repeat

; =============== S U B R O U T I N E =======================================
;SetException    proc near
SetException:
                pop     cx
                pop     bx
                pop     si
        {rmsrc} mov     ax, si
                shl     ax, 1
                shl     si, 1
                shl     si, 1
                shl     si, 1
        {rmsrc} add     si, ax
                mov     ax, SEG_CCPROM_RAM
                mov     es, ax
                ;assume es:CCPROM_RAM
                ;mov     word es:RATBL.sip[si], cx
                mov     [es:si+RATBL], cx                       ;must be "mov word es:RATBL.sip[si], cx"
                ;mov     word es:RATBL.scs[si], bx
                mov     [es:si+RATBL+02h], bx                   ;must be "mov word es:RATBL.scs[si], bx"
                ;mov     word es:RATBL.ssp[si], sp
                mov     [es:si+RATBL+04h], sp                   ;must be "mov word es:RATBL.ssp[si], sp"
                ;mov     word es:RATBL.sbp[si], bp
                mov     [es:si+RATBL+06h], bp                   ;must be "mov word es:RATBL.sbp[si], bp"
                ;mov     word es:RATBL.sds[si], ds
                mov     word [es:si+RATBL+08h], ds              ;must be "mov word es:RATBL.sds[si], ds"
                ;and     ax, 0
                db      25h, 00h, 00h                           ;hack for "and ax, 0"
                ;jmp     dword ptr es:RATBL.sip[si]
                jmp     dword [es:si+RATBL]
;SetException    endp

; =============== S U B R O U T I N E =======================================
;Exception       proc far
Exception:
                pop     cx              ; RETURN ADDRESS OFFSET
                pop     bx              ; RETURN ADDRESS SEGMENT
                pop     ax              ; CODE
                pop     si              ; EXCEPTION NUMBER
                ;cmp     ax, 0
                db      3Dh, 00h, 00h                           ;hack for "cmp ax, 0"
                jz      short .OKCODE
        {rmsrc} mov     dx, ax
        {rmsrc} mov     ax, si
                shl     ax, 1
                shl     si, 1
                shl     si, 1
                shl     si, 1
        {rmsrc} add     si, ax
                mov     ax, SEG_CCPROM_RAM
                mov     es, ax
                ;mov     sp, es:RATBL.ssp[si]
                mov     sp, [es:si+RATBL+04h]                   ;must be "mov sp, es:RATBL.ssp[si]"
                ;mov     bp, es:RATBL.sbp[si]
                mov     bp, [es:si+RATBL+06h]                   ;must be "mov bp, es:RATBL.sbp[si]"
                ;mov     ds, es:RATBL.sds[si]
                mov     ds, word [es:si+RATBL+08h]
        {rmsrc} mov     ax, dx
                ;jmp     dword  es:RATBL.sip[si]
                jmp     dword  [es:si+RATBL]                    ;must be "jmp dword  es:RATBL.sip[si]"
; ---------------------------------------------------------------------------

.OKCODE:                                 ; CODE XREF: Exception+7↑j
                push    bx
                push    cx
                retf
;Exception       endp

                repeat 15C0h - $
                    db 00h
                end repeat

; =============== S U B R O U T I N E =======================================
;BCM_related_stuff proc far              ; bubbleDrvReadWrite?+109↓P
BCM_related_stuff:

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     bx, unk_2B40
                mov     si, 2
                pop     di
                pop     ax
                pop     cx
                pop     dx
                pop     word [bx]
                pop     word [bx+si]
                pop     word [bx+4]
                pop     word [bx+6]
                pop     word [bx+8]
                pop     word [bx+si+8]
                pop     word [bx+0Ch]
                push    dx
                push    cx
                push    ax
                push    di
                call    MaskIrq5
                mov     ax, hwBubble
                mov     es, ax
                ;assume es:nothing
                push    ds
                lds     si, [bx+8]
                ;assume ds:nothing
                pop     ds
                mov     [bx+0Eh], si
                mov     dx, [bx+6]
                mov     [bx+10h], dx
                mov     ax, [bx+0Ch]
                ;cmp     ax, 4
                db      3Dh, 04h, 00h                           ;hack for "cmp ax, 4"
                jz      short .loc_FD623
                ;cmp     ax, 5
                db      3Dh, 05h, 00h                           ;hack for "cmp ax, 5"
                jz      short .loc_FD628
                mov     ax, 17h
                jmp     short .loc_FD679
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FD623:                              ; CODE XREF: BCM_related_stuff+46↑j
                mov     al, 12h
                jmp     short .loc_FD62A ; Bubble CMD: Write data?
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FD628:                              ; CODE XREF: BCM_related_stuff+4B↑j
                mov     al, 13h

.loc_FD62A:                              ; CODE XREF: BCM_related_stuff+55↑j
                mov     [es:2], al        ; Bubble CMD: Write data?
                mov     cx, 0FFFFh

.loc_FD631:                              ; CODE XREF: BCM_related_stuff+67↓j
                mov     al, [es:2]
                test    al, 80h
                loope   .loc_FD631
                jcxz    short .loc_FD63E
                jmp     short .loc_FD644
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FD63E:                              ; CODE XREF: BCM_related_stuff+69↑j
                mov     ax, 1C3h
                jmp     short .loc_FD679
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FD644:                              ; CODE XREF: BCM_related_stuff+6B↑j
                mov     ax, [bx+0Ch]
                db      3Dh, 05h, 00h                           ;hack for "cmp ax, 5"
                jnz     short .loc_FD664
                call    BMCDoFifoTransfer

.loc_FD64F:                              ; CODE XREF: BCM_related_stuff+92↓j
        {rmsrc} or      ax, ax
                jnz     short .loc_FD679
                mov     cx, [bx+6]
        {rmsrc} or      cx, cx
                jz      short .loc_FD679
                cmp     cx, 16h
                jnb     short .loc_FD664
                call    BMCDoFifoTransfer
                jmp     short .loc_FD64F
; ---------------------------------------------------------------------------

.loc_FD664:                              ; CODE XREF: BCM_related_stuff+7A↑j
                                        ; BCM_related_stuff+8D↑j
                push    bx
                call    UnmaskIrq5
                mov     ax, 1388h
                push    word [bx+4] ; sid
                push    ax              ; timeLimit
                les     di, [bx]
                ;assume es:nothing
                push    es
                push    di              ; pError
                call    SEG_MAIN:CpWait
                pop     bx

.loc_FD679:                              ; CODE XREF: BCM_related_stuff+50↑j
                                        ; BCM_related_stuff+71↑j ...
                mov     cx, [bx+10h]
                mov     [bx+6], cx
                mov     si, [bx+0Eh]
                mov     di, [bx+8]
                mov     [bx+8], si
        {rmsrc} sub     di, si
        {rmsrc} mov     ax, di
                pop     bp
                pop     ds
                retf
;BCM_related_stuff endp ; sp-analysis failed


; =============== S U B R O U T I N E =======================================
;MaskIrq5        proc near               ; OnIrq5_bubble+39↓p
MaskIrq5:
                push    bx
                mov     ax, 5
                push    ax
                call    SEG_MAIN:CpDisableInterrupt
                pop     bx
                retn
;MaskIrq5        endp

; =============== S U B R O U T I N E =======================================
;UnmaskIrq5      proc near
UnmaskIrq5:
                push    bx
                mov     ax, 5
                push    ax
                mov     ax, 0
                push    ax
                call    SEG_MAIN:CpEnableInterrupt
                pop     bx
                retn
;UnmaskIrq5      endp

; =============== S U B R O U T I N E =======================================
;BMCDoFifoTransfer proc near             ; BCM_related_stuff+8F↑p ...
BMCDoFifoTransfer:

                push    ds
                mov     cx, [bx+6]
                mov     dx, [bx+0Ch]
                lds     si, [bx+8]
                mov     ax, hwBubble
                mov     es, ax
                ;assume es:nothing
                cmp     dx, 5
                jnz     short .loc_FD6E2

.loc_FD6BF:                              ; CODE XREF: BMCDoFifoTransfer+2B↓j
                mov     al, [es:2]
                test    al, 80h
                jnz     short .loc_FD6CA
                jmp     short .loc_FD6DA
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FD6CA:                              ; CODE XREF: BMCDoFifoTransfer+1A↑j
                test    al, 1
                jz      short .loc_FD6D8
                mov     al, [si]
                mov     [es:0], al
                inc     si
                dec     cx
                jnz     short .loc_FD6BF

.loc_FD6D8:                              ; CODE XREF: BMCDoFifoTransfer+21↑j
                                        ; BMCDoFifoTransfer+47↓j ...
        {rmsrc} xor     ax, ax

.loc_FD6DA:                              ; CODE XREF: BMCDoFifoTransfer+1C↑j
                                        ; BMCDoFifoTransfer+43↓j
                pop     ds
                mov     [bx+8], si
                mov     [bx+6], cx
                retn
; ---------------------------------------------------------------------------

.loc_FD6E2:                              ; CODE XREF: BMCDoFifoTransfer+12↑j
                                        ; BMCDoFifoTransfer+51↓j
                mov     al, [es:2]
                test    al, 80h
                jnz     short .loc_FD6F0
                test    al, 1
                jnz     short .loc_FD6F4
                jmp     short .loc_FD6DA
; ---------------------------------------------------------------------------

.loc_FD6F0:                              ; CODE XREF: BMCDoFifoTransfer+3D↑j
                test    al, 1
                jz      short .loc_FD6D8

.loc_FD6F4:                              ; CODE XREF: BMCDoFifoTransfer+41↑j
                mov     al, [es:0]
                mov     [si], al
                inc     si
                dec     cx
                jnz     short .loc_FD6E2
                jmp     short .loc_FD6D8
;BMCDoFifoTransfer endp

; =============== S U B R O U T I N E =======================================
;OnIrq5_bubble   proc far                ; DATA XREF: bubbleDrvInit?+1E↓o
OnIrq5_bubble:

                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                push    bp
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     bx, 1C0h
                push    bx
                mov     ax, 5
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                pop     bx
                call    BMCDoFifoTransfer
        {rmsrc} or      ax, ax
                jnz     short .loc_FD738

.loc_FD723:                              ; CODE XREF: OnIrq5_bubble+36↓j
                mov     cx, [bx+6]
        {rmsrc} or      cx, cx
                jz      short .loc_FD738
                cmp     cx, 16h
                jnb     short .loc_FD751
                call    BMCDoFifoTransfer
        {rmsrc} or      ax, ax
                jnz     short .loc_FD738
                jmp     short .loc_FD723
; ---------------------------------------------------------------------------
.loc_FD738:                              ; CODE XREF: OnIrq5_bubble+21↑j
                                        ; OnIrq5_bubble+28↑j ...
                nop
                call    MaskIrq5
                push    bx
                mov     ax, 1
        {rmsrc} xor     cx, cx
                push    word [bx+4] ; sid
                push    ax              ; mode
                push    cx              ; note
                les     di, [bx]
                ;assume es:nothing
                push    es
                push    di              ; pError
                call    SEG_MAIN:CpSignal
                pop     bx

.loc_FD751:                              ; CODE XREF: OnIrq5_bubble+2D↑j
                pop     bp
                pop     es
                pop     ds
                ;assume ds:nothing
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                iret
;OnIrq5_bubble   endp

                repeat 1750h - $
                    db 00h
                end repeat

GBiBversionString       db      'GPiB 1.1 11/19/82'

; =============== S U B R O U T I N E =======================================
;GPIBdriver      proc far                ; OsDskDriver+91↓P ...
GPIBdriver:
; FUNCTION CHUNK AT 17FB SIZE 00000349 BYTES
; FUNCTION CHUNK AT 1D03 SIZE 000000D6 BYTES

                push    ds
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     al, [byte_2B6C]
                cmp     al, 0FFh
                jnz     short .loc_FD797
                push    [gsid]             ; sid
                mov     cx, 0FFFFh
                push    cx              ; timeLimit
                push    bp
        {rmsrc} mov     bp, sp
                mov     cx, [bp+0Ch]
                mov     bx, [bp+0Eh]
                pop     bp
                push    bx
                push    cx              ; pError
                call    SEG_MAIN:CpWait

.loc_FD797:                              ; CODE XREF: GPIBdriver+B↑j
                pop     bx
                pop     cx
                pop     dx
                pop     word [gpError]
                pop     word [gpError+2]
                pop     word [dword_2B62]
                pop     word [dword_2B62+2]
                pop     [word_2B60]
                push    dx
                push    cx
                push    bx
                push    bp
        {rmsrc} mov     bp, sp
                call    GPIBgetState
        {rmsrc} or      ax, ax
                jnz     short loc_FD80B
                mov     ax, [word_2B60]
                ;cmp     ax, 0
                db      3Dh, 00h, 00h                           ;hack for "cmp ax, 0"
                jz      short loc_FD83B
                mov     bl, [byte_2B70]
                cmp     bl, 0FFh
                jz      short .loc_FD7D5
                mov     bl, [byte_2B6C]
                cmp     bl, 0FFh
                jz      short loc_FD7D8

.loc_FD7D5:                              ; CODE XREF: GPIBdriver+59↑j
                jmp     short loc_FD83B
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

loc_FD7D8:                              ; CODE XREF: GPIBdriver+62↑j
                                        ; GPIB_SendByte?-2F3↓j ...
                ;cmp     ax, 4
                db      3Dh, 04h, 00                            ;hack for "cmp ax, 4"
                jnz     short .loc_FD7E0
                jmp     loc_FD8E0
; ---------------------------------------------------------------------------

.loc_FD7E0:                              ; CODE XREF: GPIBdriver+6A↑j
                ;cmp     ax, 5
                db      3Dh, 05h, 00                            ;hack for "cmp ax, 5"
                jnz     short .loc_FD7E8
                jmp     loc_FDA2A
; ---------------------------------------------------------------------------

.loc_FD7E8:                              ; CODE XREF: GPIBdriver+72↑j
                ;cmp     ax, 14h
                db      3Dh, 14h, 00                            ;hack for "cmp ax, 14h"
                jnz     short .loc_FD7F0
                jmp     loc_FDD13
; ---------------------------------------------------------------------------

.loc_FD7F0:                              ; CODE XREF: GPIBdriver+7A↑j
                ;cmp     ax, 15h
                db      3Dh, 15h, 00                            ;hack for "cmp ax, 15h"
                jnz     short .loc_FD805
                push    ds
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                les     di, [bx+0Fh]
                mov     byte [es:di], 2
                pop     ds
                jmp     loc_FDD13
; ---------------------------------------------------------------------------

.loc_FD805:                              ; CODE XREF: GPIBdriver+82↑j
                mov     ax, 17h
                call    GPIBsetState
;GPIBdriver      endp ; sp-analysis failed

; START OF FUNCTION CHUNK FOR GPIB_SendByte?
;   ADDITIONAL PARENT FUNCTION GPIBdriver

loc_FD80B:                              ; CODE XREF: GPIBdriver+48↑j
                                        ; GPIB_SendByte?-31D↓j ...
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                call    GPIBgetState
                push    di
                push    es
                push    ax
                mov     bx, [gsid]
                mov     cx, 1           ; char
        {rmsrc} xor     ax, ax
                call    GPIBsignal
                pop     ax
                pop     es
                pop     di
        {rmsrc} or      ax, ax
                jz      short .loc_FD82C
                mov     [es:di], ax

.loc_FD82C:                              ; CODE XREF: GPIB_SendByte?-361↑j
                call    GPIBgetState
        {rmsrc} or      ax, ax
                jz      short .loc_FD838
                mov     byte [byte_2B70], 0FFh

.loc_FD838:                              ; CODE XREF: GPIB_SendByte?-357↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
; ---------------------------------------------------------------------------

loc_FD83B:                              ; CODE XREF: GPIBdriver+50↑j
                                        ; GPIBdriver:loc_FD7D5↑j
                mov     ax, 0
                call    GPIBsetState
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB
                mov     di, regTMS9914_Aux_Cmd_Bus_Status_3
                mov     byte [es:di], 80h
                mov     byte [es:di], 8Fh
                mov     byte [es:di], 0
                mov     cl, 78h ; 'x'
                shr     cl, cl
                mov     byte [es:di], 0Fh
                mov     byte [es:di], 8Ah
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jz      short .loc_FD86D
                call    GPIBsetState
                jmp     short loc_FD80B
; ---------------------------------------------------------------------------

.loc_FD86D:                              ; CODE XREF: GPIB_SendByte?-322↑j
                mov     byte [es:regTMS9914_Data_7], 14h
                mov     ax, 500
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                cmp     byte [ds:1ECh], 0FFh
                jnz     short .loc_FD898
                cmp     byte [ds:1F0h], 0FFh
                jz      short .loc_FD88D
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FD88D:                              ; CODE XREF: GPIB_SendByte?-300↑j
                mov     byte [ds:1F0h], 0
                mov     ax, [ds:1E0h]
                jmp     loc_FD7D8
; ---------------------------------------------------------------------------
.loc_FD898:                              ; CODE XREF: GPIB_SendByte?-307↑j
                mov     byte [ds:1ECh], 0FFh
                mov     ax, 2D0h
                mov     [ds:23Ch], ax
                push    ax
                call    SEG_MAIN:CpCreateSemaphore
                mov     ax, 2D1h
                mov     [ds:23Eh], ax
                push    ax
                call    SEG_MAIN:CpCreateSemaphore
                mov     ax, 1
                push    ax              ; interruptID
                mov     ax, SEG_MAIN
                push    ax
                mov     ax, OnIrq1_GPiB
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetInterrupt
                mov     ax, SEG_MAIN
                push    ax
                mov     ax, GPIBwatchDogHandler
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetWatchDogHandler
                mov     ax, [ds:1E0h]
        {rmsrc} or      ax, ax
                jz      short .loc_FD8DD
                jmp     loc_FD7D8
; ---------------------------------------------------------------------------

.loc_FD8DD:                              ; CODE XREF: GPIB_SendByte?-2B0↑j
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

loc_FD8E0:                              ; CODE XREF: GPIBdriver+6C↑j
                call    GPIB_stuff1
                mov     word [ds:1E0h], 0
                or      al, 40h
        {rmsrc} or      ah, ah
                jnz     short .loc_FD8F2
                jmp     .loc_FD998
; ---------------------------------------------------------------------------

.loc_FD8F2:                              ; CODE XREF: GPIB_SendByte?-29B↑j
                mov     dl, 18h
                mov     dh, 40h ; '@'
                call    GPIBsetIntMask
                call    GPIB_SendByte
                call    GPIBsetListenStbyMode
                mov     dl, 28h ; '('
                mov     dh, 40h ; '@'
                call    GPIBsetIntMask
                push    ds
                lds     bx, dword [ds:1E2h]
                les     si, [bx+0Fh]
                ;assume es:nothing
                mov     dh, [es:si+1]
                mov     cx, [bx+0Ah]
                les     si, [bx+2]
                pop     ds
                mov     byte [ds:1EEh], 0FFh

.loc_FD91E:                              ; CODE XREF: GPIB_SendByte?-244↓j
                                        ; GPIB_SendByte?-241↓j
                call    GPIB_SendByte
                push    es
                mov     bx, hwGPIB
                mov     es, bx
                ;assume es:hwGPiB
                mov     dl, byte [es:regTMS9914_Data_7]
                pop     es
                ;assume es:nothing
                call    GPIBenableIRQ
                test    al, 8
                jnz     short .loc_FD949
                cmp     dh, 0FFh
                jz      short .loc_FD93D
        {rmsrc} cmp     dl, dh
                jz      short .loc_FD949

.loc_FD93D:                              ; CODE XREF: GPIB_SendByte?-251↑j
                dec     cx
                jz      short .loc_FD946
                mov     [es:si], dl
                inc     si
                jmp     short .loc_FD91E
; ---------------------------------------------------------------------------

.loc_FD946:                              ; CODE XREF: GPIB_SendByte?-24A↑j
                inc     cx
                jmp     short .loc_FD91E
; ---------------------------------------------------------------------------

.loc_FD949:                              ; CODE XREF: GPIB_SendByte?-256↑j
                                        ; GPIB_SendByte?-24D↑j
                mov     [es:si], dl
                inc     si
                push    ds
                lds     bx, dword [ds:1E2h]
                les     di, [bx+2]
        {rmsrc} sub     si, di
                mov     [bx+0Ah], si
                pop     ds

.loc_FD95B:                              ; CODE XREF: GPIB_SendByte?-161↓j
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB

.loc_FD960:                              ; CODE XREF: GPIB_SendByte?-222↓j
                mov     al, byte [es:regTMS9914_Aux_Cmd_Bus_Status_3]
                test    al, 20h
                jz      short .loc_FD960
                mov     di, 6
                mov     byte [es:di], 0Ch
                mov     byte [ds:1EEh], 0
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jz      short .loc_FD981
                call    GPIBsetState
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FD981:                              ; CODE XREF: GPIB_SendByte?-20F↑j
                mov     byte [es:regTMS9914_Data_7], 5Fh ; '_'
                mov     byte [es:di], 9
                mov     byte [es:di], 8Ah
                call    PollGPIBDevice
                call    GPIB_stuff7
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FD998:                              ; CODE XREF: GPIB_SendByte?-299↑j
                call    GPIB_stuff2
                call    GPIB_SendByte
                call    GPIBsetListenStbyMode
                mov     word [ds:1F4h], 0FFFFh
                mov     byte [es:regTMS9914_Int0_0], 8
                mov     si, 240h
                mov     byte [si], 0F3h ; rep
                mov     byte [si+1], 0A4h ; movsb
                mov     byte [si+2], 0CBh ; retf
                mov     word [ds:1F6h], 0
                call    UnmaskIrq1
                call    GPIBenableWatchDog
                lds     bx, dword [ds:1E2h]
                mov     cx, [bx+0Ah]
                les     di, [bx+2]
                ;assume es:nothing
                mov     ax, 0E000h
                mov     ds, ax
                ;assume ds:nothing
        {rmsrc} xor     si, si
                cld
                call    SEG_CCPROM_RAM:dmaHackCode
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM

.loc_FD9E3:                              ; CODE XREF: GPIB_SendByte?-192↓j
                mov     ax, [word_2B76]
        {rmsrc} or      ax, ax
                jnz     short .loc_FD9F8
                push    ds
                mov     ax, hwGPIB
                mov     ds, ax
                ;assume ds:hwGPiB
                mov     si, 0Eh
                mov     al, [si]
                pop     ds
                ;assume ds:nothing
                jmp     short .loc_FD9E3
; ---------------------------------------------------------------------------

.loc_FD9F8:                              ; CODE XREF: GPIB_SendByte?-1A0↑j
                mov     ax, hwGPIB
                mov     ds, ax
                ;assume ds:hwGPiB
                mov     al, byte [regTMS9914_Int0_0]
                test    al, 20h
                jz      short .loc_FDA08
                mov     al, byte [regTMS9914_Data_7]
                stosb

.loc_FDA08:                              ; CODE XREF: GPIB_SendByte?-186↑j
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     word [word_2B74], 0
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                mov     si, [bx+2]
        {rmsrc} sub     di, si
                mov     [bx+0Ah], di
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                call    GPIBdisableWatchDog
                jmp     .loc_FD95B
; ---------------------------------------------------------------------------

loc_FDA2A:                              ; CODE XREF: GPIBdriver+74↑j
                call    GPIB_stuff1
        {rmsrc} or      al, 20h
        {rmsrc} or      ah, ah
                jnz     short .loc_FDA36
                jmp     short .loc_FDAA9
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FDA36:                              ; CODE XREF: GPIB_SendByte?-157↑j
                mov     dl, 18h
                mov     dh, 40h ; '@'
                call    GPIBsetIntMask
                call    GPIB_SendByte
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 0Bh
                mov     byte [byte_2B6F], 0FFh
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                mov     cx, [bx+0Ah]
                lds     si, [bx+2]
                dec     cx
                jz      short .loc_FDA64
                cld

.loc_FDA5E:                              ; CODE XREF: GPIB_SendByte?-126↓j
                lodsb
                call    GPIB_SendByte
                loop    .loc_FDA5E

.loc_FDA64:                              ; CODE XREF: GPIB_SendByte?-12D↑j
                mov     ax, hwGPIB
                mov     es, ax
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                push    ds
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 8
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                push    si
                les     si, [bx+0Fh]
                ;assume es:nothing
                mov     al, [es:si+1]
                cmp     al, 0FFh
                pop     si
                jnz     short .loc_FDA8C
                les     di, [bx+2]
                mov     al, [es:si]

.loc_FDA8C:                              ; CODE XREF: GPIB_SendByte?-104↑j
                pop     ds
                call    GPIB_SendByte
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB

.loc_FDA95:                              ; CODE XREF: GPIB_SendByte?-4D↓j
                                        ; GPIB_SendByte?:loc_FDB51↓j
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 0Ch
        {rmsrc} mov     al, 3Fh ; '?'
                call    GPIB_SendByte
                call    PollGPIBDevice
                call    GPIB_stuff7
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDAA9:                              ; CODE XREF: GPIB_SendByte?-155↑j
                call    GPIB_stuff2
                call    GPIB_SendByte
                mov     si, 240h
                mov     byte [si], 0F3h ; rep
                mov     byte [si+1], 0A4h ; movsb
                mov     byte [si+2], 0CBh ; ret
                mov     word [ds:1F4h], 0FFFFh
                mov     word [ds:1F6h], 0
                call    GPIBenableWatchDog
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 0Bh
                lds     bx, dword [ds:1E2h]
                mov     cx, [bx+0Ah]
                les     si, [bx+2]
                ;assume es:nothing
                mov     ax, es
                mov     ds, ax
                mov     ax, hwDMA
                mov     es, ax
                ;assume es:nothing
        {rmsrc} xor     di, di
        {rmsrc} xor     bx, bx
                cld
                dec     cx
                jz      short .loc_FDAF2
                call    SEG_CCPROM_RAM:dmaHackCode

.loc_FDAF2:                              ; CODE XREF: GPIB_SendByte?-9D↑j
                mov     bx, SEG_CCPROM_RAM
                mov     ds, bx
                ;assume ds:CCPROM_RAM
                mov     word [word_2B74], 0
                call    GPIBdisableWatchDog
                mov     ax, [word_2B76]
        {rmsrc} or      ax, ax
                jnz     short .loc_FDB3E
                mov     byte [byte_2B6E], 0FFh
                mov     byte [byte_2B6F], 0FFh
                call    GPIBenableIRQ
                call    GPIB_SendByte
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                mov     ax, [bx+4]
                mov     ds, ax
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 8
                mov     al, [si]
                mov     byte [es:regTMS9914_Data_7], al
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     byte [byte_2B6E], 0
                jmp     .loc_FDA95
; ---------------------------------------------------------------------------

.loc_FDB3E:                              ; CODE XREF: GPIB_SendByte?-83↑j
                mov     ax, hwGPIB
                mov     es, ax
                mov     al, byte [es:regTMS9914_Int1_1]
                test    al, 40h
                jz      short .loc_FDB51
                mov     ax, 1C4h
                call    GPIBsetState

.loc_FDB51:                              ; CODE XREF: GPIB_SendByte?-3F↑j
                jmp     .loc_FDA95
; END OF FUNCTION CHUNK FOR GPIB_SendByte?

;=======================================================================
;=======================================================================
; =============== S U B R O U T I N E =======================================


;GPIB_stuff1     proc near               ; CODE XREF: GPIB_SendByte?:loc_FD8E0↑p
                                        ; GPIB_SendByte?:loc_FDA2A↑p
GPIB_stuff1:
                push    ds
                mov     byte [byte_2B71], 0
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                mov     al, [bx+0Eh]
                and     al, 1Fh
                les     si, [bx+0Fh]
                ;assume es:nothing
                mov     ah, [es:si]
                mov     cx, [es:si+3]
                pop     ds
                mov     [ds:1EAh], cx
                push    ax
                mov     ax, 0
                call    GPIBsetState
                pop     ax
                mov     byte [ds:1EEh], 0
                retn
;GPIB_stuff1     endp


; =============== S U B R O U T I N E =======================================


;GPIB_stuff2     proc near               ; CODE XREF: GPIB_SendByte?:loc_FD998↑p
                                        ; GPIB_SendByte?:loc_FDAA9↑p
GPIB_stuff2:
                mov     dl, 18h
                mov     dh, 40h ; '@'
                call    GPIBsetIntMask
                retn
;GPIB_stuff2     endp


; =============== S U B R O U T I N E =======================================


;GPIB_SendByte?  proc far                ; CODE XREF: GPIB_SendByte?-28F↑p
                                        ; GPIB_SendByte?:loc_FD91E↑p ...
GPIB_SendByte:
; FUNCTION CHUNK AT 17FB SIZE 00000349 BYTES

                push    ds
                push    es
                push    cx
                push    si
                push    dx
                mov     bx, SEG_CCPROM_RAM
                mov     ds, bx
                ;assume ds:CCPROM_RAM
                mov     bl, [byte_2B6E]
        {rmsrc} or      bl, bl
                jnz     short .loc_FDBA6
                mov     bx, hwGPIB
                mov     es, bx
                ;assume es:hwGPiB
                mov     byte [es:regTMS9914_Data_7], al
                call    GPIBenableIRQ

.loc_FDBA6:                              ; CODE XREF: GPIB_SendByte?+10↑j
                push    [word_2BBE]       ; sid
                push    [gtimelimit]       ; timeLimit
                les     bx, [gpError]
                ;assume es:nothing
                push    es
                push    bx              ; pError
                call    SEG_MAIN:CpWait
                pop     dx
                pop     si
                pop     cx
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                call    GPIBgetState
        {rmsrc} or      ax, ax
                jz      short .loc_FDBD6

.loc_FDBC8:                              ; CODE XREF: GPIB_SendByte?+53↓j
                                        ; GPIB_SendByte?+6D↓j
                call    GPIBsetState
                mov     byte [byte_2B70], 0FFh
                pop     es
                pop     ds
                ;assume ds:nothing
                pop     ax
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDBD6:                              ; CODE XREF: GPIB_SendByte?+3E↑j
                mov     ax, [ds:1F2h]
        {rmsrc} or      ax, ax
                jnz     short .loc_FDBC8
                call    MaskIrq1
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB
                mov     ah, byte [es:regTMS9914_Int0_0]
                mov     al, byte [es:regTMS9914_Int1_1]
                test    al, 40h
                jz      short loc_FDBF7
                mov     ax, 1C4h
                jmp     short .loc_FDBC8
; ---------------------------------------------------------------------------

loc_FDBF7:                              ; CODE XREF: GPIB_SendByte?+68↑j
                test    al, 2
                jz      short .loc_FDC00
                mov     byte [ds:1EDh], 0FFh

.loc_FDC00:                              ; CODE XREF: GPIB_SendByte?+71↑j
                pop     es
                ;assume es:nothing
                pop     ds
                retn
;GPIB_SendByte?  endp ; sp-analysis failed


; =============== S U B R O U T I N E =======================================


;GPIBwaitWriteReady proc near           ; CODE XREF: GPIB_SendByte?-327↑p
                                        ; GPIB_SendByte?-214↑p ...
GPIBwaitWriteReady:
        {rmsrc} xor     ax, ax
                mov     cx, 0FFFFh

.loc_FDC08:                              ; CODE XREF: GPIBwaitWriteReady?+10↓j
                mov     bl, [es:regTMS9914_Int0_0]
                test    bl, 10h
                jnz     short .locret_FDC18
                dec     cx
                jnz     short .loc_FDC08
                mov     ax, 1C3h

.locret_FDC18:                           ; CODE XREF: GPIBwaitWriteReady?+D↑j
                retn
;GPIBwaitWriteReady endp


; =============== S U B R O U T I N E =======================================


;GPIBenableWatchDog proc near           ; CODE XREF: GPIB_SendByte?-1C4↑p
GPIBenableWatchDog:

                push    ax
                push    es
                push    bx
                mov     ax, catchSetWatchDog
                push    ax              ; command
                mov     ax, 0FFh
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                mov     ax, 106h
                push    ax              ; command
                mov     ax, 1
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                pop     bx
                pop     es
                pop     ax
                retn
;GPIBenableWatchDog endp


; =============== S U B R O U T I N E =======================================


;GPIBdisableWatchDog proc near          ; CODE XREF: GPIB_SendByte?-164↑p
GPIBdisableWatchDog:
                push    es
                push    ax
                push    bx
                mov     ax, catchWatchdog
                push    ax              ; command
        {rmsrc} xor     ax, ax
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                pop     bx
                pop     ax
                pop     es
                retn
;GPIBdisableWatchDog? endp


; =============== S U B R O U T I N E =======================================


;GPIBwatchDogHandler proc far
GPIBwatchDogHandler:
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                call    GPIBdisableWatchDog
                mov     ax, 1C3h
                call    GPIBsetState
                mov     word [word_2B76], 0FFFFh
                mov     ax, SEG_CCPROM_RAM
                mov     si, 240h
                mov     ds, ax
                mov     byte [si], 90h
                mov     byte [si+1], 90h
                retf
;GPIBwatchDogHandler endp


; =============== S U B R O U T I N E =======================================


;GPIBsetIntMask  proc near               ; CODE XREF: GPIB_SendByte?-292↑p
GPIBsetIntMask:
                mov     byte [byte_2B6F], 0FFh
                mov     bx, hwGPIB
                mov     es, bx
                ;assume es:hwGPiB
                mov     byte [es:regTMS9914_Int0_0], dl
                mov     byte [es:regTMS9914_Int1_1], dh
;GPIBsetIntMask  endp


; =============== S U B R O U T I N E =======================================


;GPIBenableIRQ   proc near               ; CODE XREF: GPIB_SendByte?-25B↑p
GPIBenableIRQ:
                mov     bl, byte [byte_2B6F]
        {rmsrc} or      bl, bl
                jz      short .locret_FDC95
                mov     byte [byte_2B6F], 0
                call    UnmaskIrq1

.locret_FDC95:                           ; CODE XREF: GPIBenableIRQ+6↑j
                retn
;GPIBenableIRQ   endp


; =============== S U B R O U T I N E =======================================


; int __fastcall GPIBsignal(char)
;GPIBsignal      proc near               ; CODE XREF: GPIB_SendByte?-369↑p
                                        ; PollGPIBDevice+B3↓p ...
GPIBsignal:
                push    bx              ; sid
                push    cx              ; mode
                push    ax              ; note
                les     bx, [gpError]
                ;assume es:nothing
                push    es
                push    bx              ; pError
                call    SEG_MAIN:CpSignal
                call    GPIBgetState
                mov     [word_2B72], ax
                retn
;GPIBsignal      endp


; =============== S U B R O U T I N E =======================================


;GPIB_stuff7     proc near               ; CODE XREF: GPIB_SendByte?-1F6↑p
                                        ; GPIB_SendByte?-E5↑p
GPIB_stuff7:
                call    GPIBsetState
                mov     byte [byte_2B71], 0FFh
                mov     dl, 0
                mov     dh, 2
                call    GPIBsetIntMask
                retn
;GPIB_stuff7     endp


; =============== S U B R O U T I N E =======================================


;GPIBsetListenStbyMode proc near        ; CODE XREF: GPIB_SendByte?-28C↑p
                                        ; GPIB_SendByte?-1EA↑p ...
GPIBsetListenStbyMode:
                mov     ax, hwGPIB
                mov     es, ax
                ;assume es:hwGPiB
                mov     di, regTMS9914_Aux_Cmd_Bus_Status_3
                mov     byte [es:di], 0Ah ; Aux cmd: ton (talk only) disabled
                mov     byte [es:di], 89h ; Aux cmd: lon (listen only) enabled
                mov     byte [es:di], 0Bh ; Aux cmd: gts (go to standby). set ATN line to false
                retn
;GPIBsetListenStbyMode? endp


; =============== S U B R O U T I N E =======================================


;UnmaskIrq1      proc near               ; CODE XREF: GPIB_SendByte?-1C7↑p
                                        ; GPIBenableIRQ+D↑p ...
UnmaskIrq1:
                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                mov     ax, 1
                push    ax
                mov     ax, 0
                push    ax
                call    SEG_MAIN:CpEnableInterrupt
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es
                ;assume es:nothing
                retn
;UnmaskIrq1      endp


; =============== S U B R O U T I N E =======================================


;MaskIrq1        proc near               ; CODE XREF: GPIB_SendByte?+55↑p
                                        ; OnIrq1_GPiB+17↓p
MaskIrq1:
                push    ax
                push    es
                push    bx
                mov     ax, 1
                push    ax
                call    SEG_MAIN:CpDisableInterrupt
                pop     bx
                pop     es
                pop     ax
                retn
;MaskIrq1        endp


; =============== S U B R O U T I N E =======================================


;GPIBgetState   proc near               ; CODE XREF: GPIBdriver+43↑p
                                        ; GPIB_SendByte?-378↑p ...
GPIBgetState:
                les     di, [gpError]
                mov     ax, [es:di]
                retn
;GPIBgetState   endp


; =============== S U B R O U T I N E =======================================


;GPIBsetState   proc near               ; CODE XREF: GPIBdriver+97↑p
                                        ; GPIB_SendByte?-34A↑p ...
GPIBsetState:
                push    ax
                call    GPIBgetState
        {rmsrc} or      ax, ax
                pop     ax
                jnz     short .locret_FDD12
                les     di, [gpError]
                mov     [es:di], ax

.locret_FDD12:                           ; CODE XREF: GPIBsetState?+7↑j
                retn
;GPIBsetState   endp
;=======================================================================
;=======================================================================
; ---------------------------------------------------------------------------
; START OF FUNCTION CHUNK FOR GPIBdriver

loc_FDD13:                              ; CODE XREF: GPIBdriver+7C↑j
                                        ; GPIBdriver+91↑j
                push    ds
                lds     bx, [dword_2B62]
                ;assume ds:nothing
                les     di, [bx+0Fh]
                mov     al, [es:di]
        {rmsrc} or      al, al
                jnz     short .loc_FDD68
                mov     dx, hwGPIB
                mov     es, dx
                ;assume es:hwGPiB
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 80h
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 0
                mov     byte [es:regTMS9914_Aux_Cmd_Bus_Status_3], 8Ah
                mov     dl, [bx+0Eh]
                and     dl, 1Fh
                or      dl, 20h
                pop     ds
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jnz     short .loc_FDD74
                mov     byte [es:regTMS9914_Data_7], dl
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jnz     short .loc_FDD74
                mov     byte [es:regTMS9914_Data_7], 4
                mov     ax, 1F4h
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDD68:                              ; CODE XREF: GPIBdriver+5AF↑j
                cmp     al, 1
                jz      short .loc_FDD7A
                cmp     al, 2
                jz      short .loc_FDD9F
                pop     ds
                mov     ax, 17h

.loc_FDD74:                              ; CODE XREF: GPIBdriver+5D7↑j
                                        ; GPIBdriver+5E3↑j
                call    GPIBsetState
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDD7A:                              ; CODE XREF: GPIBdriver+5F9↑j
                inc     di
        {rmsrc} xor     bx, bx
                mov     bl, [es:di]
                inc     di
                mov     cl, [es:di]
                rol     bl, 1
                cmp     cl, 0FFh
                mov     ax, hwGPIB
                mov     ds, ax
                ;assume ds:hwGPiB
                jz      short .loc_FDD96
                mov     [bx], al

.loc_FDD92:                              ; CODE XREF: GPIBdriver+62C↓j
                pop     ds
                ;assume ds:nothing
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDD96:                              ; CODE XREF: GPIBdriver+61D↑j
                mov     al, [bx]
                dec     di
                dec     di
                mov     [es:di], al
                jmp     short .loc_FDD92
; ---------------------------------------------------------------------------

.loc_FDD9F:                              ; CODE XREF: GPIBdriver+5FD↑j
                mov     al, [bx+0Eh]
                dec     al
                pop     ds
        {rmsrc} xor     ah, ah
                push    ax
        {rmsrc} add     al, al
                mov     bx, 1F8h
        {rmsrc} add     bx, ax
                mov     cx, [es:di+1]
                mov     ax, [ds:1E0h]
                ;cmp     ax, 15h
                db      3Dh, 15h, 00                            ;hack for "cmp ax, 15h"
                jnz     short .loc_FDDBD
        {rmsrc} xor     cx, cx

.loc_FDDBD:                              ; CODE XREF: GPIBdriver+648↑j
                mov     [bx], cx
                mov     bx, 238h
                pop     cx
                mov     ax, 1
                cmp     cl, 10h
                jl      short .loc_FDDD0
                sub     cx, 10h
                inc     bx
                inc     bx

.loc_FDDD0:                              ; CODE XREF: GPIBdriver+658↑j
                clc
                rol     ax, cl
                mov     cx, [ds:1E0h]
                cmp     cx, 15h
                jnz     short .loc_FDDE4
                ;xor     ax, 0FFFFh
                db      35h, 0FFh, 0FFh                         ;hack for "xor ax, 0FFFFh"
                and     [bx], ax
                jmp     loc_FD80B
; ---------------------------------------------------------------------------

.loc_FDDE4:                              ; CODE XREF: GPIBdriver+669↑j
                or      [bx], ax
                jmp     loc_FD80B
; END OF FUNCTION CHUNK FOR GPIBdriver

; =============== S U B R O U T I N E =======================================


;PollGPIBDevice  proc near               ; CODE XREF: GPIB_SendByte?-1F9↑p
                                        ; GPIB_SendByte?-E8↑p
PollGPIBDevice:
                mov     al, byte [ds:1EDh]
        {rmsrc} or      al, al
                jnz     short loc_FDDF3
        {rmsrc} xor     ax, ax
                retn
; ---------------------------------------------------------------------------

loc_FDDF3:                              ; CODE XREF: PollGPIBDevice+5↑j
                                        ; OnIrq1_GPiB+22↓p
                mov     ax, hwGPIB
                mov     es, ax
                mov     byte [es:regTMS9914_Data_7], 18h
                mov     bx, 238h
                mov     cx, [bx]
        {rmsrc} xor     dx, dx

.loc_FDE05:                              ; CODE XREF: PollGPIBDevice+77↓j
                mov     bx, 238h
        {rmsrc} mov     ax, dx

.loc_FDE0A:                              ; CODE XREF: PollGPIBDevice+33↓j
                cmp     al, 10h
                jnz     short .loc_FDE11
                mov     cx, [bx+2]

.loc_FDE11:                              ; CODE XREF: PollGPIBDevice+23↑j
                cmp     al, 20h ; ' '
                jnz     short .loc_FDE18
                jmp     .loc_FDEA9
; ---------------------------------------------------------------------------

.loc_FDE18:                              ; CODE XREF: PollGPIBDevice+2A↑j
                inc     al
                rcr     cx, 1
                jnb     short .loc_FDE0A
        {rmsrc} mov     dx, ax
                push    dx
                push    cx
                or      dl, 40h
                push    bx
                call    GPIBwaitWriteReady
                pop     bx
        {rmsrc} or      ax, ax
                jz      short .loc_FDE31
                jmp     short .loc_FDEA7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.loc_FDE31:                              ; CODE XREF: PollGPIBDevice+43↑j
                mov     byte [es:regTMS9914_Data_7], dl
                call    GPIBsetListenStbyMode
                mov     cx, 0FFFFh

.loc_FDE3C:                              ; CODE XREF: PollGPIBDevice+5C↓j
                mov     al, byte [es:regTMS9914_Int0_0]
                test    al, 20h
                jnz     short .loc_FDE4A
                dec     cx
                jnz     short .loc_FDE3C
                jmp     short .loc_FDEA7
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.loc_FDE4A:                              ; CODE XREF: PollGPIBDevice+59↑j
                mov     byte [es:di], 0Dh
                mov     bl, byte [es:regTMS9914_Data_7]
                mov     byte [es:di], 9
                mov     byte [es:di], 8Ah
                pop     cx
                pop     dx
                test    bl, 40h
                jz      short .loc_FDE05
                and     bl, 0BFh
        {rmsrc} xor     bh, bh
        {rmsrc} mov     ax, bx
                mov     bx, 1F8h
                dec     dx
                clc
                rol     dx, 1
        {rmsrc} mov     si, dx
                mov     bx, [bx+si]
                push    bx
                push    ax
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jnz     short .loc_FDEA7
                mov     byte [es:regTMS9914_Data_7], 19h
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jnz     short .loc_FDEA7
                mov     byte [es:regTMS9914_Data_7], 5Fh ; '_'
                call    GPIBwaitWriteReady
        {rmsrc} or      ax, ax
                jnz     short .loc_FDEA7
                pop     ax
                pop     bx
                mov     cx, 81h         ; char
                call    GPIBsignal
        {rmsrc} xor     ax, ax

.loc_FDEA1:                              ; CODE XREF: PollGPIBDevice+C3↓j
                mov     byte [ds:1EDh], 0
                retn
; ---------------------------------------------------------------------------

.loc_FDEA7:                              ; CODE XREF: PollGPIBDevice+45↑j
                                        ; PollGPIBDevice+5E↑j ...
                pop     ax
                pop     bx

.loc_FDEA9:                              ; CODE XREF: PollGPIBDevice+2C↑j
                mov     ax, 1C4h
                jmp     short .loc_FDEA1
;PollGPIBDevice  endp


; =============== S U B R O U T I N E =======================================


;OnIrq1_GPiB     proc far
OnIrq1_GPiB:
                push    es
                push    ds
                push    bp
                push    si
                push    di
                push    dx
                push    bx
                push    ax
                push    cx
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     ax, 1
                push    ax
                call    SEG_MAIN:CpEndOfInterrupt
                call    MaskIrq1
                mov     al, [byte_2B71]
        {rmsrc} or      al, al
                jz      short .loc_FDEE5
                push    ds
                call    loc_FDDF3
                pop     ds
                ;assume ds:nothing
                mov     ax, hwGPIB
                mov     es, ax
                mov     al, byte [es:regTMS9914_Int0_0]
                mov     ah, byte [es:regTMS9914_Int1_1]
                jmp     short loc_FDF12
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.loc_FDEE5:                              ; CODE XREF: OnIrq1_GPiB+1F↑j
                mov     ax, [ds:1F4h]
        {rmsrc} or      ax, ax
                jz      short .loc_FDF06
                push    ds
                mov     ax, SEG_CCPROM_RAM
                mov     si, 240h
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                mov     byte [si], 90h
                mov     byte [si+1], 90h
                mov     word [word_2B76], 0FFFFh
                pop     ds
                ;assume ds:nothing
                jmp     short loc_FDF1D
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.loc_FDF06:                              ; CODE XREF: OnIrq1_GPiB+3C↑j
                mov     bx, [ds:23Eh]
                mov     cx, 81h         ; char
        {rmsrc} xor     ax, ax
                call    GPIBsignal

loc_FDF12:                              ; CODE XREF: OnIrq1_GPiB+34↑j
        {rmsrc} xor     ax, ax
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                call    UnmaskIrq1

loc_FDF1D:                              ; CODE XREF: OnIrq1_GPiB+55↑j
                mov     byte [ds:1EFh], 0FFh
                pop     cx
                pop     ax
                pop     bx
                pop     dx
                pop     di
                pop     si
                pop     bp
                pop     ds
                pop     es
                ;assume es:nothing
                iret
;OnIrq1_GPiB     endp

                repeat 1F20h - $
                    db 00h
                end repeat


;jump tables
jpt_FE0D1:      dw loc_FE0D6     ; DATA XREF: BlitRectangle+4C↓r
                dw loc_FE0DF     ; jump table for switch statement
                dw loc_FE0EA
                dw loc_FE0F7
                dw loc_FE106
                dw loc_FE117
                dw loc_FE12A
                dw loc_FE13C
                dw loc_FE14C
                dw loc_FE15A
                dw loc_FE16A
                dw loc_FE17C
                dw loc_FE197
                dw loc_FE1B0
                dw loc_FE1C7
                dw loc_FE1DC
                
                
jpt_FE241:      dw loc_FE246     ; DATA XREF: INVCSR?+47↓r
                dw loc_FE24D     ; jump table for switch statement
                dw loc_FE254
                dw loc_FE25B
                dw loc_FE262
                dw loc_FE269
                dw loc_FE270
                dw loc_FE277
                dw loc_FE27E
                dw loc_FE285
                dw loc_FE28C
                dw loc_FE293
                dw loc_FE29A
                dw loc_FE2A6
                dw loc_FE2B2
                dw loc_FE2BE

; =============== S U B R O U T I N E =======================================
;CnoCharOut      proc far                ; CODE XREF: j_CnoCharOut↓J
CnoCharOut:

arg_0           equ     08h

                push    ds
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                call    INVCSR
                mov     ax, [bp+arg_0]
                call    ConChar
                call    INVCSR
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    2
;CnoCharOut      endp

; =============== S U B R O U T I N E =======================================
;CnoLineOut      proc far                ; CODE XREF: osReadBootLoader+149↓P
                                        ; osSelectBootDevice+132↓P ...
CnoLineOut:

arg_0           equ     08h
arg_2           equ     0Ah
arg_4           equ     0Ch

                push    ds
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
               ; assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                call    INVCSR
                mov     ax, [bp+arg_4]
                mov     es, ax
                mov     di, [bp+arg_2]
                mov     cx, [bp+arg_0]

.loc_FDFA1:                              ; CODE XREF: CnoLineOut+24↓j
                mov     al, [es:di]
                push    es
                push    cx
                push    di
                call    ConChar
                pop     di
                pop     cx
                pop     es
                inc     di
                loop    .loc_FDFA1
                call    INVCSR
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    6
;CnoLineOut      endp

; =============== S U B R O U T I N E =======================================
;ConChar         proc near               ; CODE XREF: CnoCharOut+F↑p
                                        ; CnoLineOut+1D↑p
ConChar:
                cmp     al, 0Dh
                jz      short .loc_FE028
                cmp     al, 0Ah
                jz      short .loc_FE02F

.loc_FDFC0:
                cmp     al, 8
                jz      short .loc_FE01B
                cmp     word [ds:250h], 13Ah
                jle     short .loc_FDFD7
                mov     word [ds:250h], 0
                add     word [ds:252h], 0Ah

.loc_FDFD7:                              ; CODE XREF: ConChar+12↑j
                cmp     word [ds:252h], 0E6h
                jle     short .loc_FDFEA
                mov     word [ds:252h], 0E6h
                push    ax
                call    ScollUp
                pop     ax

.loc_FDFEA:                              ; CODE XREF: ConChar+25↑j
                and     ah, 0
        {rmsrc} mov     di, ax
                les     bx, dword [ds:258h+1]
                mov     cl, [es:bx]
                and     ch, 0
                mov     bx, word [ds:250h]
                mov     dx, [ds:252h]
                call    BlitRectangle
                add     word [ds:250h], 6
                cmp     word [ds:250h], 13Ah
                jle     short .locret_FE01A
                mov     word [ds:250h], 0
                jmp     short .loc_FE02F
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.locret_FE01A:                           ; CODE XREF: ConChar+57↑j
                retn
; ---------------------------------------------------------------------------

.loc_FE01B:                              ; CODE XREF: ConChar+A↑j
                cmp     word [ds:250h], 0
                jz      short .locret_FE027
                sub     word [ds:250h], 6

.locret_FE027:                           ; CODE XREF: ConChar+68↑j
                retn
; ---------------------------------------------------------------------------

.loc_FE028:                              ; CODE XREF: ConChar+2↑j
                mov     word [ds:250h], 0
                retn
; ---------------------------------------------------------------------------

.loc_FE02F:                              ; CODE XREF: ConChar+6↑j
                                        ; ConChar+5F↑j
                add     word [ds:252h], 0Ah
                cmp     word [ds:252h], 0E6h
                jle     short .locret_FE045
                mov     word [ds:252h], 0E6h
                call    ScollUp

.locret_FE045:                           ; CODE XREF: ConChar+82↑j
                retn
;ConChar         endp


; =============== S U B R O U T I N E =======================================
;ScollUp         proc near               ; CODE XREF: ConChar+2E↑p
                                        ; ConChar+8A↑p
ScollUp:
                push    ds
                mov     ax, SEG_FONT_ROM
                mov     es, ax
                ;assume es:font_rom
                mov     bx, 0
                shl     bx, 1
                ;mov     di, [es:bx]
                db      26h, 8Bh, 0BFh, 00h, 00h                ;hack for "mov di, [es:bx]"
        {rmsrc} mov     ax, di
                add     ax, 190h
        {rmsrc} mov     si, ax
                mov     bx, 17h
                shl     bx, 1
                ;mov     cx, [es:bx]
                db      26h, 8Bh, 8Fh, 00h, 00h                 ;hack for "mov di, [es:bx]"
        {rmsrc} sub     cx, di
                shr     cx, 1
                mov     ax, SEG_VIDEO_RAM
                mov     ds, ax
                ;assume ds:video_ram
                mov     es, ax
                ;assume es:video_ram
                cld
                rep movsw
                mov     word [di], 0
        {rmsrc} mov     si, di
                inc     di
                inc     di
                mov     cx, 0C7h
                cld
                rep movsw
                pop     ds
                ;assume ds:nothing
                retn
;ScollUp         endp

; =============== S U B R O U T I N E =======================================
;BlitRectangle   proc near               ; CODE XREF: ConChar+49↑p
BlitRectangle:
        {rmsrc} cmp     di, cx
                jl      short .loc_FE08C
        {rmsrc} mov     di, cx
                dec     di

.loc_FE08C:                              ; CODE XREF: BlitRectangle+2↑j
                push    ds
                mov     ax, SEG_CCPROM_RAM
                mov     ds, ax
                ;assume ds:CCPROM_RAM
                les     ax, dword [ROMfontOffset]
                ;assume es:nothing
        {rmsrc} add     di, ax
                add     di, 8
        {rmsrc} mov     ax, dx
                shl     ax, 1
                shl     ax, 1
                shl     ax, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
        {rmsrc} add     dx, ax
        {rmsrc} mov     si, bx
                ;and     si, 0Fh         ; switch 16 cases
                db      81h, 0E6h, 0Fh, 00h                     ;hack for "and si, 0Fh ;switch 16 cases"
                shl     si, 1
                shr     bx, 1
                shr     bx, 1
                shr     bx, 1
                shr     bx, 1
                shl     bx, 1
        {rmsrc} add     bx, dx
        {rmsrc} mov     dx, cx
                mov     ch, 8
                mov     ax, SEG_VIDEO_RAM
                mov     ds, ax
                ;assume ds:video_ram

loc_FE0CC:                              ; CODE XREF: BlitRectangle+170↓j
                mov     ah, [es:di]
                and     al, 0
                jmp     word [cs:jpt_FE0D1+si] ; switch jump
; ---------------------------------------------------------------------------

loc_FE0D6:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                and     word [bx], 3FFh ; jumptable 000FE0D1 case 0
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE0DF:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                shr     ax, 1           ; jumptable 000FE0D1 case 1
                and     word [bx], 81FFh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE0EA:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                shr     ax, 1           ; jumptable 000FE0D1 case 2
                shr     ax, 1
                and     word [bx], 0C0FFh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE0F7:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                shr     ax, 1           ; jumptable 000FE0D1 case 3
                shr     ax, 1
                shr     ax, 1
                and     word [bx], 0E07Fh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE106:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                shr     ax, 1           ; jumptable 000FE0D1 case 4
                shr     ax, 1
                shr     ax, 1
                shr     ax, 1
                and     word [bx], 0F03Fh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE117:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                shr     ax, 1           ; jumptable 000FE0D1 case 5
                shr     ax, 1
                shr     ax, 1
                shr     ax, 1
                shr     ax, 1
                and     word [bx], 0F81Fh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE12A:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
        {rmsrc} mov     al, ah          ; jumptable 000FE0D1 case 6
                and     ah, 0
                shl     ax, 1
                shl     ax, 1
                and     word [bx], 0FC0Fh
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE13C:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
        {rmsrc} mov     al, ah          ; jumptable 000FE0D1 case 7
                and     ah, 0
                shl     ax, 1
                and     word [bx], 0FE07h
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE14C:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
        {rmsrc} mov     al, ah          ; jumptable 000FE0D1 case 8
                and     ah, 0
                and     word [bx], 0FF03h
                or      [bx], ax
                jmp     loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE15A:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
        {rmsrc} mov     al, ah          ; jumptable 000FE0D1 case 9
                and     ah, 0
                shr     ax, 1
                ;and     word [bx], 0FF81h
                db      81h, 27h, 81h, 0FFh                     ;hack for "and word [bx], 0FF81h"
                or      [bx], ax
                jmp     near loc_FE1EC
; ---------------------------------------------------------------------------

loc_FE16A:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
        {rmsrc} mov     al, ah          ; jumptable 000FE0D1 case 10
                and     ah, 0
                shr     ax, 1
                shr     ax, 1
                ;and     word [bx], 0FFC0h
                db      81h, 27h, 0C0h, 0FFh                    ;hack for "and word [bx], 0FFC0h"
                or      [bx], ax
                jmp     short loc_FE1EC
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE17C:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                rol     ax, 1           ; jumptable 000FE0D1 case 11
                rol     ax, 1
                rol     ax, 1
                rol     ax, 1
                rol     ax, 1
                ;and     word [bx], 0FFE0h
                db      81h, 27h, 0E0h, 0FFh                    ;hack for "and word [bx], 0FFE0h"
                or      [bx], al
                and     word [bx+2], 7FFFh
                or      [bx+3], ah
                jmp     short loc_FE1EC
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE197:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                rol     ax, 1           ; jumptable 000FE0D1 case 12
                rol     ax, 1
                rol     ax, 1
                rol     ax, 1
                ;and     word [bx], 0FFF0h
                db      81h, 27h, 0F0h, 0FFh                    ;hack for "and word [bx], 0FFF0h"
                or      [bx], al
                and     word [bx+2], 3FFFh
                or      [bx+3], ah
                jmp     short loc_FE1EC
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE1B0:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                rol     ax, 1           ; jumptable 000FE0D1 case 13
                rol     ax, 1
                rol     ax, 1
                ;and     word [bx], 0FFF8h
                db      81h, 27h, 0F8h, 0FFh                    ;hack for "and word [bx], 0FFF8h"
                or      [bx], al
                and     word [bx+2], 1FFFh
                or      [bx+3], ah
                jmp     short loc_FE1EC
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE1C7:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                rol     ax, 1           ; jumptable 000FE0D1 case 14
                rol     ax, 1
                ;and     word [bx], 0FFFCh
                db      81h, 27h, 0FCh, 0FFh                    ;hack for "and word [bx], 0FFFCh"
                or      [bx], al
                and     word [bx+2], 0FFFh
                or      [bx+3], ah
                jmp     short loc_FE1EC
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE1DC:                              ; CODE XREF: BlitRectangle+4C↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE0D1↑o
                rol     ax, 1           ; jumptable 000FE0D1 case 15
                ;and     word [bx], 0FFFEh
                db      81h, 27h, 0FEh, 0FFh                    ;hack for "and word [bx], 0FFFEh"
                or      [bx], al
                and     word [bx+2], 7FFh
                or      [bx+3], ah

loc_FE1EC:                              ; CODE XREF: BlitRectangle+57↑j
                                        ; BlitRectangle+62↑j ...
        {rmsrc} add     di, dx
                add     bx, 28h ; '('
                dec     ch
                jz      short .RenderCharComplete ; if (ch==0) jump to render complete
                jmp     loc_FE0CC
; ---------------------------------------------------------------------------

.RenderCharComplete:                     ; CODE XREF: BlitRectangle+16E↑j
                pop     ds
                ;assume ds:nothing
                retn
;BlitRectangle   endp


; THIS ROUTINE INVERTS THE CURSOR AT THE
; SPECIFIED X-Y COORDINATE IF THE CURSOR IS
; ON. THE CURSOR IS AN UNDERBAR.
;
;    DS:wsXLoc    X POSITION
;    DS:wsYLoc    Y POSITION

; =============== S U B R O U T I N E =======================================


;INVCSR          proc near               ; CODE XREF: CnoCharOut+9↑p
                                        ; CnoCharOut+12↑p ...
INVCSR:
                cmp     byte [ds:0254h], 1
                jz      short .loc_FE202
                retn
; ---------------------------------------------------------------------------

.loc_FE202:                              ; CODE XREF: INVCSR?+5↑j
                mov     bx, [ds:250h]
                mov     dx, [ds:252h]
                push    ds
                mov     ax, SEG_VIDEO_RAM
                mov     ds, ax
                ;assume ds:video_ram
                mov     ax, SEG_FONT_ROM
                mov     es, ax
                ;assume es:font_rom
        {rmsrc} mov     ax, dx
                shl     ax, 1
                shl     ax, 1
                shl     ax, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
        {rmsrc} add     dx, ax
        {rmsrc} mov     si, bx
                ;and     si, 0Fh         ; switch 16 cases
                db      81h, 0E6h, 0Fh, 00h                     ;hack for "and si, 0Fh ;switch 16 cases"
                shl     si, 1
                shr     bx, 1
                shr     bx, 1
                shr     bx, 1
                shr     bx, 1
                shl     bx, 1
        {rmsrc} add     bx, dx
                add     bx, 140h
                jmp     word [cs:jpt_FE241+si] ; switch jump
; ---------------------------------------------------------------------------

loc_FE246:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 0F800h ; jumptable 000FE241 case 0
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE24D:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 7C00h ; jumptable 000FE241 case 1
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE254:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 3E00h ; jumptable 000FE241 case 2
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE25B:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 1F00h ; jumptable 000FE241 case 3
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE262:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 0F80h ; jumptable 000FE241 case 4
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE269:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 7C0h ; jumptable 000FE241 case 5
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE270:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 3E0h ; jumptable 000FE241 case 6
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE277:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 1F0h ; jumptable 000FE241 case 7
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE27E:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                xor     word [bx], 0F8h ; jumptable 000FE241 case 8
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE285:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 7Ch ; jumptable 000FE241 case 9
                db      81h, 37h, 7Ch, 00h                      ;hack for "xor word [bx], 7Ch"
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE28C:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 3Eh ; jumptable 000FE241 case 10
                db      81h, 37h, 3Eh, 00h                      ;hack for "xor word [bx], 3Eh"
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE293:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 1Fh ; jumptable 000FE241 case 11
                db      81h, 37h, 1Fh, 00h                      ;hack for "xor word [bx], 1Fh"
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE29A:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 0Fh ; jumptable 000FE241 case 12
                db      81h, 37h, 0Fh, 00h                      ;hack for "xor word [bx], 0Fh"
                xor     word [bx+2], 8000h
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE2A6:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 7 ; jumptable 000FE241 case 13
                db      81h, 37h, 07h, 00h                      ;hack for "xor word [bx], 7"
                xor     word [bx+2], 0C000h
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE2B2:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 3 ; jumptable 000FE241 case 14
                db      81h, 37h, 03h, 00h                      ;hack for "xor word [bx], 3"
                xor     word [bx+2], 0E000h
                jmp     short loc_FE2C7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

loc_FE2BE:                              ; CODE XREF: INVCSR?+47↑j
                                        ; DATA XREF: CCPROM_MAIN:jpt_FE241↑o
                ;xor     word [bx], 1 ; jumptable 000FE241 case 15
                db      81h, 37h, 01h, 00h                      ;hack for "xor word [bx], 1"
                xor     word [bx+2], 0F000h

loc_FE2C7:                              ; CODE XREF: INVCSR?+50↑j
                                        ; INVCSR?+57↑j ...
                pop     ds
                ;assume ds:nothing
                retn
;INVCSR          endp

                repeat 22C0h - $
                    db 00h
                end repeat

; ---------------------------------------------------------------------------
;part_number:    db '330000114432--0044 <<-- ppaarrtt nnuummbbeerr'
;patch for rev4
part_number:    db '330000225510--0044 <<-- ppaarrtt nnuummbbeerr'
;end patch
                db      00h
                db      0C5h
                db      02h


end match
