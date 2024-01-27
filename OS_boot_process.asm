match FALSE, _OS_boot_process_asm
display 'Including OS boot process segment', 10

_OS_boot_process_asm equ TRUE

; ===========================================================================

; Segment type: Pure code
;OsBoot          segment byte public 'CODE'
;                assume cs:OsBoot
org 6
;                assume es:nothing, ss:nothing, ds:nothing
                dw GPIBdriver
segBIOS         dw SEG_MAIN
                db 0FFh
                db  67h ; g
offBubbleCommand dw bubbleDrvService
                                        ; DATA XREF: osSelectBootDevice+89↓r
;------------------------------------------------------------------------------------
segBubbleDrv    dw SEG_BUBBLE
;------------------------------------------------------------------------------------
                db 0FFh
                db  62h ; b
dword_FE7F2     dd 0FED3000Eh           ; DATA XREF: osSelectBootDevice+71↓r
                db    4
                db  77h ; w
dword_FE7F8     dd 0FED3000Eh           ; DATA XREF: osSelectBootDevice+3F↓r
                db    5
                db  66h ; f
dword_FE7FE     dd 0FED3000Eh           ; DATA XREF: osSelectBootDevice+59↓r
                db    6
                db  63h ; c
dword_FE804     dd 0FED3000Eh           ; DATA XREF: osSelectBootDevice+A1↓r
                db    3
                db  78h ; x
aProm02531683   db 'Prom 0.25 3/16/83'
aCopyrightC1982 db 'Copyright (c) 1982 GRiD Systems Corporation'
aSystemDisk     db 'System Disk!'
msgCannotBootChecksum db 'Cannot boot: Checksum error',0Dh,0Ah
                                        ; DATA XREF: osReadBootLoader+140↓o
msgCannotBootStorage db 'Cannot boot: Storage medium error',0Dh,0Ah
                                        ; DATA XREF: osSelectBootDevice:loc_FECE2↓o
osBootDataSegment dw 2CAh               ; DATA XREF: osKeyHandler+1↓r
                                        ; osDoBoot+1↓r
bootLoaderSegOffsetEntry dd 20000006h   ; DATA XREF: osDoBoot+A↓r
; __int32 pBuf
opBuf            dd 20000000h            ; DATA XREF: osReadBootLoader+87↓r


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsBootFillStruct proc near              ; CODE XREF: sub_FE8D9+4B↓p
                                        ; sub_FE9F3+28↓p ...
OsBootFillStruct:

arg_0           equ     04h
arg_2           equ     06h
arg_4           equ     08h
arg_6           equ     0Ah
arg_8           equ     0Ch

                push    bp
        {rmsrc} mov     bp, sp
                mov     al, 0
                mov     di, 44h ; 'D'
                mov     cx, 13h
                push    ds
                pop     es
                ;assume es:nothing
                cld
                repne stosb
                mov     al, [bp+arg_2]
                mov     byte [ds:51h], al
                mov     al, [bp+arg_0]
                mov     byte [ds:52h], al
                les     ax, [bp+arg_8]
                ;assume es:nothing
                mov     [ds:46h], ax
                mov     word [ds:48h], es
                mov     ax, [bp+arg_4]
                mov     [ds:4Eh], ax
                mov     ax, [bp+arg_6]
                mov     dx, 0
                mov     [ds:4Ah], ax
                mov     word [ds:4Ch], dx
                pop     bp
                retn    0Ch
;OsBootFillStruct endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;sub_FE8D9       proc near               ; CODE XREF: osReadBootLoader+95↓p
                                        ; osReadBootLoader+126↓p
sub_FE8D9:

var_8           equ     -8
var_6           equ     -6
var_4           equ     -4
var_2           equ     -2
arg_0           equ     04h
arg_2           equ     06h
arg_4           equ     08h
arg_8           equ     0Ch

                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 8
                mov     ax, 0
                mov     [bp+var_6], ax
                mov     ax, [ds:0Ch]
                mov     [bp+var_4], ax
                mov     word [bp+var_8], 0

.loc_FE8F0:                              ; CODE XREF: sub_FE8D9+73↓j
                mov     ax, [bp+arg_2]
                mov     cx, [bp+var_4]
                ;xor     dx, dx
                db      31h, 0D2h                               ;hack for "xor dx, dx"
                div     cx
                dec     ax
                cmp     [bp+var_8], ax
                ja      short .loc_FE94E
                les     bx, [bp+arg_4]
                mov     si, [bp+var_6]
                lea     ax, [bx+si]
                push    es
                push    ax
                mov     ax, [bp+arg_8]
                ;xor     dx, dx
                db      31h, 0D2h                               ;hack for "xor dx, dx"
                div     cx
                push    ax
                push    cx
                mov     al, 0
                push    ax
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                mov     bx, ax
                push    word [cs:bx+0Ah]
                call    OsBootFillStruct
                mov     ax, 4
                push    ax
                mov     ax, 44h ; 'D'
                push    ds
                push    ax

