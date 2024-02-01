match FALSE, _OS_disk_drv_asm
display 'Including OS Disk driver segment', 10

_OS_disk_drv_asm equ TRUE


; Segment type: Pure code
;OsDskDrv        segment byte public 'CODE'
;                assume cs:OsDskDrv
org 0Ch
;                assume es:nothing, ss:nothing, ds:nothing
word_FED3C      dw 0FF2Fh               ; DATA XREF: OsDskDriver+1↓r

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsDskDriver     proc far                ; CODE XREF: j_OsDskDriver↓J
OsDskDriver:

var_4E          equ     -4Eh
var_4A          equ     -4Ah
var_49          equ     -49h
var_47          equ     -47h
var_46          equ     -46h
var_45          equ     -45h
var_44          equ     -44h
time            equ     -42h
var_40          equ     -40h
pError_         equ     -3Eh
var_3A          equ     -3Ah
var_4           equ     -4
pError          equ     08h
pPlist          equ     0Ch
request         equ     10h

                push    ds
                mov     ds, [cs:word_FED3C]
                ;assume ds:nothing
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 4Ch
                mov     al, [ds:3A68h]
                rcr     al, 1

.loc_FED4F:
                jnb     short .loc_FED66
                push    word [ds:3A54h] ; sid
                mov     ax, 0FFFFh
                push    ax              ; timeLimit
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpWait

.loc_FED63:
                mov     [bp+var_40], ax

.loc_FED66:                              ; CODE XREF: OsDskDriver:loc_FED4F↑j
                les     bx, [bp+pPlist]
                les     ax, [es:bx+2]
                mov     word [bp+var_4], ax

.loc_FED70:
                mov     word [bp+var_4+2], es

.loc_FED73:
                mov     ax, 0
                mov     [ds:3A50h], ax
                les     bx, [bp+pError]
                mov     [es:bx], ax

.loc_FED7F:
                mov     ax, [ds:3A56h]
                rcr     al, 1
                jnb     short .loc_FEDAE

.loc_FED86:
                mov     byte [bp+var_4A], 0
                lea     ax, [bp+var_4A]
                les     bx, [bp+pPlist]

.loc_FED90:
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, 14h
                push    ax
                push    es
                push    bx
                lea     ax, [bp+pError_+2]
                push    ss
                push    ax
                call    SEG_MAIN:GPIBdriver
                mov     word [ds:3A56h], 0

.loc_FEDAE:                              ; CODE XREF: OsDskDriver+46↑j
                mov     ax, 15h
                cmp     [bp+request], ax
                jnz     short .loc_FEDD6
                les     bx, [bp+pPlist]
                mov     bl, [es:bx+0Eh]
                mov     bh, 0
                mov     byte [bx+3A69h], 0
                push    ax
                les     ax, [bp+pPlist]
                push    es
                push    ax
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver
                jmp     short .loc_FEDF2
; ---------------------------------------------------------------------------

.loc_FEDD6:                              ; CODE XREF: OsDskDriver+76↑j
                cmp     word [bp+request], 14h
                jnz     short .loc_FEDF5
                mov     word [ds:3A50h], 0
                les     bx, [bp+var_4]
                cmp     byte [es:bx], 2
                jnz     short .loc_FEDF2
                mov     ax, [es:bx+1]
                mov     [ds:3A58h], ax

.loc_FEDF2:                              ; CODE XREF: OsDskDriver+96↑j
                                        ; OsDskDriver+AB↑j
                jmp     .loc_FF276
; ---------------------------------------------------------------------------

.loc_FEDF5:                              ; CODE XREF: OsDskDriver+9C↑j
                mov     ax, [bp+request]
                or      ax, ax
                jz      short .loc_FEE1D
                cmp     ax, 1
                jz      short .loc_FEE1D
                cmp     ax, 4
                jz      short .loc_FEE1D
                cmp     ax, 5
                jz      short .loc_FEE1D
                cmp     ax, 10h
                jz      short .loc_FEE1D
                cmp     ax, 11h
                jz      short .loc_FEE1D
                cmp     ax, 16h
                jz      short .loc_FEE1D
                jmp     .loc_FF22C
; ---------------------------------------------------------------------------

