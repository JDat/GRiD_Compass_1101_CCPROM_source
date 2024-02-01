match FALSE, _LQ_DWORD_MUL_asm
display 'Including LQ_DWORD_MUL segment', 10

_LQ_DWORD_MUL_asm equ TRUE


; =============== S U B R O U T I N E =======================================
org 00h
;LQ_DWORD_MUL    proc far                ; CODE XREF: CpGetMemStatus+70↑P
LQ_DWORD_MUL:
        {rmsrc} mov     bx, ax
        {rmsrc} mov     ax, dx
                mul     cx
        {rmsrc} mov     si, ax
        {rmsrc} mov     ax, di
                mul     bx
        {rmsrc} add     si, ax
        {rmsrc} mov     ax, cx
                mul     bx
        {rmsrc} add     dx, si
                retf
;LQ_DWORD_MUL    endp
  


end match
