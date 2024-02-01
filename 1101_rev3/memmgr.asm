match FALSE, _cp_mem_mgr_asm
display 'Including memory management routines', 10

_cp_mem_mgr_asm equ TRUE

; these routines are based on original source
; from file CCPROM/MEMMGR.ASM

; =============== S U B R O U T I N E =======================================
;AtOsFreeMemQ    proc near
AtOsFreeMemQ:
                pop     di
                push    [cs:DataFrame_0]
                mov     ax, OsFreeMemQ
                push    ax
                jmp     di
;AtOsFreeMemQ    endp

; =============== S U B R O U T I N E =======================================
;AtOsAllocMemQ   proc near
AtOsAllocMemQ:
                pop     di
                push    [cs:DataFrame_0]
                mov     ax, OsAllocMemQ
                push    ax
                jmp     di
;AtOsAllocMemQ   endp

; Attributes: bp-based frame

;CheckCheckSum   proc near
CheckCheckSum:

scbSeg          equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                call    AtOsFreeMemQ
                push    [bp+scbSeg]
                call    SEG_MAIN:OsVerifyChecksum
                rcr     al, 1
                jb      short .CheckDone
                push    [bp+scbSeg]
                call    MemoryCheckSum

.CheckDone:                              ; CODE XREF: CheckCheckSum+10↑j
        {rmsrc} mov     sp, bp
                pop     bp
                retn    2
;CheckCheckSum   endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall AddToFreeChain(int scbSeg)
;AddToFreeChain  proc near
AddToFreeChain:

curScbSeg       equ     -4
tempSeg         equ     -2
scbSeg          equ     06h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 4
                mov     ds, [cs:DataFrame_0]
                ;assume ds:CCPROM_RAM
                ;mov     ax, [OsFreeMemQ.headOfQ]
                mov     ax, [OsFreeMemQ]                    ;must be "mov     ax, [OsFreeMemQ.headOfQ]"
                mov     [bp+curScbSeg], ax
                mov     ds, [bp+scbSeg]
                ;assume ds:nothing
                mov     word ptr ds:0Ah, 0FFFFh
                mov     word [bp+tempSeg], 0FFFFh

.AddToTopOfLoop:                         ; CODE XREF: AddToFreeChain+D0↓j
                ;cmp     word [bp+curScbSeg], 0FFFFh
                db      81h, 07Eh, 0FCh, 0FFh, 0FFh         ;hack for "cmp word [bp+curScbSeg], 0FFFFh"
                jnz     short .AddTo01
                jmp     .AddToLoopExit
; ---------------------------------------------------------------------------

.AddTo01:                                ; CODE XREF: AddToFreeChain+25↑j
                push    [bp+curScbSeg]
                call    CheckCheckSum
                mov     ax, [bp+curScbSeg]
                mov     es, ax
                add     ax, [es:6]
                inc     ax
                cmp     ax, [bp+scbSeg]
                jnz     short .AddToSecondTest
                mov     ds, [bp+scbSeg]
                mov     ax, [ds:6]
                inc     ax
                add     [es:6], ax
                mov     ax, es
                add     ax, [es:6]
                inc     ax
                cmp     ax, [es:2]
                jnz     short .AddTo20
                mov     ds, word [es:2]
                mov     ax, [ds:6]
                inc     ax
                add     [es:6], ax
                call    AtOsFreeMemQ
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                jmp     short .AddToReturn
; ---------------------------------------------------------------------------

.AddTo20:                                ; CODE XREF: AddToFreeChain+59↑j
                call    AtOsFreeMemQ
                push    es
                call    SEG_MAIN:OsElementChecksum
                mov     es, [bp+curScbSeg]
                mov     [es:0], ax
                jmp     short .AddToReturn
; ---------------------------------------------------------------------------

.AddToSecondTest:                        ; CODE XREF: AddToFreeChain+3E↑j
                mov     ds, word [bp+scbSeg]
                mov     ax, ds
                add     ax, [ds:6]
                inc     ax
                cmp     ax, [bp+curScbSeg]
                jnz     short .AddToThirdTest
                mov     es, [bp+curScbSeg]
                mov     ax, [es:6]
                inc     ax
                add     [ds:6], ax
                call    AtOsFreeMemQ
                push    [bp+curScbSeg]
                call    SEG_MAIN:OsRemoveFromQ
                call    AtOsFreeMemQ
                push    [bp+tempSeg]
                push    [bp+scbSeg]
                call    SEG_MAIN:OsInsertIntoQ
                jmp     short .AddToReturn