.loc_FEE1D:                              ; CODE XREF: OsDskDriver+BC↑j
                                        ; OsDskDriver+C1↑j ...
                les     bx, [bp+pPlist]
                cmp     byte [es:bx+0Eh], 20h ; ' '
                jb      short .loc_FEE2A

.loc_FEE27:
                jmp     .loc_FF22C
; ---------------------------------------------------------------------------

.loc_FEE2A:                              ; CODE XREF: OsDskDriver+E7↑j
                mov     ax, [es:bx+0Ah]

.loc_FEE2E:
                or      ax, ax
                jnz     short .loc_FEE35
                jmp     .loc_FF22C
; ---------------------------------------------------------------------------

.loc_FEE35:                              ; CODE XREF: OsDskDriver+F2↑j
                mov     word [ds:3A50h], 0
                les     cx, [es:bx+2]
                mov     [ds:3A64h], cx
                mov     word [ds:3A66h], es
                mov     [bp+var_3A], ax
                mov     cx, [bp+request]
                mov     [ds:3A5Ah], cx
                les     bx, [bp+pPlist]
                mov     cx, [es:bx+6]
                mov     dx, [es:bx+8]
                mov     [ds:3A5Dh], cx
                mov     [ds:3A5Fh], dx
                mov     [ds:3A61h], ax
                mov     al, [es:bx+0Ch]
                mov     [ds:3A63h], al
                mov     al, [es:bx+0Dh]
                mov     [ds:3A5Ch], al
                mov     ax, 3A5Ah
                mov     [es:bx+2], ax
                mov     word [es:bx+4], ds
                mov     word [es:bx+0Ah], 0Ah
                mov     al, [ds:3A68h]
                rcr     al, 1
                jb      short .loc_FEECC
                ;les     ax, dword [ds:dword_FF30C]
                les     ax, dword [ds:1Ch]                      ;must be "les ax, dword [ds:dword_FF30C]"
                push    es
                call    SEG_MAIN:CpCreateSemaphore
                ;les     ax, dword [ds:dword_FF30C]
                les     ax, dword [ds:1Ch]                      ;must be "les ax, dword [ds:dword_FF30C]"
                mov     word [ds:3A52h], es
                ;les     ax, [ds:dword_FF310]
                les     ax, [ds:20h]                            ;must be "les ax, [ds:dword_FF310]"
                push    es
                call    SEG_MAIN:CpCreateSemaphore
                ;les     ax, dword [ds:dword_FF310]
                les     ax, [ds:20h]                            ;must be "les ax, [ds:dword_FF310]"
                mov     word [ds:3A54h], es
                push    word [ds:3A54h] ; sid
                mov     ax, 1
                push    ax              ; mode
                mov     ax, 0
                push    ax              ; note
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpSignal
                mov     byte [ds:3A68h], 0FFh

.loc_FEECC:                              ; CODE XREF: OsDskDriver+14D↑j
                les     bx, [bp+pPlist]
                mov     bl, [es:bx+0Eh]
                mov     bh, 0
                mov     al, [bx+3A69h]
                rcr     al, 1
                jb      short .loc_FEF13
                mov     byte [bp+var_4A], 2
                mov     ax, [ds:3A52h]
                mov     [bp+var_49], ax
                lea     ax, [bp+var_4A]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, 14h
                push    ax
                push    es
                push    bx
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver
                les     bx, [bp+pPlist]
                mov     bl, [es:bx+0Eh]
                mov     bh, 0
                mov     byte [bx+3A69h], 0FFh

.loc_FEF13:                              ; CODE XREF: OsDskDriver+19D↑j
                mov     byte [bp+var_47], 0
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                jz      short .loc_FEF2B
                mov     [bp+time], ax
                jmp     short .loc_FEF30
; ---------------------------------------------------------------------------

.loc_FEF2B:                              ; CODE XREF: OsDskDriver+1E6↑j
                mov     word [bp+time], 3A98h

.loc_FEF30:                              ; CODE XREF: OsDskDriver+1EB↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     ax, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, 5
                push    ax
                push    es
                push    bx
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver
                cmp     word [ds:3A50h], 0
                jz      short .loc_FEF5E
                jmp     .loc_FF276
; ---------------------------------------------------------------------------

.loc_FEF5E:                              ; CODE XREF: OsDskDriver+21B↑j
                cmp     word [bp+request], 5
                jz      short .loc_FEF67
                jmp     .loc_FF040
