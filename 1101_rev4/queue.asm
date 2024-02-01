match FALSE, _os_queue_asm
display 'Including queue routines', 10

_os_queue_asm equ TRUE

; these routines are based on original source
; from file CCPROM/QUEUE.ASM

; =============== S U B R O U T I N E =======================================

;    OsNewQElement : PROCEDURE (pQcb) EidType
;        DCL pQcb PTR;
;        DCL error WORD;
;
; This will allocate a new queue element using
; the length stored in the Qcb.  This uses IntAllocate
; and uses the system pid.
; Attributes: bp-based frame

;OsNewQElement   proc far
OsNewQElement:

error           equ     -2
pQcb            equ     06h

                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 2
                mov     ax, 0
                push    ax
                les     bx, [bp+pQcb]
                push    word [es:bx+7]
                lea     ax, [bp+error]
                push    ss
                push    ax
                call    SEG_MAIN:IntAllocate
                mov     ax, 0FFFFh
                cmp     word [bp+error], 0
                jnz     short .OsNewQDone
                mov     ax, es

.OsNewQDone:                             ; CODE XREF: OsNewQElement+22↑j
        {rmsrc} mov     sp, bp
                pop     bp
                retf    4
;OsNewQElement   endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsInitQCB       proc far
OsInitQCB:

len             equ     06h
usesCheck       equ     08h
pQcb            equ     0Ah

                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, 0FFFFh
                les     bx, [bp+pQcb]
                ;mov     [es:bx+QcbType.headOfQ], ax
                mov     [es:bx], ax                             ;must be "mov [es:bx+QcbType.headOfQ], ax"
                ;mov     [es:bx+QcbType.tailOfQ], ax
                mov     [es:bx+02h], ax                         ;must be "mov [es:bx+QcbType.tailOfQ], ax"
                mov     al, [bp+usesCheck]
                ;mov     [es:bx+QcbType.usesChecksum], al
                mov     [es:bx+04h], al                         ;must be "mov [es:bx+QcbType.usesChecksum], al"
                mov     ax, [bp+len]
                ;mov     [es:bx+QcbType.elementLength], ax
                mov     [es:bx+07h], ax                         ;must be "mov [es:bx+QcbType.qcbCount], 0"
                ;mov     [es:bx+QcbType.qcbCount], 0
                mov     word [es:bx+05h], 0                     ;must be "mov [es:bx+QcbType.qcbCount], 0"
        {rmsrc} mov     sp, bp
                pop     bp
                retf    8
;OsInitQCB       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsElementChecksum proc far
OsElementChecksum:

eid             equ     06h
pQcb            equ     08h

                push    bp
        {rmsrc} mov     bp, sp
                mov     es, [bp+eid]
                push    es
                mov     ax, 2
                push    ax              ; pBuf
                les     bx, [bp+pQcb]
                ;mov     ax, [es:bx+QcbType.elementLength]
                mov     ax, [es:bx+07h]                         ;must be "mov ax, [es:bx+QcbType.elementLength]"
                ;sub     ax, 2
                db      2Dh, 02h, 00h                           ;hack for "sub ax, 2"
                push    ax              ; len
                call    SEG_MAIN:MakeChecksum
        {rmsrc} mov     sp, bp
                pop     bp
                retf    6
;OsElementChecksum endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsVerifyChecksum proc far
OsVerifyChecksum:

eid             equ     06h
pQcb            equ     08h

                push    bp
        {rmsrc} mov     bp, sp
                les     ax, [bp+pQcb]
                push    es
                push    ax
                push    [bp+eid]
                call    SEG_MAIN:OsElementChecksum
                mov     es, [bp+eid]
                ;cmp     ax, [es:QElementType.checkSum]
                cmp     ax, [es:00h]                            ;must be "cmp ax, [es:QElementType.checkSum]"
                mov     al, 0FFh
                jz      short .OsVerifyDone
                mov     al, 0

.OsVerifyDone:                           ; CODE XREF: OsVerifyChecksum+1A↑j
        {rmsrc} mov     sp, bp
                pop     bp
                retf    6
