match FALSE, _String_utils_asm
display 'Including String utils segment', 10

_String_utils_asm equ TRUE


org 10h
; =============== S U B R O U T I N E =======================================
; Attributes: bp-based frame
; if (arg_2 > arg_0) 
;       reg_ax = arg_0
; else
;       reg_ax = arg_2

;sub_FE300       proc far
sub_FE300:
arg_0           equ     08h
arg_2           equ     0Ah

                push    ds
                mov     ds, [cs:word_FC01E]
                ;assume ds:nothing
                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, [bp+arg_0]
                cmp     [bp+arg_2], ax
                ja      short .loc_FE314
                mov     ax, [bp+arg_2]

.loc_FE314:                              ; CODE XREF: sub_FE300+F↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;sub_FE300       endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame
; if (arg_2 > arg_0) 
;       reg_ax = arg_2
; else
;       reg_ax = arg_0

;sub_FE319       proc far
sub_FE319:
arg_0           equ     08h
arg_2           equ     0Ah

                push    ds
                mov     ds, [cs:word_FC01E]
                ;assume ds:nothing
                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, [bp+arg_2]
                cmp     ax, [bp+arg_0]
                ja      short .loc_FE32D
                mov     ax, [bp+arg_0]

.loc_FE32D:                              ; CODE XREF: sub_FE319+F↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    4
;sub_FE319       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;Upper           proc far                ; CODE XREF: CompareChars+28↓P
Upper:

char            equ     08h

                push    ds
                mov     ds, [cs:word_FC01E]
                ;assume ds:nothing
                push    bp
        {rmsrc} mov     bp, sp
                mov     al, [bp+char]
                mov     cl, 'a'
        {rmsrc} cmp     al, cl
                jb      short .loc_FE34E
                cmp     al, 'z'
                ja      short .loc_FE34E
                add     al, 41h ; 'A'
        {rmsrc} sub     al, cl
                jmp     short .UpperExit
; ---------------------------------------------------------------------------

.loc_FE34E:                              ; CODE XREF: Upper+10↑j
                                        ; Upper+14↑j
                mov     al, [bp+char]

.UpperExit:                              ; CODE XREF: Upper+1A↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    2
;Upper           endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CompareChars    proc far                ; CODE XREF: OsSearchInQ+3B↑P
CompareChars:

var_2           equ     -2
lenCompare      equ     08h
pString2        equ     0Ah
pString1        equ     0Eh

                push    ds
                mov     ds, [cs:word_FC01E]
                ;assume ds:nothing
                push    bp
        {rmsrc} mov     bp, sp
                push    cx
                cmp     word [bp+lenCompare], 0
                jz      short .CompareEqual
                mov     word [bp+var_2], 0

.loc_FE36B:                              ; CODE XREF: CompareChars+48↓j
                mov     ax, [bp+lenCompare]
                dec     ax
                mov     cx, [bp+var_2]
        {rmsrc} cmp     cx, ax
                ja      short .CompareEqual
                mov     si, cx
                les     bx, [bp+pString1]
                ;assume es:nothing
                push    word [es:bx+si]
                call    SEG_UNKOWN:Upper
                push    ax
                les     bx, [bp+pString2]
                mov     si, [bp+var_2]
                push    word [es:bx+si]
                call    SEG_UNKOWN:Upper
                pop     cx
        {rmsrc} cmp     cl, al
                jz      short .loc_FE39B
                mov     al, 0
                jmp     short .CompareExit
; ---------------------------------------------------------------------------

.loc_FE39B:                              ; CODE XREF: CompareChars+3F↑j
                inc     word [bp+var_2]
                jnz     short .loc_FE36B

.CompareEqual:                           ; CODE XREF: CompareChars+E↑j
                                        ; CompareChars+1E↑j
                mov     al, 1

.CompareExit:                            ; CODE XREF: CompareChars+43↑j
                mov     sp, bp
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    10
;CompareChars    endp

                repeat 0C0h - $
                    db 00h
                end repeat



end match