; ---------------------------------------------------------------------------

.loc_FEF67:                              ; CODE XREF: OsDskDriver+224↑j
                mov     ax, [ds:3A61h]
                les     bx, [bp+pPlist]
                mov     word [es:bx+0Ah], ax
                push    es
                les     ax, [ds:3A64h]
                push    es
                ;mov     es, [bp+var_4E]
                db      8Eh, 86h, 0B2h, 0FFh
                mov     [es:bx+2], ax
                pop     dx
                mov     [es:bx+4], dx
                mov     byte [bp+var_47], 0
                ;db      8Eh, 86h, 0B2h, 0FFh                    ;hack for "mov byte [bp+var_47], 0"
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                pop     cx
                jz      short .loc_FEF9D
                mov     [bp+time], ax
                jmp     short .loc_FEFA2
; ---------------------------------------------------------------------------

.loc_FEF9D:                              ; CODE XREF: OsDskDriver+258↑j
                mov     word [bp+time], 3A98h

.loc_FEFA2:                              ; CODE XREF: OsDskDriver+25D↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     ax, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, 5
                push    ax
                push    es
                push    bx
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver

.loc_FEFC6:
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF03D
                les     bx, [bp+pPlist]
                mov     word [es:bx+0Ah], 7
                mov     ax, 3A89h
                mov     [es:bx+2], ax
                mov     word [es:bx+4], ds
                mov     byte [bp+var_47], 0
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                jz      short .loc_FEFF9
                mov     [bp+time], ax
                jmp     short .loc_FEFFE
; ---------------------------------------------------------------------------

.loc_FEFF9:                              ; CODE XREF: OsDskDriver+2B4↑j
                mov     word [bp+time], 3A98h

.loc_FEFFE:                              ; CODE XREF: OsDskDriver+2B9↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     cx, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], cx
                mov     word [es:bx+11h], ss
                mov     word [bp+pError_], 0
                push    word [ds:3A52h] ; sid
                push    ax              ; timeLimit
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpWait
                mov     [bp+var_40], ax
                cmp     ax, 0Fh
                jnz     short .loc_FF037
                cmp     word [bp+pError_], 0
                jnz     short .loc_FF037
                jmp     .loc_FF1F8
; ---------------------------------------------------------------------------

.loc_FF037:                              ; CODE XREF: OsDskDriver+2EE↑j
                                        ; OsDskDriver+2F4↑j
                mov     word [ds:3A50h], 1C3h

.loc_FF03D:                              ; CODE XREF: OsDskDriver+28D↑j
                jmp     .loc_FF20B
; ---------------------------------------------------------------------------

.loc_FF040:                              ; CODE XREF: OsDskDriver+226↑j
                cmp     word [bp+request], 4
                jz      short .loc_FF049
                jmp     .loc_FF0FF
; ---------------------------------------------------------------------------

.loc_FF049:                              ; CODE XREF: OsDskDriver+306↑j
                les     ax, [ds:3A64h]
                push    es
                les     bx, [bp+pPlist]
                mov     [es:bx+2], ax
                pop     dx
                mov     [es:bx+4], dx
                mov     ax, [bp+var_3A]
                mov     [es:bx+0Ah], ax
                mov     byte [bp+var_47], 0
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                jz      short .loc_FF079
                mov     [bp+time], ax
                jmp     short .loc_FF07E
; ---------------------------------------------------------------------------

.loc_FF079:                              ; CODE XREF: OsDskDriver+334↑j
                mov     word [bp+time], 3A98h

.loc_FF07E:                              ; CODE XREF: OsDskDriver+339↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     cx, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], cx
                mov     word [es:bx+11h], ss
                mov     word [bp+pError_], 0
                push    word [ds:3A52h] ; sid
                push    ax              ; timeLimit
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpWait
                mov     [bp+var_40], ax
                cmp     ax, 0Fh
                jnz     short .loc_FF0C9
                cmp     word [bp+pError_], 0
                jnz     short .loc_FF0C9
                mov     ax, 4
                push    ax
                les     ax, [bp+pPlist]
                push    es
                push    ax
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver
                jmp     short .loc_FF0CF
; ---------------------------------------------------------------------------

