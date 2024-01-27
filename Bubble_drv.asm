match FALSE, _Bubble_drv_asm
display 'Including Bubble Driver segment', 10

_Bubble_drv_asm equ TRUE


;segment SEG_BUBBLE
org 5
                        db 00h
bubbleDrv_Weird_Seg:    dw SEG_BUBBLE_WEIRD

; =============== S U B R O U T I N E =======================================
;bubbleDrvService proc far               ; CODE XREF: j_BubbleDriver↓J
                                        ; DATA XREF: OsBoot:offBubbleCommand↓o
bubbleDrvService:
                push    ds

.loc_FE3C9:
                mov     ds, [cs:bubbleDrv_Weird_Seg]
                ;assume ds:nothing

;loc_FE3CE:
                pop     bx

;loc_FE3CF:
                pop     cx

;loc_FE3D0:
                pop     dx
                pop     word [ds:39C4h]
                pop     word [ds:39C6h]
                pop     word [ds:39C8h]

.loc_FE3DD:
                pop     word [ds:39CAh]

.loc_FE3E1:
                pop     word [ds:39CCh]
                push    dx
                push    cx
                push    bx
                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, 0
                mov     [ds:39CEh], ax

.loc_FE3F1:
                les     bx, [ds:39C4h]
                mov     [es:bx], ax
                mov     [ds:39D0h], ax
                mov     ax, [ds:39CCh]

.loc_FE3FE:                              ; switch 6 cases
                cmp     ax, ddWrite

.loc_FE401:                              ; jumptable 000FE407 default case
                ja      short .bubbleDrvNotSupported

.loc_FE403:
                mov     bx, ax
                shl     bx, 1
                ;jmp     word [cs:bx+.jpt_FE407] ; switch jump
                db      2Eh, 0FFh, 0A7h, 4Ch, 00h               ;hack for "jmp word [cs:bx+.jpt_FE407] ;switch jump"
; ---------------------------------------------------------------------------
.jpt_FE407      dw .l_bubbleDrvInit
                                        ; DATA XREF: bubbleDrvService+3F↑r
                dw .l_bubbleDrvGetStatus ; jump table for switch statement
                dw .l_bubbleDrvOpenClose_Skip
                dw .l_bubbleDrvOpenClose_Skip
                dw .l_bubbleDrvReadWrite
                dw .l_bubbleDrvReadWrite
; ---------------------------------------------------------------------------

.l_bubbleDrvInit:                        ; CODE XREF: bubbleDrvService+3F↑j
                                        ; DATA XREF: bubbleDrvService:jpt_FE407↑o
                call    bubbleDrvInit  ; jumptable 000FE407 case 0
                jmp     short .l_caseCommand
; ---------------------------------------------------------------------------

.l_bubbleDrvGetStatus:                   ; CODE XREF: bubbleDrvService+3F↑j
                                        ; DATA XREF: bubbleDrvService:jpt_FE407↑o
                call    bubbleDrvGetStatus ; jumptable 000FE407 case 1

.loc_FE420:
                jmp     short .l_caseCommand
; ---------------------------------------------------------------------------

.l_bubbleDrvReadWrite:                   ; CODE XREF: bubbleDrvService+3F↑j
                                        ; DATA XREF: bubbleDrvService:jpt_FE407↑o
                call    bubbleDrvReadWrite ; jumptable 000FE407 cases 4,5
                jmp     short .l_caseCommand
; ---------------------------------------------------------------------------

.bubbleDrvNotSupported:                  ; CODE XREF: bubbleDrvService:loc_FE401↑j
                cmp     word [ds:39CCh], 11h ; jumptable 000FE407 default case
                jz      short .l_caseCommand

.l_bubbleDrvOpenClose_Skip:              ; CODE XREF: bubbleDrvService+3F↑j
                                        ; DATA XREF: bubbleDrvService:jpt_FE407↑o
                les     bx, [ds:39C4h]    ; jumptable 000FE407 cases 2,3
                mov     word [es:bx], 23h ; '#'

.l_caseCommand:                          ; CODE XREF: bubbleDrvService+53↑j
                                        ; bubbleDrvService:loc_FE420↑j ...
                les     bx, [ds:39C4h]
                cmp     word [es:bx], 0
                jnz     short .loc_FE447
                mov     ax, [ds:39CEh]
                mov     [es:bx], ax

.loc_FE447:                              ; CODE XREF: bubbleDrvService+77↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
;bubbleDrvService endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================
;bubbleExec7220CmdWait proc near        ; CODE XREF: bubbleDrvInit?+53↓p
                                        ; bubbleDrvInit?+7B↓p ...
bubbleExec7220CmdWait:

                push    bp
        {rmsrc} mov     bp, sp
                mov     word [ds:39CEh], 6Bh ; 'k'
                mov     word [ds:39E0h], 0FFFFh