;OsVerifyChecksum endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;ReplaceOp       proc near
ReplaceOp:

len             equ     -2
nextEid         equ     06h
newEid          equ     08h
prevEid         equ     0Ah
pQcb            equ     0Ch

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 2
                les     bx, [bp+pQcb]
                ;cmp     word [bp+newEid], 0FFFFh
                db      81h, 7Eh, 08h, 0FFh, 0FFh               ;hack for "cmp word [bp+newEid], 0FFFFh"
                jnz     short .ReplaceOther
                ;cmp     word [bp+prevEid], 0FFFFh
                db      81h, 7Eh, 0Ah, 0FFh, 0FFh               ;hack for "cmp word [bp+prevEid], 0FFFFh"
                jnz     short .Replace10
                ;cmp     word [bp+nextEid], 0FFFFh
                db      81h, 7Eh, 06h, 0FFh, 0FFh               ;hack for "cmp word [bp+nextEid], 0FFFFh"
                jnz     short .Replace10
                ;mov    word  [es:bx+QcbType.headOfQ], 0FFFFh
                mov     word [es:bx], 0FFFFh                    ;must be "mov [es:bx+QcbType.headOfQ], 0FFFFh"
                ;mov    word [es:bx+QcbType.tailOfQ], 0FFFFh
                mov     word [es:bx+02h], 0FFFFh                ;must be "mov [es:bx+QcbType.tailOfQ], 0FFFFh"
                jmp     short .ReplaceCont
; ---------------------------------------------------------------------------
                nop
; ---------------------------------------------------------------------------

.Replace10:                              ; CODE XREF: ReplaceOp+16↑j
                                        ; ReplaceOp+1D↑j
                ;cmp     word [bp+prevEid], 0FFFFh
                db      81h, 7Eh, 0Ah, 0FFh, 0FFh               ;hack for "cmp word [bp+prevEid], 0FFFFh"
                jnz     short .Replace20
                mov     ax, [bp+nextEid]
                ;mov     [es:bx+QcbType.headOfQ], ax
                mov     [es:bx], ax                             ;must be "mov [es:bx+QcbType.headOfQ], ax"
                mov     ds, word [bp+nextEid]
                ;mov     word [ds:QElementType.prev], 0FFFFh
                mov     word [ds:04h], 0FFFFh                   ;must be "mov word [ds:QElementType.prev], 0FFFFh"
                jmp     short .ReplaceCont
; ---------------------------------------------------------------------------

.Replace20:                              ; CODE XREF: ReplaceOp+32↑j
                ;cmp     word [bp+nextEid], 0FFFFh
                db      81h, 7Eh, 06h, 0FFh, 0FFh               ;hack for "cmp word [bp+nextEid], 0FFFFh"
                jnz     short .Replace30
                mov     ax, [bp+prevEid]
                ;mov     [es:bx+QcbType.tailOfQ], ax
                mov     [es:bx+02h], ax                         ;must be "mov [es:bx+QcbType.tailOfQ], ax"
                mov     ds, word [bp+prevEid]
                ;mov     word [ds:QElementType.next], 0FFFFh
                mov     word [ds:02h], 0FFFFh                   ;must be "mov word [ds:QElementType.next], 0FFFFh"
                jmp     short .ReplaceCont
; ---------------------------------------------------------------------------

.Replace30:                              ; CODE XREF: ReplaceOp+4A↑j
                mov     ds, word [bp+prevEid]
                mov     ax, word [bp+nextEid]
                ;mov     [ds:QElementType.next], ax
                mov     [ds:02h], ax                            ;must be "mov [ds:QElementType.next], ax"
                mov     ds, ax
                mov     ax, [bp+prevEid]
                ;mov     [ds:QElementType.prev], ax
                mov     [ds:04h], ax                            ;must be "mov [ds:QElementType.prev], ax"
                jmp     short .ReplaceCont
; ---------------------------------------------------------------------------