.loc_FF0C9:                              ; CODE XREF: OsDskDriver+36E↑j
                                        ; OsDskDriver+374↑j
                mov     word [ds:3A50h], 1C3h

.loc_FF0CF:                              ; CODE XREF: OsDskDriver+389↑j
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF0EA
                les     bx, [bp+pPlist]
                cmp     word [es:bx+0Ah], 7
                jnz     short .loc_FF0EA
                les     bx, [ds:3A64h]
                mov     ax, [es:bx]
                jmp     .loc_FF21F
; ---------------------------------------------------------------------------

.loc_FF0EA:                              ; CODE XREF: OsDskDriver+396↑j
                                        ; OsDskDriver+3A0↑j
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF0FA
                les     bx, [bp+pPlist]
                cmp     word [es:bx+0Ah], 200h

.loc_FF0FA:                              ; CODE XREF: OsDskDriver+3B1↑j
                jnz     short .loc_FF172
                jmp     .loc_FF262
; ---------------------------------------------------------------------------

.loc_FF0FF:                              ; CODE XREF: OsDskDriver+308↑j
                cmp     word [bp+request], 1
                jnz     short .loc_FF175
                les     ax, [ds:3A64h]
                push    es
                les     bx, [bp+pPlist]
                mov     [es:bx+2], ax
                pop     dx
                mov     [es:bx+4], dx
                mov     ax, [bp+var_3A]
                mov     [es:bx+0Ah], ax
                mov     byte [bp+var_47], 0
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                jz      short .loc_FF135
                mov     [bp+time], ax
                jmp     short .loc_FF13A
; ---------------------------------------------------------------------------

.loc_FF135:                              ; CODE XREF: OsDskDriver+3F0↑j
                mov     word [bp+time], 3A98h

.loc_FF13A:                              ; CODE XREF: OsDskDriver+3F5↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     ax, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, 4
                push    ax
                push    es
                push    bx
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF172
                les     bx, [bp+pPlist]
                cmp     word [es:bx+0Ah], 34h ; '4'
                jnz     short .loc_FF172
                jmp     .loc_FF276
; ---------------------------------------------------------------------------

.loc_FF172:                              ; CODE XREF: OsDskDriver:loc_FF0FA↑j
                                        ; OsDskDriver+425↑j ...
                jmp     .loc_FF224
; ---------------------------------------------------------------------------

.loc_FF175:                              ; CODE XREF: OsDskDriver+3C5↑j
                mov     ax, 0
                mov     [ds:3A50h], ax
                mov     cx, 3A89h
                les     bx, [bp+pPlist]
                mov     [es:bx+2], cx
                mov     word [es:bx+4], ds
                mov     word [es:bx+0Ah], 7
                mov     [bp+var_47], al
                mov     al, 0FFh
                mov     [bp+var_46], al
                mov     [bp+var_45], al
                mov     ax, [ds:3A58h]
                or      ax, ax
                jz      short .loc_FF1A6
                mov     [bp+time], ax
                jmp     short .loc_FF1AB
; ---------------------------------------------------------------------------

.loc_FF1A6:                              ; CODE XREF: OsDskDriver+461↑j
                mov     word [bp+time], 3A98h

.loc_FF1AB:                              ; CODE XREF: OsDskDriver+466↑j
                mov     ax, [bp+time]
                mov     [bp+var_44], ax
                lea     ax, [bp+var_47]
                les     bx, [bp+pPlist]
                mov     [es:bx+0Fh], ax
                mov     word [es:bx+11h], ss
                mov     ax, [bp+request]
                cmp     ax, 11h
                jz      short .loc_FF1CC
                cmp     ax, 16h
                jnz     short .loc_FF1F1

.loc_FF1CC:                              ; CODE XREF: OsDskDriver+487↑j
                mov     word [bp+pError_], 0
                push    word [ds:3A52h] ; sid
                mov     ax, 0FFFFh
                push    ax              ; timeLimit
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpWait
                mov     [bp+var_40], ax
                cmp     ax, 0Fh
                jz      short .loc_FF1F1
                mov     word [ds:3A50h], 1C3h

.loc_FF1F1:                              ; CODE XREF: OsDskDriver+48C↑j
                                        ; OsDskDriver+4AB↑j
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF20B