; ---------------------------------------------------------------------------

.AddToThirdTest:                         ; CODE XREF: AddToFreeChain+93↑j
                mov     ax, [bp+curScbSeg]
                cmp     ax, [bp+scbSeg]
                ja      short .AddToLoopExit
                mov     [bp+tempSeg], ax
                mov     es, ax
                mov     ax, [es:2]
                mov     [bp+curScbSeg], ax
                jmp     .AddToTopOfLoop
; ---------------------------------------------------------------------------

.AddToLoopExit:                          ; CODE XREF: AddToFreeChain+27↑j
                                        ; AddToFreeChain+C2↑j
                call    AtOsFreeMemQ
                push    [bp+tempSeg]
                push    [bp+scbSeg]
                call    SEG_MAIN:OsInsertIntoQ

.AddToReturn:                            ; CODE XREF: AddToFreeChain+72↑j
                                        ; AddToFreeChain+84↑j ...
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retn    2
;AddToFreeChain  endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall Allocated(int scbSeg)
;Allocated       proc near
Allocated:

scbSeg          equ     04h

                push    bp
        {rmsrc} mov     bp, sp
                call    AtOsAllocMemQ
                push    [bp+scbSeg]

.loc_FCF09:
                call    SEG_MAIN:OsElementInQ
                pop     bp
                retn    2
;Allocated       endp

; =============== S U B R O U T I N E =======================================


;EnterMemMgr     proc near
EnterMemMgr:

                mov     ax, 2C4h
                push    ax              ; sid
                mov     ax, 0FFFFh
                push    ax              ; timeLimit
                push    [cs:DataFrame_0]
                mov     ax, dummyError_0
                push    ax              ; pError
                call    SEG_MAIN:CpWait
                retn
;EnterMemMgr     endp


; =============== S U B R O U T I N E =======================================


;LeaveMemMgr     proc near
LeaveMemMgr:

                mov     ax, 2C4h
                push    ax              ; sid
                mov     ax, 1
                push    ax              ; mode
                push    ax              ; note
                push    [cs:DataFrame_0]
                mov     ax, 182h
                push    ax              ; pError
                call    SEG_MAIN:CpSignal
                retn
;LeaveMemMgr     endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpFree(__int32 pError, int, int pBlockSeg)
;CpFree          proc far
CpFree:

pError          equ     08h
pBlockSeg       equ     0Eh

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    EnterMemMgr
                mov     ax, [bp+pBlockSeg]
                dec     ax
                mov     ds, ax
                push    ds              ; scbSeg
                call    Allocated
                rcr     al, 1
                jnb     short .OsFree10
                les     bx, [bp+pError]
                mov     word [es:bx], 0
                call    AtOsAllocMemQ
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                push    ds              ; scbSeg
                call    AddToFreeChain
                jmp     short .OsFreeDone
; ---------------------------------------------------------------------------

.OsFree10:                               ; CODE XREF: CpFree+13↑j
                les     bx, [bp+pError]
                mov     word [es:bx], 0Bh

.OsFreeDone:                             ; CODE XREF: CpFree+2A↑j
                call    LeaveMemMgr
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retf    8
;CpFree          endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpGetSize(__int32 pError, int, int pBlock)
;CpGetSize       proc far
CpGetSize:

pError          equ     08h
pBlock          equ     0Eh

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    EnterMemMgr
                mov     ax, [bp+pBlock]
                dec     ax
                mov     ds, ax
                push    ds              ; scbSeg
                call    Allocated
                rcr     al, 1
                jnb     short .OsGsNotAllocated
                les     bx, [bp+pError]
                mov     word [es:bx], 0
                mov     ax, [ds:6]
                dec     ax
                mov     cl, 4
                shl     ax, cl
                add     ax, [ds:8]
                cmp     word [ds:8], 0
                jnz     short .OsGsDone
                ;add     ax, 10h
                db      05h, 10h, 00h                           ;hack for "add ax, 10h"
                jmp     short .OsGsDone
; ---------------------------------------------------------------------------

.OsGsNotAllocated:                       ; CODE XREF: CpGetSize+13↑j
                les     bx, [bp+0Ch]
                mov     word [es:bx], 0Bh
        {rmsrc} xor     ax, ax