.loc_FE930:
                lea     ax, [bp+var_2]
                push    ss
                push    ax
                call    dword [ds:4]
                mov     ax, [bp+var_2]
                or      ax, ax
                jnz     short .loc_FE951
                mov     ax, [bp+var_4]
                add     [bp+var_6], ax
                add     [bp+arg_8], ax
                inc     word [bp+var_8]
                jnz     short .loc_FE8F0

.loc_FE94E:                              ; CODE XREF: sub_FE8D9+25↑j
                mov     ax, 0
                ;db      89h, 0ECh

.loc_FE951:                              ; CODE XREF: sub_FE8D9+65↑j
                mov     sp, bp
                pop     bp
                retn    0Ah
;sub_FE8D9       endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;sub_FE957       proc near               ; CODE XREF: osSelectBootDevice+30↓p
sub_FE957:

arg_0           equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                mov     al, 0
                mov     di, 44h ; 'D'
                mov     cx, 13h
                push    ds
                pop     es
                ;assume es:nothing
                cld
                repne stosb
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                mov     bx, ax
                mov     al, [cs:bx+0Ah]
                mov     byte [ds:52h], al
                mov     ax, 0
                push    ax
                mov     ax, 44h ; 'D'
                push    ds
                push    ax
                mov     bx, [bp+arg_0]
                lea     ax, [bx+58h]
                push    ds
                push    ax
                call    dword [ds:4]
                pop     bp
                retn    2
;sub_FE957       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;osCheckChar     proc near               ; CODE XREF: osKeyHandler+1A↓p
osCheckChar:

arg_0           equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                mov     al, [bp+arg_0]
                cmp     al, 'A'
                jb      short .osCheckLetterWrongChar
                cmp     al, 'Z'
                ja      short .osCheckLetterWrongChar
                add     al, 20h ; ' '
                jmp     short .osCheckCharExit
; ---------------------------------------------------------------------------

.osCheckLetterWrongChar:                 ; CODE XREF: osCheckChar+8↑j
                                        ; osCheckChar+C↑j
                mov     al, [bp+arg_0]

.osCheckCharExit:                        ; CODE XREF: osCheckChar+10↑j
                pop     bp
                retn    2
;osCheckChar     endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;osKeyHandler    proc far                ; DATA XREF: osDoBoot+1B↓o
osKeyHandler:

var_5           equ     -5

                push    ds
                mov     ds, [cs:osBootDataSegment]
                ;assume ds:osBootData
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 6
                mov     ax, catchReadStatusKey
                push    ax              ; command
                mov     ax, 0
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                push    ax
                call    osCheckChar
                mov     [bp+var_5], al
                cmp     al, 'b'
                jz      short .loc_FE9DE
                cmp     al, 'f'
                jz      short .loc_FE9DE
                cmp     al, 'w'
                jz      short .loc_FE9DE
                cmp     al, 'h'
                jz      short .loc_FE9DE
                cmp     al, 2Ah ; '*'
                jnz     short .loc_FE9EE

.loc_FE9DE:                              ; CODE XREF: osKeyHandler+22↑j
                                        ; osKeyHandler+26↑j ...
                cmp     byte [bp+var_5], 'h'
                jnz     short .loc_FE9E8
                mov     byte [bp+var_5], 'w'

.loc_FE9E8:                              ; CODE XREF: osKeyHandler+38↑j
                mov     al, [bp+var_5]
                mov     byte [byte_2CF7], al

.loc_FE9EE:                              ; CODE XREF: osKeyHandler+32↑j
                mov     sp, bp
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
;osKeyHandler    endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;sub_FE9F3       proc near               ; CODE XREF: osReadBootLoader+20↓p
                                        ; osReadBootLoader+66↓p
sub_FE9F3:

var_5           equ     -5
var_4           equ     -4
var_2           equ     -2
arg_0           equ     04h
arg_2           equ     06h

                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 6
                mov     al, byte [bp+arg_2]
                cmp     al, 0FFh
                jz      short .loc_FEA30
                mov     byte [bp+var_5], 2
                mov     ax, [bp+arg_0]
                mov     word [bp+var_4], ax
                lea     ax, [bp+var_5]
                push    ss
                push    ax
                mov     ax, 0
                push    ax
                mov     cx, 3
                push    cx
                push    ax
                push    [bp+arg_2]
                call    OsBootFillStruct
                mov     ax, 14h
                push    ax
                mov     ax, 44h ; 'D'
                push    ds
                push    ax
                lea     ax, [bp+var_2]
                push    ss
                push    ax
                call    dword [ds:4]

.loc_FEA30:                              ; CODE XREF: sub_FE9F3+B↑j
                mov     sp, bp
                pop     bp
                retn    4
;sub_FE9F3       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;sub_FEA36       proc near               ; CODE XREF: osReadBootLoader+7D↓p
sub_FEA36:

var_2           equ     -2
arg_0           equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                push    cx
                lea     ax, [bp+var_2]
                push    ss
                push    ax
                mov     ax, 0
                push    ax
                push    ax
                push    ax
                push    [bp+arg_0]
                call    OsBootFillStruct
                mov     ax, 15h
                push    ax
                mov     ax, 44h ; 'D'
                push    ds
                push    ax
                lea     ax, [bp+var_2]
                push    ss
                push    ax
                call    dword [ds:4]
                mov     sp, bp
                pop     bp
                retn    2
;sub_FEA36       endp

; =============== S U B R O U T I N E =======================================

; argument:
; 1(b) - bubble
; 2(w) - hard disk
; 3(f) - floppy
; 5(x) - unknown (OsDiskDrv)
; also other options available
; Attributes: bp-based frame

;osReadBootLoader proc near              ; CODE XREF: osSelectBootDevice+4F↓p
                                        ; osSelectBootDevice+B1↓p ...
osReadBootLoader:

var_4           equ     -4
var_2           equ     -2
arg_0           equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                push    cx
                push    cx
                mov     bx, [bp+arg_0]
                ;cmp     byte [bx+58h], 0
                db      82h, 7Fh, 58h, 00h                      ;hack for "cmp byte [bx+58h], 0"
                jnz     short .osReadBootLoaderErrorXkey
                mov     ax, [bp+arg_0]
                mov     cx, 6

.loc_FEA77:
                mul     cx
                mov     bx, ax
                push    word [cs:bx+0Ah]
                mov     ax, 3E8h
                push    ax
                call    sub_FE9F3
                mov     ax, 0Ch
                push    ds
                push    ax
                mov     ax, 0
                push    ax
                mov     cx, 34h ; '4'
                push    cx
                push    ax
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                mov     bx, ax
                push    word [cs:bx+0Ah]
                call    OsBootFillStruct
                mov     ax, 1
                push    ax
                mov     ax, 44h ; 'D'
                push    ds
                push    ax
                lea     ax, [bp+var_4]
                push    ss
                push    ax
                call    dword [ds:4]
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                mov     bx, ax
                push    word [cs:bx+0Ah]
                mov     ax, 3A98h
                push    ax
                call    sub_FE9F3
                cmp     word [bp+var_4], 0
                jz      short .loc_FEAE6
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                mov     bx, ax
                push    word [cs:bx+0Ah]
                call    sub_FEA36

.osReadBootLoaderErrorXkey:             ; CODE XREF: osReadBootLoader+C↑j
                                        ; osReadBootLoader+9D↓j
                jmp     .osReadBootLoaderError
; ---------------------------------------------------------------------------

.loc_FEAE6:                              ; CODE XREF: osReadBootLoader+6D↑j
                mov     ax, 0
                push    ax
                les     ax, [cs:opBuf]
                ;assume es:nothing
                push    es
                push    ax
                mov     ax, 200h
                push    ax
                push    [bp+arg_0]
                call    sub_FE8D9
                mov     [bp+var_4], ax
                or      ax, ax
                jnz     short .osReadBootLoaderErrorXkey
                les     si, [cs:opBuf]
                mov     di, 66h ; 'f'
                mov     cx, 0Ch
                push    ds
                push    es
                push    cs
                pop     es
                ;assume es:OsBoot
                pop     ds
                cld

.loc_FEB13:                              ; CODE XREF: osReadBootLoader+B6↓j
        {rmsrc} mov     dx, cx
                jcxz    short .loc_FEB1D
                repe cmpsb
                jz      short .loc_FEB13
        {rmsrc} sub     dx, cx