.loc_FE459:                              ; CODE XREF: bubbleExec7220CmdWait?+54↓j
                                        ; bubbleExec7220CmdWait?+5A↓j
                cmp     word [ds:39E0h], 0
                jz      short .loc_FE4A6
                les     bx, dword [ds:67h]
                mov     al, [es:bx]
                test    al, 80h
                jnz     short .loc_FE4A0
                test    al, 40h
                jnz     short .loc_FE477
                mov     word [ds:39CEh], 67h ; 'g'
                jmp     short .loc_FE47D
; ---------------------------------------------------------------------------

.loc_FE477:                              ; CODE XREF: bubbleExec7220CmdWait?+23↑j
                mov     word [ds:39CEh], 0

.loc_FE47D:                              ; CODE XREF: bubbleExec7220CmdWait?+2B↑j
                les     bx, dword [ds:67h]
                mov     al, [es:bx]
                mov     [ds:39ECh], al
                mov     cl, 48h ; 'H'
        {rmsrc} and     al, cl
                mov     [ds:39ECh], al
        {rmsrc} cmp     al, cl
                jnz     short .loc_FE498
                mov     word [ds:39CEh], 6Ch ; 'l'

.loc_FE498:                              ; CODE XREF: bubbleExec7220CmdWait?+46↑j
                mov     word [ds:39E0h], 0
                jmp     short .loc_FE459
; ---------------------------------------------------------------------------

.loc_FE4A0:                              ; CODE XREF: bubbleExec7220CmdWait?+1F↑j
                dec     word [ds:39E0h]
                jmp     short .loc_FE459
; ---------------------------------------------------------------------------

.loc_FE4A6:                              ; CODE XREF: bubbleExec7220CmdWait?+14↑j
                pop     bp
                retn
;bubbleExec7220CmdWait? endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;sub_FE4A8       proc near               ; CODE XREF: bubbleDrvInit?+69↓p
                                        ; bubbleDrvReadWrite?+34↓p ...
sub_FE4A8:
                push    bp
        {rmsrc} mov     bp, sp
                les     bx, [ds:39C8h]
                ;cmp     byte [es:bx+0Dh], 0
                db      26h, 82h, 7Fh, 0Dh, 00h                 ;hack for "cmp byte [es:bx+0Dh], 0"
                jz      short .loc_FE4B9
                jmp     .loc_FE53E
; ---------------------------------------------------------------------------

.loc_FE4B9:                              ; CODE XREF: sub_FE4A8+C↑j
                mov     ax, [es:bx+6]
                mov     dx, [es:bx+8]
                mov     cx, 600h
        {rmsrc} cmp     ax, cx
                jnb     short .loc_FE536
                mov     si, [es:bx+6]
                push    ax
                shl     ax, 1
                shl     ax, 1
                mov     [ds:39E9h], ax
                mov     ax, [es:bx+0Ah]
                mov     di, 100h
                push    dx
                xor     dx, dx
                div     di
                pop     cx
                pop     dx
        {rmsrc} add     ax, dx
                mov     dx, 600h
        {rmsrc} cmp     ax, dx
                jbe     short .loc_FE4F7
                push    si
        {rmsrc} sub     dx, si
                mov     ax, dx
                mul     di
                mov     [es:bx+0Ah], ax
                pop     cx

.loc_FE4F7:                              ; CODE XREF: sub_FE4A8+41↑j
                les     bx, [ds:39C8h]
                mov     ax, [es:bx+0Ah]
                mov     cx, 40h ; '@'
                xor     dx, dx
                div     cx
                add     ax, 1000h
                mov     [ds:39E7h], ax
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 0Bh
                mov     al, [ds:39E7h]
                les     bx, dword [ds:5Fh]
                mov     [es:bx], al
                mov     al, [ds:39E8h]
                mov     [es:bx], al
                mov     byte [es:bx], 28h ; '('
                mov     al, [ds:39E9h]
                mov     [es:bx], al
                mov     al, [ds:39EAh]
                mov     [es:bx], al
                pop     bp
                retn
; ---------------------------------------------------------------------------

.loc_FE536:                              ; CODE XREF: sub_FE4A8+1E↑j
                mov     word [ds:39CEh], 66h ; 'f'
                pop     bp
                retn
; ---------------------------------------------------------------------------

.loc_FE53E:                              ; CODE XREF: sub_FE4A8+E↑j
                mov     word [ds:39CEh], 65h ; 'e'
                pop     bp
                retn
;sub_FE4A8       endp