.OsGsDone:                               ; CODE XREF: CpGetSize+2E↑j
                                        ; CpGetSize+33↑j
                push    ax
                call    LeaveMemMgr
                pop     ax
       {rmsrc}  mov     sp, bp
                pop     bp
                pop     ds
                retf    8
;CpGetSize       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;IntAllocate     proc far
IntAllocate:

remainder       equ     -4
numBlkReq       equ     -2
pError          equ     08h
siz             equ     0Ch
pid             equ     0Eh

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 4
                call    EnterMemMgr
                mov     es, [cs:DataFrame_0]
                ;assume es:CCPROM_RAM
                mov     bx, 170h
                mov     ds, word [es:bx+2]
                mov     ax, [bp+siz]
                dec     ax
                mov     cl, 4
                shr     ax, cl
                inc     ax
                mov     [bp+numBlkReq], ax
                mov     ax, [bp+siz]
                ;and     ax, 0Fh
                db      25h, 0Fh, 00h                  ;hack for "and ax, 0Fh"
                mov     [bp+remainder], ax

.loc_FCFF5:                              ; CODE XREF: IntAllocate+B4↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3dh, 0FFh, 0FFh                 ; hacl for "cmp ax, 0FFFFh"
                jnz     short .loc_FCFFF
                jmp     .loc_FD081
; ---------------------------------------------------------------------------

.loc_FCFFF:                              ; CODE XREF: IntAllocate+30↑j
                push    ds
                call    CheckCheckSum
                mov     ax, [ds:6]
                cmp     ax, [bp+numBlkReq]
                jnb     short .loc_FD00E
                jmp     short .loc_FD07A
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.loc_FD00E:                              ; CODE XREF: IntAllocate+3F↑j
                dec     ax
                cmp     ax, [bp+numBlkReq]
                ja      short .loc_FD01F
                call    AtOsFreeMemQ
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                jmp     short .loc_FD04A
; ---------------------------------------------------------------------------

.loc_FD01F:                              ; CODE XREF: IntAllocate+48↑j
                mov     ax, ds
                add     ax, [ds:6]
                sub     ax, [bp+numBlkReq]
                push    ax
                mov     ax, [bp+numBlkReq]
                inc     ax
                sub     [ds:6], ax
                call    AtOsFreeMemQ
                push    ds
                call    SEG_MAIN:OsElementChecksum
                mov     [ds:0], ax
                pop     ds
                mov     ax, [bp+numBlkReq]
                mov     [ds:6], ax
                mov     ax, [bp+remainder]
                mov     [ds:8], ax

.loc_FD04A:                              ; CODE XREF: IntAllocate+53↑j
                mov     ax, [bp+pid]
                mov     [ds:0Ah], ax
                call    AtOsAllocMemQ
                push    ds
                call    SEG_MAIN:OsElementChecksum
                mov     [ds:0], ax
                call    AtOsAllocMemQ
                mov     ax, 0FFFFh
                push    ax
                push    ds
                call    SEG_MAIN:OsInsertIntoQ
                les     bx, [bp+pError]
                ;assume es:nothing
                mov     word [es:bx], 0
                mov     ax, ds
                inc     ax
                mov     es, ax
                ;assume es:nothing
        {rmsrc} xor     bx, bx
                jmp     short .loc_FD090
; ---------------------------------------------------------------------------

.loc_FD07A:                              ; CODE XREF: IntAllocate+41↑j
                mov     ds, word [ds:4]
                jmp     .loc_FCFF5
; ---------------------------------------------------------------------------

.loc_FD081:                              ; CODE XREF: IntAllocate+32↑j
                lds     bx, [bp+pError]
                mov     word [bx], 2
                mov     ax, 0FFFFh
                mov     es, ax
                ;assume es:reset_vector
                mov     bx, 0Fh

.loc_FD090:                              ; CODE XREF: IntAllocate+AE↑j
                push    es
                push    bx
                call    LeaveMemMgr
                pop     bx
                pop     es
                ;assume es:nothing
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retf    8
;IntAllocate     endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpAllocate      proc far
CpAllocate:

pError          equ     06h
siz             equ     0Ah

                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, SEG_CCPROM_RAM
                mov     es, ax
                ;assume es:CCPROM_RAM
                mov     bx, 150h
                push    word [es:bx]
                push    [bp+siz]
                les     bx, [bp+pError]
                ;assume es:nothing
                push    es
                push    bx
                call    SEG_MAIN:IntAllocate
        {rmsrc} mov     sp, bp
                pop     bp
                retf    6
;CpAllocate      endp