.loc_FEB1D:                              ; CODE XREF: osReadBootLoader+B2↑j
                dec     dx
                pop     ds
                mov     [bp+var_2], dx
                cmp     dx, 0FFFFh
                jz      short .loc_FEB77
                les     bx, [cs:opBuf]
                ;assume es:nothing
                cmp     byte [es:bx+1FEh], 55h ; 'U'
                jnz     short .osReadBootLoaderError
                cmp     byte [es:bx+1FFh], 0AAh
                jnz     short .osReadBootLoaderError
                les     ax, [cs:opBuf]
                mov     [ds:0], ax
                mov     word [ds:2], es
                mov     word [bp+var_4], 0

.loc_FEB4D:                              ; CODE XREF: osReadBootLoader+13E↓j
                call    SEG_MAIN:CpAddressOf     ; ;    CpAddressOf : PROCEDURE PTR CLEAN;
                                        ; ;
                                        ; ;    This will return the start of the block
                                        ; ;    of variables of the prom in ES:BX
                mov     [ds:8], bx
                mov     word [ds:0Ah], es
                mov     ax, [bp+arg_0]
                mov     cx, 6
                mul     cx
                xchg    ax, bx
                mov     cl, [cs:bx+0Bh]
                mov     bx, ax
                mov     [es:bx+16h], cl
                cmp     word [bp+var_4], 0
                jnz     short .osReadBootLoaderError
                mov     al, 1
                jmp     short .osReadBootLoaderExit
; ---------------------------------------------------------------------------

.loc_FEB77:                              ; CODE XREF: osReadBootLoader+C2↑j
                mov     ax, 200h
                push    ax
                les     ax, [cs:opBuf]
                push    es
                push    ax
                mov     ax, 800h
                push    ax
                push    [bp+arg_0]
                call    sub_FE8D9
                mov     [bp+var_4], ax
                les     ax, [cs:opBuf]
                push    es
                push    ax              ; pBuf
                mov     ax, 800h
                push    ax              ; len
                call    SEG_MAIN:MakeChecksum
                or      ax, ax
                jz      short .loc_FEB4D
                mov     ax, msgCannotBootChecksum ; "Cannot boot: Checksum error\r\n"
                push    cs
                push    ax
                mov     ax, 1Dh
                push    ax
                call    SEG_MAIN:CnoLineOut

.osReadBootLoaderError:                  ; CODE XREF: osReadBootLoader:osReadBootLoaderErrorXkey?↑j
                                        ; osReadBootLoader+CF↑j ...
                mov     al, 0

.osReadBootLoaderExit:                   ; CODE XREF: osReadBootLoader+112↑j
                mov     sp, bp
                pop     bp
                retn    2
;osReadBootLoader endp


; =============== S U B R O U T I N E =======================================

; Attributes: noreturn bp-based frame

;osSelectBootDevice proc near            ; CODE XREF: osDoBoot+3D↓p
osSelectBootDevice:

var_3           equ     -3
var_2           equ     -2

                push    bp
        {rmsrc} mov     bp, sp
                push    cx
                push    cx
                mov     ax, 1000        ; Wait 1000 ms (1sec) for user keypress

.loc_FEBC1:                              ; CODE XREF: osSelectBootDevice+13A↓j
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                mov     word [bp+var_2], 0

.loc_FEBCC:                              ; CODE XREF: osSelectBootDevice+36↓j
                mov     ax, [bp+var_2]
                cmp     ax, 5
                ja      short .loc_FEBF1
                mov     cx, 6
                mul     cx
                mov     bx, ax
                les     ax, [cs:bx+6]
                mov     [ds:4], ax
                mov     word [ds:6], es
                push    [bp+var_2]
                call    sub_FE957
                inc     word [bp+var_2]
                jnz     short .loc_FEBCC

.loc_FEBF1:                              ; CODE XREF: osSelectBootDevice+19↑j
                cmp     byte [ds:57h], 66h ; 'f'
                jnz     short .loc_FEC23
                les     ax, [cs:dword_FE7F8]
                mov     [ds:4], ax
                mov     word [ds:6], es
                mov     ax, 3
                push    ax
                call    osReadBootLoader
                mov     [bp+var_3], al
                rcr     al, 1
                jb      short .loc_FEC70
                les     ax, [cs:dword_FE7FE]
                mov     [ds:4], ax
                mov     word [ds:6], es
                mov     ax, 4
                jmp     short .loc_FEC69
; ---------------------------------------------------------------------------

.loc_FEC23:                              ; CODE XREF: osSelectBootDevice+3D↑j
                cmp     byte [ds:57h], 77h ; 'w'
                jnz     short .loc_FEC3B
                les     ax, [cs:dword_FE7F2]
                mov     [ds:4], ax
                mov     word [ds:6], es
                mov     ax, 2
                jmp     short .loc_FEC69