; =============== S U B R O U T I N E =======================================
;bubbleDrvInit  proc near               ; CODE XREF: bubbleDrvService:l_bubbleDrvInit↑p
bubbleDrvInit:
                push    bp
        {rmsrc} mov     bp, sp
                mov     al, 0Ah
                les     bx, dword [ds:63h]
                mov     [es:bx], al
                les     si, dword [ds:5Fh]
                mov     byte [es:si], 5Ah ; 'Z'
                les     bx, dword [ds:63h]
                mov     [es:bx], al
                mov     dx, SEG_MAIN
                mov     ax, OnIrq5_bubble
                les     bx, dword [ds:5Bh]
                mov     [es:bx+84h], ax
                mov     [es:bx+86h], dx
                mov     al, 0
                les     di, [ds:39C8h]
                mov     cx, 13h
                cld
                repne stosb
                les     bx, [ds:39C8h]
                mov     word [es:bx+6], 5FFh
                mov     word [es:bx+8], 0
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 19h
                call    bubbleExec7220CmdWait
                mov     ax, 150
                mov     [ds:39DEh], ax
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                cmp     word [ds:39CEh], 0
                jnz     short .loc_FE625
                call    sub_FE4A8
                cmp     word [ds:39CEh], 0
                jnz     short .loc_FE625
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 11h
                call    bubbleExec7220CmdWait
                cmp     word [ds:39CEh], 0
                jnz     short .loc_FE625
                mov     al, [ds:39E6h]
                rcr     al, 1
                jb      short .loc_FE625
                mov     byte [ds:39E6h], 0FFh
                les     ax, dword [ds:53h]
                push    es
                call    SEG_MAIN:CpCreateSemaphore
                les     ax, dword [ds:53h]
                mov     word [ds:39D2h], es
                push    word [ds:39D2h] ; sid
                mov     ax, 1
                push    ax              ; mode
                push    word [ds:39DAh] ; note
                les     ax, [ds:39C4h]
                push    es
                push    ax              ; pError
                call    SEG_MAIN:CpSignal
                les     bx, [ds:39C4h]
                cmp     word [es:bx], 0
                jnz     short .loc_FE625
                les     ax, dword [ds:57h]
                push    es
                call    SEG_MAIN:CpCreateSemaphore
                les     ax, dword [ds:57h]
                mov     word [ds:39D4h], es
                mov     ax, 0
                mov     [ds:39C0h], ax
                mov     [ds:39C2h], ax

.loc_FE625:                              ; CODE XREF: bubbleDrvInit?+67↑j
                                        ; bubbleDrvInit?+71↑j ...
                pop     bp
                retn
;bubbleDrvInit?  endp

; =============== S U B R O U T I N E =======================================
;bubbleDrvReadWrite? proc near           ; CODE XREF: bubbleDrvService:l_bubbleDrvReadWrite↑p
bubbleDrvReadWrite:
                push    bp
        {rmsrc} mov     bp, sp
                push    word [ds:39D2h] ; sid
                mov     ax, 0FFFFh
                push    ax              ; timeLimit
                les     ax, [ds:39C4h]
                push    es
                push    ax              ; pError
                call    SEG_MAIN:CpWait
                mov     [ds:39D6h], ax
                les     bx, [ds:39C4h]
                cmp     word [es:bx], 0
                jnz     short .loc_FE675
                mov     word [ds:39E2h], 0Ah
                les     bx, [ds:39C8h]
                mov     ax, [es:bx+0Ah]

.loc_FE658:
                mov     [ds:39DCh], ax
                call    sub_FE4A8
                cmp     word [ds:39CEh], 0
                jnz     short .loc_FE675
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 1Dh ; Bubble CMD: Reset FIFO
                call    bubbleExec7220CmdWait
                cmp     word [ds:39CEh], 0

.loc_FE675:                              ; CODE XREF: bubbleDrvReadWrite?+21↑j
                                        ; bubbleDrvReadWrite?+3C↑j
                jz      short .loc_FE67A
                jmp     .loc_FE799
; ---------------------------------------------------------------------------

.loc_FE67A:                              ; CODE XREF: bubbleDrvReadWrite?:loc_FE675↑j
                                        ; bubbleDrvReadWrite?:loc_FE6F6↓j ...
                cmp     word [ds:39E2h], 0
                jnz     short .loc_FE684
                jmp     .loc_FE799
; ---------------------------------------------------------------------------

.loc_FE684:                              ; CODE XREF: bubbleDrvReadWrite?+58↑j
                mov     word [ds:39CEh], 0
                push    word [ds:39CCh]
                les     bx, [ds:39C8h]
                les     ax, [es:bx+2]
                push    es
                push    ax
                les     bx, [ds:39C8h]
                push    word [es:bx+0Ah]
                push    word [ds:39D4h]
                les     ax, [ds:39C4h]
                push    es
                push    ax
                call    SEG_MAIN:BCM_related_stuff
                mov     [ds:39E4h], ax

.loc_FE6B2:
                call    bubbleExec7220CmdWait
                mov     ax, [ds:39CEh]
                or      ax, ax
                jnz     short .loc_FE6BF
                jmp     .loc_FE78D