; =============== S U B R O U T I N E =======================================


;MemoryCheckSum  proc near
MemoryCheckSum:
                push    bp
                mov     ax, 2
                push    ax
                mov     ax, 1Dh
                push    ax
                call    SEG_MAIN:Exception
                pop     bp
                retn    2
;MemoryCheckSum  endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpMemInit(int numBlk, int initSeg)
;CpMemInit       proc far
CpMemInit:

numBlk          equ     08h
initSeg         equ     0Ah

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     ds, [bp+initSeg]
                mov     ax, [bp+numBlk]
                dec     ax
                ;mov     ds:MemCbType.mmcbNumBlk, ax
                mov     [ds:06h], ax                            ;must be "mov ds:MemCbType.mmcbNumBlk, ax"
                ;mov     word [ds:MemCbType.mmcbRemainder], 0
                mov     word [ds:08h], 0                        ;must be "mov word [ds:MemCbType.mmcbRemainder], 0"
                push    ds              ; scbSeg
                call    AddToFreeChain
                pop     bp
                pop     ds
                retf    4
;CpMemInit       endp

; =============== S U B R O U T I N E =======================================


;InitMemMgr      proc far
InitMemMgr:
                push    ds
                call    AtOsAllocMemQ
                mov     al, 0FFh
                push    ax
                mov     ax, 0Ch
                push    ax
                call    SEG_MAIN:OsInitQCB
                call    AtOsFreeMemQ
                mov     al, 0FFh
                push    ax
                mov     ax, 0Ch
                push    ax
                call    SEG_MAIN:OsInitQCB
                mov     ax, 2C4h
                mov     ds, ax
                ;assume ds:nothing
                push    ds
                call    SEG_MAIN:CpCreateSemaphore
                ;mov     word [ds:word_2C48], 0FFFFh
                mov     word [ds:08h], 0FFFFh                   ;must be "mov word [ds:word_2C48], 0FFFFh"
                pop     ds
                ;assume ds:nothing
                retf
;InitMemMgr      endp ; sp-analysis failed

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpFreeTaskMem   proc far
CpFreeTaskMem:

pid             equ     08h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    EnterMemMgr
                mov     ds, [cs:DataFrame_0]
                ;assume ds:CCPROM_RAM
                mov     bx, OsAllocMemQ
                ;mov     ds, [bx+QcbType.headOfQ]
                mov     ds, [bx]                        ;must be "mov ds, [bx+QcbType.headOfQ]"
                ;assume ds:nothing

.OsFtmTopOfLoop:                         ; CODE XREF: CpFreeTaskMem+36↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ;must be "cmp ax, 0FFFFh"
                jz      short .OsFtmDone
                push    ds
                call    CheckCheckSum
                ;mov     ax, ds:QElementType.next
                mov     ax, [ds:02h]                    ;must be "mov ax, ds:QElementType.next"
                push    ax
                ;mov     ax, ds:MemCbType.mmcbPid
                mov     ax, [ds:0Ah]                    ;must be "mov ax, ds:MemCbType.mmcbPid"
                cmp     ax, [bp+pid]
                jnz     short .OsFtmNotEqual
                call    AtOsAllocMemQ
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                push    ds              ; scbSeg
                call    AddToFreeChain

.OsFtmNotEqual:                          ; CODE XREF: CpFreeTaskMem+26↑j
                pop     ds
                jmp     short .OsFtmTopOfLoop
; ---------------------------------------------------------------------------

.OsFtmDone:                              ; CODE XREF: CpFreeTaskMem+16↑j
                call    LeaveMemMgr
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retf    2
;CpFreeTaskMem   endp ; sp-analysis failed
; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpGetMemStatus  proc far
CpGetMemStatus:

tempSizeLow     equ     -0Eh
tempSizeHigh    equ     -0Ch
count           equ     -0Ah
pStatus         equ     -8
qToUse          equ     -4
pError          equ     08h
pMemStatus      equ     0Ch
pid             equ     10h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 14
                call    EnterMemMgr
                lds     bx, [bp+pError]
                mov     word [bx], 0
                mov     al, 0
                les     di, [bp+pMemStatus]
                mov     cx, 10h
                cld
                rep stosb
                lds     bx, [bp+pMemStatus]
                mov     word [bp+pStatus+2], ds
                mov     word [bp+pStatus], bx
                mov     ax, [cs:DataFrame_0]
                mov     word  [bp+qToUse+2], ax
                mov     ax, 170h
                mov     word [bp+qToUse], ax
                mov     word [bp+count], 2