; ---------------------------------------------------------------------------

.loc_FEC3B:                              ; CODE XREF: osSelectBootDevice+6F↑j
                cmp     byte [ds:57h], 62h ; 'b'
                jnz     short .loc_FEC53
                les     ax, dword [cs:offBubbleCommand]
                mov     [ds:4], ax
                mov     word [ds:6], es
                mov     ax, 1
                jmp     short .loc_FEC69
; ---------------------------------------------------------------------------

.loc_FEC53:                              ; CODE XREF: osSelectBootDevice+87↑j
                cmp     byte [ds:57h], 78h ; 'x'
                jnz     short .loc_FEC72
                les     ax, [cs:dword_FE804]
                mov     [ds:4], ax
                mov     word [ds:6], es
                mov     ax, 5

.loc_FEC69:                              ; CODE XREF: osSelectBootDevice+68↑j
                                        ; osSelectBootDevice+80↑j ...
                push    ax
                call    osReadBootLoader
                mov     byte [bp+var_3], al

.loc_FEC70:                              ; CODE XREF: osSelectBootDevice+57↑j
                jmp     short .loc_FECA3
; ---------------------------------------------------------------------------

.loc_FEC72:                              ; CODE XREF: osSelectBootDevice+9F↑j
                mov     word [bp+var_2], 1

.loc_FEC77:                              ; CODE XREF: osSelectBootDevice+E8↓j
                mov     ax, [bp+var_2]
                cmp     ax, 5
                ja      short .loc_FECA3
                mov     cx, 6
                mul     cx
                mov     bx, ax
                les     ax, [cs:bx+6]
                mov     [ds:4], ax
                mov     word [ds:6], es
                push    [bp+var_2]
                call    osReadBootLoader
                mov     [bp+var_3], al
                rcr     al, 1
                jb      short .loc_FECA3
                inc     word [bp+var_2]
                jnz     short .loc_FEC77

.loc_FECA3:                              ; CODE XREF: osSelectBootDevice:loc_FEC70↑j
                                        ; osSelectBootDevice+C4↑j ...
                mov     al, [bp+var_3]
                rcr     al, 1
                jnb     short .loc_FECE2
                mov     ax, catchKeyboard
                push    ax              ; command
                mov     ax, 0
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll
                mov     [bp+var_2], ax
                les     ax, dword [ds:40h]
                push    es
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetKeyHandler
                mov     [ds:40h], bx
                mov     word [ds:42h], es
                mov     ax, 0
                mov     di, 0
                mov     dx, 40h ; '@'
                mov     cx, 12C0h
                mov     es, dx
                ;assume es:video_ram
                cld
                repne stosw
                call    dword [ds:0]

.loc_FECE2:                              ; CODE XREF: osSelectBootDevice+EF↑j
                mov     ax, msgCannotBootStorage ; "Cannot boot: Storage medium error\r\n"
                push    cs
                push    ax
                mov     ax, 23h ; '#'
                push    ax
                call    SEG_MAIN:CnoLineOut
                mov     ax, 7D0h
                jmp     .loc_FEBC1
;osSelectBootDevice endp

; =============== S U B R O U T I N E =======================================

; Attributes: noreturn bp-based frame

;osDoBoot        proc far                ; DATA XREF: initMultitasking+52↑o
osDoBoot:

var_2           equ     -2

                push    ds
                mov     ds, [cs:osBootDataSegment]
                ;assume ds:osBootData
                push    bp
        {rmsrc} mov     bp, sp
                push    cx
                les     ax, [cs:bootLoaderSegOffsetEntry]
                ;assume es:nothing
                mov     [bootLoaderOffset], ax
                mov     word [bootLoaderSegment], es
                mov     byte [byte_2CF7], 2Ah ; '*'
                mov     ax, osKeyHandler
                push    cs
                push    ax              ; pRoutine
                call    SEG_MAIN:CpSetKeyHandler
                mov     [osKeyHandlerOffset], bx
                mov     word [osKeyHandlerSeg], es
                mov     ax, catchKeyboard
                push    ax              ; command
                mov     ax, 1
                push    ax              ; theData
                call    SEG_MAIN:CpCatchAll

.loc_FED30:
                mov     word [bp+var_2], ax
                call    osSelectBootDevice
; ---------------------------------------------------------------------------
                mov     sp, bp

.loc_FED38:
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
;osDoBoot        endp

; ---------------------------------------------------------------------------
                db    0
;OsBoot          ends


end match