; ---------------------------------------------------------------------------

.loc_FE6BF:                              ; CODE XREF: bubbleDrvReadWrite?+93↑j
                dec     word [ds:39E2h]
                mov     [ds:39D0h], ax
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 19h ; Bubble CMD: Abort
                call    bubbleExec7220CmdWait
                mov     ax, 150
                mov     [ds:39DEh], ax
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 1Fh ; Bubble CMD: Software reset
                call    bubbleExec7220CmdWait
                call    sub_FE4A8
                mov     ax, [ds:39D0h]
                mov     [ds:39CEh], ax
                cmp     word [ds:39E2h], 7

.loc_FE6F6:                              ; CODE XREF: bubbleDrvReadWrite?+D4↓j
                jnz     short .loc_FE67A
                cmp     ax, 6Ch ; 'l'
                jnz     short .loc_FE6F6

.loc_FE6FD:                              ; CODE XREF: bubbleDrvReadWrite?:loc_FE77A↓j
                cmp     word [ds:39E2h], 0
                jnz     short .loc_FE707
                jmp     .loc_FE67A
; ---------------------------------------------------------------------------

.loc_FE707:                              ; CODE XREF: bubbleDrvReadWrite?+DB↑j
                mov     word [ds:39CEh], 0
                mov     ax, 5
                mov     [ds:39CCh], ax
                push    ax
                les     bx, [ds:39C8h]
                les     ax, [es:bx+2]
                push    es
                push    ax
                les     bx, [ds:39C8h]
                push    word [es:bx+0Ah]
                push    word [ds:39D4h]
                les     ax, [ds:39C4h]
                push    es
                push    ax
                call    SEG_MAIN:BCM_related_stuff
                mov     [ds:39E4h], ax
                call    bubbleExec7220CmdWait
                mov     ax, [ds:39CEh]
                or      ax, ax
                jz      short .loc_FE77C
                mov     [ds:39D0h], ax
                dec     word [ds:39E2h]
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 19h
                call    bubbleExec7220CmdWait
                mov     ax, 96h
                mov     [ds:39DEh], ax
                push    ax              ; timeLimit
                call    SEG_MAIN:CpDelay         ; Milliseconds
                les     bx, dword [ds:63h]
                mov     byte [es:bx], 1Fh
                call    bubbleExec7220CmdWait
                call    sub_FE4A8
                mov     ax, [ds:39D0h]
                mov     [ds:39CEh], ax
                mov     word [ds:39CCh], 4

.loc_FE77A:                              ; CODE XREF: bubbleDrvReadWrite?+164↓j
                jmp     short .loc_FE6FD
; ---------------------------------------------------------------------------

.loc_FE77C:                              ; CODE XREF: bubbleDrvReadWrite?+119↑j
                mov     word [ds:39CCh], 4
                mov     ax, 0
                mov     [ds:39CEh], ax
                mov     [ds:39E2h], ax
                jmp     short .loc_FE77A
; ---------------------------------------------------------------------------

.loc_FE78D:                              ; CODE XREF: bubbleDrvReadWrite?+95↑j
                mov     ax, 0
                mov     [ds:39E2h], ax
                mov     [ds:39CEh], ax
                jmp     .loc_FE67A
; ---------------------------------------------------------------------------

.loc_FE799:                              ; CODE XREF: bubbleDrvReadWrite?+50↑j
                                        ; bubbleDrvReadWrite?+5A↑j
                mov     ax, [ds:39E4h]
                les     bx, [ds:39C8h]
                mov     [es:bx+0Ah], ax
                push    word [ds:39D2h] ; sid
                mov     ax, 1
                push    ax              ; mode
                push    word [ds:39D6h] ; note
                les     ax, [ds:39C4h]
                push    es
                push    ax              ; pError
                call    SEG_MAIN:CpSignal
                pop     bp
                retn
;bubbleDrvReadWrite endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================
;bubbleDrvGetStatus? proc near           ; CODE XREF: bubbleDrvService:l_bubbleDrvGetStatus↑p
bubbleDrvGetStatus:
                push    bp
        {rmsrc} mov     bp, sp
                mov     al, [ds:39E6h]
                rcr     al, 1
                jnb     short .loc_FE7DB
                les     bx, [ds:39C8h]
                mov     cx, [es:bx+0Ah]
                les     di, [es:bx+2]
        {rmsrc} mov     si, 0Ch
                cld
                repne movsb
                pop     bp
                retn
; ---------------------------------------------------------------------------

.loc_FE7DB:                              ; CODE XREF: bubbleDrvGetStatus?+8↑j
                les     bx, [ds:39C4h]

.loc_FE7DF:
                mov     word [es:bx], 6Bh ; 'k'
                pop     bp
                retn
;bubbleDrvGetStatus endp
  

end match