.OsGetTopLoop1:                          ; CODE XREF: CpGetMemStatus+C3↓j
                lds     bx, [bp+qToUse]
                ;mov     ds, [bx+QcbType.headOfQ]
                mov     ds, word [bx]                           ;must be "mov ds, [bx+QcbType.headOfQ]"

.OsGetTopLoop2:                          ; CODE XREF: CpGetMemStatus+B0↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;hack for "cmp ax, 0FFFFh"
                jnz     short .OsGet05
                jmp     short .OsGetLoop2
; ---------------------------------------------------------------------------

.OsGet05:                                ; CODE XREF: CpGetMemStatus+41↑j
                push    ds
                call    CheckCheckSum
                cmp     word [bp+count], 1
                jnz     short .OsGet07
                mov     ax, [bp+pid]
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;hack for "cmp ax, 0FFFFh"
                jz      short .OsGet07
                ;cmp     ax, [ds:MemCbType.mmcbPid]
                cmp     ax, [ds:0Ah]                            ;must be "cmp ax, ds:MemCbType.mmcbPid"
                jnz     short .OsGetNext

.OsGet07:                                ; CODE XREF: CpGetMemStatus+4D↑j
                                        ; CpGetMemStatus+55↑j
                les     bx, [bp+pStatus]
                ;inc     [es:bx+MemStatusType.freeBlocks]
                inc     word [es:bx+04h] ;must be "inc es:[bx+MemStatusType.freeBlocks]"
                ;mov     ax, [ds:MemCbType.mmcbNumBlk]
                mov     ax, [ds:06h]                            ;must be "mov ax, [ds:MemCbType.mmcbNumBlk]"
                mov     dx, 0
                mov     cx, 10h
                mov     di, 0
                call    SEG_UNK_MUL:LQ_DWORD_MUL
                ;call    0FE3Bh:0h                               ;must be "call SEG_MAIN:LQ_DWORD_MUL"
                mov     [bp+tempSizeLow], ax
                mov     [bp+tempSizeHigh], dx
                les     bx, [bp+pStatus]
                mov     cx, [es:bx]
                mov     di, [es:bx+2]
        {rmsrc} add     cx, ax
        {rmsrc} adc     di, dx
                mov     [es:bx], cx
                mov     [es:bx+2], di
        {rmsrc} and     di, di
                les     bx, [bp+pStatus]
                jz      short .OsGetLessThanBigNum
                ;mov     es:[bx+MemStatusType.largestFree], 0FFFFh
                mov     word [es:bx+06h], 0FFFFh                 ;must be "mov es:[bx+MemStatusType.largestFree], 0FFFFh"
                jmp     short .OsGetNext
; ---------------------------------------------------------------------------

.OsGetLessThanBigNum:                    ; CODE XREF: CpGetMemStatus+95↑j
                mov     ax, [bp+tempSizeLow]
                ;cmp     ax, [es:bx+MemStatusType.largestFree]
                cmp     ax, [es:bx+06h]                         ;must be "cmp ax, es:[bx+MemStatusType.largestFree]"
                jb      short .OsGetNext
                ;mov     [es:bx+MemStatusType.largestFree], ax
                mov     word [es:bx+06h], ax                    ;must be "mov es:[bx+MemStatusType.largestFree], ax"

.OsGetNext:                              ; CODE XREF: CpGetMemStatus+5B↑j
                                        ; CpGetMemStatus+9D↑j ...
                ;mov     ds, word [ds:QElementType.next]
                mov     ds, word [ds:02h]                       ;must be "mov ds, word [ds:QElementType.next]"
                jmp     short .OsGetTopLoop2
; ---------------------------------------------------------------------------

.OsGetLoop2:                             ; CODE XREF: CpGetMemStatus+43↑j
                mov     ax, OsAllocMemQ
                mov     word [bp+qToUse], ax
                ;mov     ax, MemStatusType.allocBytes
                mov     ax, word 08h                            ;must be "mov ax, MemStatusType.allocBytes"
                add     word [bp+pStatus], ax
                dec     word [bp+count]
                jz      short .OsGetDone
                jmp     .OsGetTopLoop1
; ---------------------------------------------------------------------------

.OsGetDone:                              ; CODE XREF: CpGetMemStatus+C1↑j
                call    LeaveMemMgr
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retf    0Ah
;CpGetMemStatus  endp



end match