.ReplaceOther:                           ; CODE XREF: ReplaceOp+F↑j
                mov     ds, word [bp+newEid]
                mov     ax, [bp+prevEid]
                ;mov     [ds:QElementType.prev], ax
                mov     [ds:04h], ax                            ;must be "mov [ds:QElementType.prev], ax"
                mov     ax, [bp+nextEid]
                ;mov     [ds:QElementType.next], ax
                mov     [ds:02h], ax                            ;must be "mov [ds:QElementType.next], ax"
                mov     ax, [bp+newEid]
                ;cmp     word [bp+prevEid], 0FFFFh
                db      81h, 7Eh, 0Ah, 0FFh, 0FFh               ;hack for "cmp word [bp+prevEid], 0FFFFh"
                jz      short .Replace40
                mov     ds, word [bp+prevEid]
                ;mov     [ds:QElementType.next], ax
                mov     [ds:02h], ax                            ;must be "mov [ds:QElementType.next], ax"
                jmp     short .Replace50
; ---------------------------------------------------------------------------

.Replace40:                              ; CODE XREF: ReplaceOp+88↑j
                ;mov     [es:bx+QcbType.headOfQ], ax
                mov     [es:bx], ax                             ;must be "mov [es:bx+QcbType.headOfQ], ax"

.Replace50:                              ; CODE XREF: ReplaceOp+90↑j
                ;cmp     word [bp+nextEid], 0FFFFh
                db      81h, 7Eh, 06h, 0FFh, 0FFh               ;hack for "cmp word [bp+nextEid], 0FFFFh"
                jz      short .Replace60
                mov     ds, word [bp+nextEid]
                ;mov     [ds:QElementType.prev], ax
                mov     [ds:04h], ax                            ;must be "mov [ds:QElementType.prev], ax"
                jmp     short .ReplaceCont
; ---------------------------------------------------------------------------

.Replace60:                              ; CODE XREF: ReplaceOp+9A↑j
                ;mov     [es:bx+QcbType.tailOfQ], ax
                mov     [es:bx+02h], ax                         ;must be "mov [es:bx+QcbType.tailOfQ], ax"

.ReplaceCont:                            ; CODE XREF: ReplaceOp+2A↑j
                                        ; ReplaceOp+43↑j ...
                ;mov     al, [es:bx+QcbType.usesChecksum]
                mov     al, [es:bx+04h]                         ;must be "mov al, [es:bx+QcbType.usesChecksum]"
                rcr     al, 1
                jnb     short .ReplaceDone
                ;mov     ax, [es:bx+QcbType.elementLength]
                mov     ax, [es:bx+07h]                         ;must be "mov ax, [es:bx+QcbType.elementLength]"
                ;sub     ax, 2
                db      2Dh, 02h, 00h                           ;hack for "sub ax, 2"
                mov     [bp+len], ax
                ;cmp     word [bp+prevEid], 0FFFFh
                db      81h, 7Eh, 0Ah, 0FFh, 0FFh               ;hack for "cmp word [bp+prevEid], 0FFFFh"
                jz      short .Replace80
                push    [bp+prevEid]
                mov     ax, 2
                push    ax              ; pBuf
                push    [bp+len]        ; len
                call    SEG_MAIN:MakeChecksum
                mov     es, word [bp+prevEid]
                ;mov     [es:QElementType.checkSum], ax
                mov     [es:00h], ax                            ;must be "mov [es:QElementType.checkSum], ax"

.Replace80:                              ; CODE XREF: ReplaceOp+BF↑j
                ;cmp     word [bp+newEid], 0FFFFh
                db      81h, 7Eh, 08h, 0FFh, 0FFh               ;hack for "cmp word [bp+newEid], 0FFFFh"
                jz      short .Replace90
                push    [bp+newEid]
                mov     ax, 2
                push    ax              ; pBuf
                push    [bp+len]        ; len
                call    SEG_MAIN:MakeChecksum
                mov     es, word [bp+newEid]
                ;mov     [es:QElementType.checkSum], ax
                mov     [es:00h], ax                            ;must be "mov [es:QElementType.checkSum], ax"