.loc_FF1F8:                              ; CODE XREF: OsDskDriver+2F6↑j
                mov     ax, 4
                push    ax
                les     ax, [bp+pPlist]
                push    es
                push    ax
                mov     ax, 3A50h
                push    ds
                push    ax
                call    SEG_MAIN:GPIBdriver

.loc_FF20B:                              ; CODE XREF: OsDskDriver:loc_FF03D↑j
                                        ; OsDskDriver+4B8↑j
                cmp     word [ds:3A50h], 0
                jnz     short .loc_FF224
                les     bx, [bp+pPlist]
                cmp     word [es:bx+0Ah], 7
                jnz     short .loc_FF224
                mov     ax, [ds:3A89h]

.loc_FF21F:                              ; CODE XREF: OsDskDriver+3A9↑j
                mov     [ds:3A50h], ax
                jmp     short .loc_FF276
; ---------------------------------------------------------------------------

.loc_FF224:                              ; CODE XREF: OsDskDriver:loc_FF172↑j
                                        ; OsDskDriver+4D2↑j ...
                mov     word [ds:3A56h], 0FFh
                jmp     short .loc_FF276
; ---------------------------------------------------------------------------

.loc_FF22C:                              ; CODE XREF: OsDskDriver+DC↑j
                                        ; OsDskDriver:loc_FEE27↑j ...
                mov     ax, [bp+request]
                or      ax, ax
                jz      short .loc_FF251
                cmp     ax, 1
                jz      short .loc_FF251
                cmp     ax, 4
                jz      short .loc_FF251
                cmp     ax, 5
                jz      short .loc_FF251
                cmp     ax, 16
                jz      short .loc_FF251
                cmp     ax, 17
                jz      short .loc_FF251
                cmp     ax, 22
                jnz     short .loc_FF26A

.loc_FF251:                              ; CODE XREF: OsDskDriver+4F3↑j
                                        ; OsDskDriver+4F8↑j ...
                les     bx, [bp+pPlist]
                cmp     byte [es:bx+0Eh], 20h ; ' '
                jnb     short .loc_FF26A
                cmp     word [es:bx+0Ah], 0
                jnz     short .loc_FF26A

.loc_FF262:                              ; CODE XREF: OsDskDriver+3BE↑j
                mov     word [ds:3A50h], 0
                jmp     short .loc_FF276
; ---------------------------------------------------------------------------

.loc_FF26A:                              ; CODE XREF: OsDskDriver+511↑j
                                        ; OsDskDriver+51B↑j ...
                mov     word [ds:3A56h], 0FFh
                mov     word [ds:3A50h], 23h ; '#'

.loc_FF276:                              ; CODE XREF: OsDskDriver:loc_FEDF2↑j
                                        ; OsDskDriver+21D↑j ...
                push    word [ds:3A54h] ; sid
                mov     ax, 1
                push    ax              ; mode
                mov     ax, 0
                push    ax              ; note
                lea     ax, [bp+pError_]
                push    ss
                push    ax              ; pError
                call    SEG_MAIN:CpSignal
                mov     ax, [ds:3A50h]

.loc_FF28F:
                les     bx, [bp+pError]
                mov     [es:bx], ax
                mov     sp, bp
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    0Ah
;OsDskDriver     endp ; sp-analysis failed

; ---------------------------------------------------------------------------
                dw 100h
                dw 0FCh
                dw 600h
                db    1
                dw 3FDh
                dw 3FEh
                dw 1
                db    0
a384kByteBubble db '384K-Byte Bubble  GRiD PN 100009'
                dw 40h
                dw 1800h
                dw 1
aBubble12111982 db 'Bubble 1.2 11/19/82'
                db 0
                db    0
                db 0C8h
                db    2
                db 0
                db    0
                db 0C9h
                db    2
                db 0
                db    0
                db    0
                dw 0
                dw 0E800h
                dw 2DFh
                db 0
                dw 0DFE8h
                dw 2
                dw 0DFE8h
                db 0
aDisk1092782    db 'Disk 1.0 9/27/82'
dword_FF30C     dd 2D20000h             ; DATA XREF: OsDskDriver+14F↑r
                                        ; OsDskDriver+159↑r
dword_FF310     dd 2D30000h             ; DATA XREF: OsDskDriver+161↑r
                                        ; OsDskDriver+16B↑r
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
;OsDskDrv        ends


end match