.Replace90:                              ; CODE XREF: ReplaceOp+DC↑j
                ;cmp     word [bp+nextEid], 0FFFFh
                db      81h, 7Eh, 06h, 0FFh, 0FFh               ;hack for "cmp word [bp+nextEid], 0FFFFh"
                jz      short .ReplaceDone
                push    [bp+nextEid]
                mov     ax, 2
                push    ax              ; pBuf
                push    [bp+len]        ; len
                call    SEG_MAIN:MakeChecksum
                mov     es, word [bp+nextEid]
                ;mov     [es:QElementType.checkSum], ax
                mov     [es:00h], ax                            ;must be "mov [es:QElementType.checkSum], ax"

.ReplaceDone:                            ; CODE XREF: ReplaceOp+AE↑j
                                        ; ReplaceOp+F9↑j
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retn    0Ah
;ReplaceOp       endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsInsertIntoQ   proc far
OsInsertIntoQ:

newEid          equ     06h
curEid          equ     08h
pQcb            equ     0Ah

                push    bp
        {rmsrc} mov     bp, sp
                ;cmp     word [bp+curEid], 0FFFFh
                db      81h, 7Eh, 08h, 0FFh, 0FFh               ;hack for "cmp word [bp+curEid], 0FFFFh"
                jz      short .OsInsertNull
                mov     es, [bp+curEid]
                ;mov     dx, [es:QElementType.next]
                mov     dx, [es:02h]                            ;must be "mov dx, [es:QElementType.next]"
                jmp     short .OsInsertCont
; ---------------------------------------------------------------------------

.OsInsertNull:                           ; CODE XREF: OsInsertIntoQ+8↑j
                les     bx, [bp+pQcb]
                ;mov     dx, [es:bx+QcbType.headOfQ]
                mov     dx, [es:bx]                             ;must be "mov dx, [es:bx+QcbType.headOfQ]"

.OsInsertCont:                           ; CODE XREF: OsInsertIntoQ+12↑j
                les     ax, [bp+pQcb]
                push    es
                push    ax
                push    [bp+curEid]
                push    [bp+newEid]
                push    dx
                call    ReplaceOp
                les     bx, [bp+pQcb]
                ;inc     word [es:bx+QcbType.qcbCount]
                inc     word [es:bx+05h]                           ;must be "inc word [es:bx+QcbType.qcbCount]"
        {rmsrc} mov     sp, bp
                pop     bp
                retf    8
;OsInsertIntoQ   endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsRemoveFromQ   proc far
OsRemoveFromQ:

curEid          equ     06h
pQcb            equ     08h

                push    bp
        {rmsrc} mov     bp, sp
                les     ax, [bp+pQcb]
                push    es
                push    ax
                mov     es, word [bp+curEid]
                ;push    word [es:QElementType.prev]
                push    word [es:04h]                           ;must be "push word [es:QElementType.prev]"
                mov     ax, 0FFFFh
                push    ax
                ;push    word [es:QElementType.next]
                push    word [es:02h]                           ;must be "push word [es:QElementType.next]"
                call    ReplaceOp
                les     bx, [bp+pQcb]
                ;dec     word [es:bx+QcbType.qcbCount]
                dec     word [es:bx+05h]                        ;must be "dec word [es:bx+QcbType.qcbCount]"
                mov     es, [bp+curEid]
                ;dec     word [es:QElementType.checkSum]
                dec     word [es:00h]                           ;must be "dec word [es:QElementType.checkSum]"
        {rmsrc} mov     sp, bp
                pop     bp
                retf    6
;OsRemoveFromQ   endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsReplaceInQ    proc far
OsReplaceInQ:

newEid          equ     06h
oldEid          equ     08h
pQcb            equ     0Ah

                push    bp
        {rmsrc} mov     bp, sp
                les     ax, [bp+pQcb]
                push    es
                push    ax
                mov     es, word [bp+oldEid]
                ;push    word [es:QElementType.prev]
                push    word [es:04h]                           ;must be "push word [es:QElementType.prev]"
                push    [bp+newEid]
                ;push    word [es:QElementType.next]
                push    word [es:02h]                           ;must be "push word [es:QElementType.next]"
                call    ReplaceOp
        {rmsrc} mov     sp, bp
                pop     bp
                retf    8
;OsReplaceInQ    endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsElementInQ    proc far
OsElementInQ:

eid             equ     06h
pQcb            equ     08h

                push    bp
        {rmsrc} mov     bp, sp
                les     bx, [bp+pQcb]
                ;mov     es, word [es:bx+QcbType.headOfQ]
                mov     es, word [es:bx]
                mov     dx, 0FFFFh

.OsElementTopOfLoop:                     ; CODE XREF: OsElementInQ+37↓j
                mov     ax, es
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;hack for "cmp ax, 0FFFFh"
                jz      short .OsElementFalse
                ;cmp     [es:QElementType.prev], dx
                cmp     [es:04h], dx                            ;hack for "cmp [es:QElementType.prev], dx"
                jz      short .OsElementCont
                mov     ax, 2
                push    ax
                mov     ax, 1Fh
                push    ax
                call    SEG_MAIN:Exception

.OsElementCont:                          ; CODE XREF: OsElementInQ+18↑j
                mov     al, 0FFh
                mov     bx, es
                cmp     bx, [bp+eid]
                jz      short .OsElementDone
                mov     dx, es
                ;mov     es, word [es:QElementType.next]
                mov     es, word [es:02h]                       ;hack for "mov es, word [es:QElementType.next]"
                jmp     short .OsElementTopOfLoop
; ---------------------------------------------------------------------------

.OsElementFalse:                         ; CODE XREF: OsElementInQ+11↑j
                mov     al, 0

.OsElementDone:                          ; CODE XREF: OsElementInQ+2E↑j
        {rmsrc} mov     sp, bp
                pop     bp
                retf    6
;OsElementInQ    endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;OsSearchInQ     proc far
OsSearchInQ:

MODE            equ     06h
len             equ     08h
pKey            equ     0Ah
offst           equ     0Eh
pQcb            equ     10h

                push    bp
        {rmsrc} mov     bp, sp
                les     bx, [bp+pQcb]
                ;mov     es, word [es:bx+QcbType.headOfQ]
                mov     es, word [es:bx]                        ;must be "mov es, word [es:bx+QcbType.headOfQ]"
                mov     dx, 0FFFFh

.OsSearchTopOfLoop:                      ; CODE XREF: OsSearchInQ+61↓j
                mov     ax, es
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;must be "cmp ax, 0FFFFh"
                jz      short .OsSearchDone
                cmp     [es:4], dx
                jz      short .OsSearchCont
                mov     ax, 2
                push    ax
                mov     ax, 1Fh
                push    ax
                call    SEG_MAIN:Exception

.OsSearchCont:                           ; CODE XREF: OsSearchInQ+18↑j
                push    es
                push    dx
                cmp     byte [bp+MODE], 0
                jnz     short .OsSearchCase
                push    es
                push    [bp+offst]
                les     ax, [bp+pKey]
                push    es
                push    ax
                push    [bp+len]
                call    SEG_UNKOWN:CompareChars
                rcr     al, 1
                jnb     short .OsSearchBottomOfLoop
                jmp     short .OsSearchTrue
; ---------------------------------------------------------------------------

.OsSearchCase:                           ; CODE XREF: OsSearchInQ+2D↑j
                mov     di, [bp+offst]
                push    ds
                lds     si, [bp+pKey]
                mov     cx, [bp+len]
                cld
                repe cmpsb
                pop     ds
                jnz     short .OsSearchBottomOfLoop
                jmp     short .OsSearchTrue
; ---------------------------------------------------------------------------

.OsSearchBottomOfLoop:                   ; CODE XREF: OsSearchInQ+42↑j
                                        ; OsSearchInQ+54↑j
                pop     dx
                pop     es
                mov     dx, es
                mov     es, word [es:2]
                jmp     short .OsSearchTopOfLoop
; ---------------------------------------------------------------------------

.OsSearchTrue:                           ; CODE XREF: OsSearchInQ+44↑j
                                        ; OsSearchInQ+56↑j
                pop     dx
                pop     ax

.OsSearchDone:                           ; CODE XREF: OsSearchInQ+11↑j
        {rmsrc} mov     sp, bp
                pop     bp
                retf    0Eh
;OsSearchInQ     endp ; sp-analysis failed


end match
