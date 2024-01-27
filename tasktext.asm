match FALSE, _task_text_asm
display 'Including multitasking routines', 10

_task_text_asm equ TRUE

; these routines are based on original source
; from file CCPROM/TASKTEXT.ASM

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall FreeMe(int sel)
;FreeMe          proc near
FreeMe:

sel             equ 4

                push    bp
        {rmsrc} mov     bp, sp
                pushf
                push    [bp+sel]        ; pBlockSeg
        {rmsrc} xor     ax, ax
                push    ax              ; int
                push    [cs:DataFrame1]
                ;db      2eh, 0ffh, 36h, 80h, 04h    ;hack for "push [cs:DataFrame]"
        {rmsrc} mov     ax, dummyError
                push    ax              ; pError
                sti
                call    SEG_MAIN:CpFree
                popf
                pop     bp
                retn    2
;FreeMe          endp

; =============== S U B R O U T I N E =======================================
;PopStart        proc far
PopStart:
                pop     ds
                ;assume ds:nothing
                pop     es
                ;assume es:nothing
                iret
;PopStart        endp

; =============== S U B R O U T I N E =======================================


;HeadOfProcessQ  proc near
HeadOfProcessQ:
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                mov     bx, OsProcessQ
                ;mov     ds, [bx+QcbType.headOfQ]
                mov     ds, [bx + 00h]       ;hack for this:"mov ds, [bx+QcbType.headOfQ]"
                ;assume ds:nothing
                retn
;HeadOfProcessQ  endp

; =============== S U B R O U T I N E =======================================

;DecTimedProcesses proc near
DecTimedProcesses:
                push    es
                mov     es, [cs:DataFrame1]
                ;assume es:CCPROM_RAM
                mov     bx, timedProcesses
                dec     word [es:bx]
                pop     es
                ;assume es:nothing
                retn
;DecTimedProcesses endp

; =============== S U B R O U T I N E =======================================

;IncTimedProcesses proc near
IncTimedProcesses:
                push    es
                mov     es, [cs:DataFrame1]
                ;assume es:CCPROM_RAM
                mov     bx, timedProcesses
                inc     word [es:bx]
                pop     es
                ;assume es:nothing
                retn
;IncTimedProcesses endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall SemaphoreExists(int sid)
;SemaphoreExists proc near
SemaphoreExists:

sid             equ  4

                push    bp
        {rmsrc} mov     bp, sp
                mov     al, 0FFh
                mov     es, [bp + sid]
                ;cmp     word [es:ScbType.scbIdCode], 5A5Bh
                cmp     word [es:0Ch], 5A5Bh     ;must be "cmp word [es:ScbType.scbIdCode], 5A5Bh"
                jz      short .SemaExDone
                mov     al, 0

.SemaExDone:                             ; CODE XREF: SemaphoreExists+F↑j
                pop     bp
                retn    2
;SemaphoreExists endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;ProcessExists   proc near
ProcessExists:

pid             equ 4

                push    bp
        {rmsrc} mov     bp, sp
                mov     al, 0FFh
                mov     es, [bp+pid]
                ;cmp     word ptr es:PcbType.pcbIdCode, 0A5B5h
                cmp     word [es:47h], 0A5B5h   ; must be "cmp word [es:PcbType.pcbIdCode], 0A5B5h"
                jz      short .ProcessExDone
                mov     al, 0

.ProcessExDone:                          ; CODE XREF: ProcessExists+F↑j
                pop     bp
                retn    2
;ProcessExists   endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;FirstWaitingProcess proc near
FirstWaitingProcess:

sid             equ 6

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    HeadOfProcessQ
                mov     es, [bp + sid]
                ;cmp     word ptr es:ScbType.scbCount, 0
                cmp     word [es:0Eh], 0                 ; must be "cmp word [es:ScbType.scbCount], 0"
                mov     ax, 0FFFFh
                jz      short .FirstWaitReturnNull
                mov     dx, es
                mov     ax, ds

.FirstWaitTopOfLoop:                     ; CODE XREF: FirstWaitingProcess+32↓j
                mov     ds, ax
                ;cmp     ax, word 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"
                jz      short .FirstWaitReturnNull
                ;mov     al, ds:PcbType.pcbState
                mov     al, [ds:0Fh]                    ; must be "mov al, ds:PcbType.pcbState"
                
                and     al, 0Fh
                cmp     al, 3
                jnz     short .FirstWaitNext
                ;cmp     ds:int08offset, dx
                cmp     [ds:30h], dx                    ; must be "cmp ds:int08offset, dx"
                jz      short .FirstWaitFound

.FirstWaitNext:                          ; CODE XREF: FirstWaitingProcess+27↑j
                ;mov     ax, ds:QElementType.next
                mov     ax, word [ds:02h]               ; must be "mov ax, ds:QElementType.next"
                jmp     short .FirstWaitTopOfLoop
; ---------------------------------------------------------------------------

.FirstWaitFound:                         ; CODE XREF: FirstWaitingProcess+2D↑j
                mov     ax, ds

.FirstWaitReturnNull:                    ; CODE XREF: FirstWaitingProcess+13↑j
                                        ; FirstWaitingProcess+1E↑j
                pop     bp
                pop     ds
                retn    2
;FirstWaitingProcess endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall ComputeTime(int time)
;ComputeTime     proc near
ComputeTime:

time            equ  4

                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, [bp + time]
                mov     cx, [cs:tickGranularity]
        {rmsrc} add     ax, cx
                dec     ax
        {rmsrc} xor     dx, dx
                div     cx
                pop     bp
                retn    2               ; RETURN ((time + timeSlice - 1) / timeSlice)
;ComputeTime     endp

; =============== S U B R O U T I N E =======================================


;CpWhoAmI        proc far
CpWhoAmI:
                push    ds
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                mov     ax, [OsCurrentPid]
                pop     ds
                ;assume ds:nothing
                retf
;CpWhoAmI        endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;AnyMessage      proc near
AnyMessage:

arg_0           equ  6
arg_2           equ  8

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    SEG_MAIN:CpWhoAmI
                mov     ds, ax
                mov     ds, word [ds:6]
                mov     cx, [bp+arg_0]
                mov     dx, [bp+arg_2]

.loc_FC592:                              ; CODE XREF: AnyMessage+38↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"
                jz      short .loc_FC5B9
                cmp     [ds:0Eh], dx
                jz      short .loc_FC5A5
                ;cmp     dx, 0FFFFh
                db      81h, 0FAh, 0FFh, 0FFh                 ; hack for "cmp cx, 0FFFFh"

                jnz     short .loc_FC5B1

.loc_FC5A5:                              ; CODE XREF: AnyMessage+20↑j

                ;cmp     cx, 0FFFFh
                db      81h, 0F9h, 0FFh, 0FFh                 ; hack for "cmp cx, 0FFFFh"
                jz      short .loc_FC5B7
                cmp     cx, [ds:8]
                jz      short .loc_FC5B7

.loc_FC5B1:                              ; CODE XREF: AnyMessage+26↑j
                mov     ds, word [ds:2]
                jmp     short .loc_FC592
; ---------------------------------------------------------------------------

.loc_FC5B7:                              ; CODE XREF: AnyMessage+2C↑j
                mov     ax, ds

.loc_FC5B9:                              ; CODE XREF: AnyMessage+1A↑j

                pop     bp
                pop     ds
                retn    4
;AnyMessage      endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;AddToReadyQ     proc near
AddToReadyQ:

pid             equ  6

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     ds, [bp+pid]
                mov     cl, byte [ds:10h]
                call    HeadOfProcessQ
                mov     dx, 0FFFFh
                mov     ax, ds

.AddToTopOfLoop:                         ; CODE XREF: AddToReadyQ+25↓j
                mov     ds, ax
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .AddToLoopExit
                cmp     byte [ds:10h], cl
                ja      short .AddToLoopExit
                mov     dx, ds
                ;mov     ax, ds:QElementType.next
                mov     ax, [ds:02h]                 ;must be "mov ax, ds:QElementType.next"
                jmp     short .AddToTopOfLoop
; ---------------------------------------------------------------------------

.AddToLoopExit:                          ; CODE XREF: AddToReadyQ+18↑j
                                        ; AddToReadyQ+1E↑j
                mov     ax, SEG_CCPROM_RAM
                push    ax
                mov     ax, OsProcessQ
                push    ax
                push    dx
                push    [bp+pid]
                call    SEG_MAIN:OsInsertIntoQ
                pop     bp
                pop     ds
                retn    2
;AddToReadyQ     endp

; =============== S U B R O U T I N E =======================================


;FirstReadyProcess proc near
FirstReadyProcess:

                push    ds
                call    HeadOfProcessQ
                mov     ax, ds

.FirstReadyTopOfLoop:                    ; CODE XREF: FirstReadyProcess+17↓j
                mov     ds, ax
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .FirstReadyReturn
                ;cmp     byte ptr ds:PcbType.pcbState, 0
                cmp     byte [ds:0Fh], 0                  ;must be "cmp byte ptr ds:PcbType.pcbState, 0"
                jz      short .FirstReadyReturn
                ;mov     ax, ds:QElementType.next
                mov     ax, [ds:02h]                    ;must be "mov ax, ds:QElementType.next"
                jmp     short .FirstReadyTopOfLoop
; ---------------------------------------------------------------------------

.FirstReadyReturn:                       ; CODE XREF: FirstReadyProcess+B↑j
                                        ; FirstReadyProcess+12↑j
                mov     ax, ds
                pop     ds
                retn
;FirstReadyProcess endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;RoundRobinProcess proc near
RoundRobinProcess:

pid             equ     6

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    FirstReadyProcess
                mov     es, ax
                mov     ds, [bp+pid]
                ;mov     ds, word ptr ds:QElementType.next
                mov     ds, word [ds:02h]           ; must be "mov ds, word ptr ds:QElementType.next"
                mov     ax, ds

.RoundRobTopOfLoop:                      ; CODE XREF: RoundRobinProcess+23↓j
                mov     ds, ax
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .RoundRealFirst
                ;cmp     byte ptr ds:PcbType.pcbState, 0
                cmp     byte [ds:0Fh], 0                ;must be "cmp byte ptr ds:PcbType.pcbState, 0"
                jz      short .RoundRobFirstReady
                ;mov     ax, ds:QElementType.next
                mov     ax, word [ds:02h]           ; must be "mov ax, word ptr ds:QElementType.next"
                jmp     short .RoundRobTopOfLoop
; ---------------------------------------------------------------------------

.RoundRobFirstReady:                     ; CODE XREF: RoundRobinProcess+1E↑j
                mov     al, byte [ds:10h]
                ;cmp     al, es:PcbType.pcbPriority
                cmp     al, [es:10h]                ;must be ";cmp al, es:PcbType.pcbPriority"
                mov     ax, ds
                jbe     short .RoundRobReturn

.RoundRealFirst:                         ; CODE XREF: RoundRobinProcess+17↑j
                mov     ax, es

.RoundRobReturn:                         ; CODE XREF: RoundRobinProcess+2F↑j
                pop     bp
                pop     ds
                retn    2
;RoundRobinProcess endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;TellWaiters     proc near
TellWaiters:
sid             equ     6

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                call    HeadOfProcessQ
                mov     dx, [bp+sid]

.TellWaitTopOfLoop:                      ; CODE XREF: TellWaiters+3C↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .TellWaitDone
                ;mov     al, ds:PcbType.pcbState
                mov     al, [ds:0Fh]                    ;must be "mov al, ds:PcbType.pcbState"
        {rmsrc} mov     ah, al
                and     al, 0Fh
                cmp     al, 3
                jnz     short .TellWaitNext
                cmp     [ds:30h], dx
                
                jnz     short .TellWaitNext
                les     bx, dword [ds:40h]
                mov     word [es:bx], 0FCh
                cmp     ah, 13h
                jnz     short .TellWait10
                call    DecTimedProcesses

.TellWait10:                             ; CODE XREF: TellWaiters+2E↑j
                ;mov     byte ds:PcbType.pcbState, 0
                mov     byte [ds:0Fh], 0                ;must be "mov byte ds:PcbType.pcbState, 0"

.TellWaitNext:                           ; CODE XREF: TellWaiters+1A↑j
                                        ; TellWaiters+20↑j
                ;mov     ds, word ptr ds:QElementType.next
                mov     ds, word [ds:02h]               ;must be "mov ds, word ptr ds:QElementType.next"
                jmp     short .TellWaitTopOfLoop
; ---------------------------------------------------------------------------

.TellWaitDone:                           ; CODE XREF: TellWaiters+F↑j
                pop     bp
                pop     ds
                retn    2
;TellWaiters     endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;TellMessageWaiters proc far
TellMessageWaiters:

exitCode        equ     8
procID          equ     0Ah

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                call    HeadOfProcessQ
                mov     dx, [bp+procID]

.TellMessTopOfLoop:                      ; CODE XREF: TellMessageWaiters+45↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .TellMessDone
                ;mov     al, ds:PcbType.pcbState
                mov     al, [ds:0Fh]                    ;must be "mov al, ds:PcbType.pcbState"
        {rmsrc} mov     ah, al
                and     al, 0Fh
                cmp     al, 2
                jnz     short .TellMessNext
                cmp     [ds:30h], dx
                jnz     short .TellMessNext
                mov     cx, [bp+exitCode]
                mov     [ds:18h], cx
                les     bx, dword [ds:40h]
                mov     word [es:bx], 0FBh
                cmp     ah, 12h
                jnz     short .TellMess10
                call    DecTimedProcesses

.TellMess10:                             ; CODE XREF: TellMessageWaiters+37↑j
                ;mov     byte ptr ds:PcbType.pcbState, 0
                mov     byte [ds:0Fh], 0             ;must be "mov byte ptr ds:PcbType.pcbState, 0"

.TellMessNext:                           ; CODE XREF: TellMessageWaiters+1C↑j
                                        ; TellMessageWaiters+22↑j
                mov     ds, word [ds:2]
                jmp     short .TellMessTopOfLoop
; ---------------------------------------------------------------------------

.TellMessDone:                           ; CODE XREF: TellMessageWaiters+11↑j
                popf
                pop     bp
                pop     ds
                retf    4
;TellMessageWaiters endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;SwapTasksRoutine proc near
SwapTasksRoutine:

                push    bp
        {rmsrc} mov     bp, sp
                mov     ax, [ds:150h]
                mov     es, ax
                ;cmp     ax, 0FFFEh
                db      3Dh, 0FEh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .SwapTask10
                ;mov     word [es:PcbType.pcbStackSeg], ss
                mov     word [es:1Eh], ss               ;must be "mov word [es:PcbType.pcbStackSeg], ss"
                
                ;mov     es:PcbType.pcbStackOff, sp
                mov     [es:1Ch], sp                    ;must be "mov es:PcbType.pcbStackOff, sp"
                ;mov     al, es:PcbType.pcbUses8087
                mov     al, [es:49h]                    ;must be "mov al, es:PcbType.pcbUses8087"
                
                rcr     al, 1
                jnb     short .SwapTask10
                push    ds
                ;lds     bx, es:PcbType.pcbP8087Regs
                lds     bx, [es:4Ah]                    ;must be "lds bx, es:PcbType.pcbP8087Regs"
                pushf
                cli
                nop
                ;fnsave  byte [bx]
                db      0DDh, 37h                       ;hack for "fnsave byte [bx]"
                wait
                popf
                pop     ds

.SwapTask10:                             ; CODE XREF: SwapTasksRoutine+B↑j
                                        ; SwapTasksRoutine+1D↑j
                mov     ax, [ds:168h]
                mov     [ds:150h], ax
                mov     es, ax
                ;mov     ss, word ptr es:PcbType.pcbStackSeg
                mov     ss, word [es:1Eh]               ;must be "mov ss, word ptr es:PcbType.pcbStackSeg"
                ;assume ss:nothing
                ;mov     sp, es:PcbType.pcbStackOff
                mov     sp, [es:1Ch]                    ;must be "mov sp, es:PcbType.pcbStackOff"
                ;mov     al, es:PcbType.pcbUses8087
                mov     al, [es:49h]                    ;must be "mov al, es:PcbType.pcbUses8087"
                rcr     al, 1
                jnb     short .SwapTask20
                push    ds
                ;lds     bx, es:PcbType.pcbP8087Regs
                lds     bx, [es:4Ah]                    ;must be "lds bx, es:PcbType.pcbP8087Regs"
                wait
                ;frstor  byte [bx]
                db      0DDh, 27h                       ;hack for "frstor byte [bx]"
                wait
                pop     ds

.SwapTask20:                             ; CODE XREF: SwapTasksRoutine+45↑j
                pop     bp
                retn
;SwapTasksRoutine endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;Reschedule      proc far
Reschedule:

pid             equ     8

                push    ds
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                ;cmp     word [bp+pid], 0FFFFh
                db      81h, 7Eh, 08h, 0FFh, 0FFh           ;hack for "cmp  word [bp+pid], 0FFFFh"
                jnz     short .ReschTest2
                push    [OsCurrentPid]
                call    RoundRobinProcess
                jmp     short .ReschDoIt
; ---------------------------------------------------------------------------

.ReschTest2:                             ; CODE XREF: Reschedule+E↑j
                ;cmp     word [bp+pid], 0FFFEh
                db      81h, 7Eh, 08h, 0FEh, 0FFh           ;hack for "cmp  word [bp+pid], 0FFFFh"

                jnz     short .ReschTest3
                mov     word [OsCurrentPid], 0FFFEh
                call    FirstReadyProcess
                jmp     short .ReschDoIt
; ---------------------------------------------------------------------------

.ReschTest3:                             ; CODE XREF: Reschedule+1E↑j
                mov     es, [bp+pid]
                ;mov     al, es:PcbType.pcbPriority
                mov     al, [es:10h]                    ;must be "mov al, es:PcbType.pcbPriority"
                mov     es, [OsCurrentPid]
                ;cmp     al, es:PcbType.pcbPriority
                cmp     al, [es:10h]                    ;must be "cmp al, es:PcbType.pcbPriority"
                ja      short .ReschDone
                mov     ax, [bp+pid]

.ReschDoIt:                              ; CODE XREF: Reschedule+17↑j
                                        ; Reschedule+29↑j
                cmp     ax, [OsCurrentPid]
                jz      short .ReschDone
                mov     [nextpidToSchedule], ax
                call    SwapTasksRoutine

.ReschDone:                              ; CODE XREF: Reschedule+3B↑j
                                        ; Reschedule+44↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf    2
;Reschedule      endp


; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpSignal(__int32 pError, int note, char mode, int sid)
;CpSignal        proc far           ; OnIrq5_bubble+4B↓P ...
CpSignal:

pError          equ     8
note            equ     0Ch
MODE            equ     0Eh
sid             equ     10h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                lds     bx, [bp+pError]
                mov     word [bx], 0
                push    [bp+sid]        ; sid
                call    SemaphoreExists
                rcr     al, 1
                jnb     short .CpSignalNotExist
                push    [bp+sid]
                call    FirstWaitingProcess
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jnz     short .CpSignalYes
                mov     al, [bp+MODE]
                and     al, 7Fh
                cmp     al, 1
                jnz     short .CpSignalDone
                mov     ds, [bp+sid]
                mov     ax, [bp+note]
                ;mov     ds:ScbType.scbNote, ax
                mov     [ds:0Ah], ax                    ;must be "mov ds:ScbType.scbNote, ax"
                ;mov     word ptr ds:ScbType.scbBusy, 0FFFFh
                mov     word [ds:08h], 0FFFFh           ;must be "mov word ptr ds:ScbType.scbBusy, 0FFFFh"
                jmp     short .CpSignalDone
; ---------------------------------------------------------------------------

.CpSignalYes:                            ; CODE XREF: CpSignal+20↑j
                mov     es, [bp+sid]
                mov     ds, ax
                mov     si, ds
                ;mov     word ptr es:ScbType.scbBusy, ds
                mov     word [es:08h], ds               ;must be "mov word ptr es:ScbType.scbBusy, ds"

.CpSignalTopOfLoop:                      ; CODE XREF: CpSignal+7C↓j
                mov     ax, ds
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ; hack for "cmp ax, 0FFFFh"

                jz      short .CpSignalReschedule
                mov     ax, [bp+note]
                mov     [ds:18h], ax
                ;cmp     byte ptr ds:PcbType.pcbState, 13h
                cmp     byte [ds:0Fh], 13h              ;must be "cmp byte ptr ds:PcbType.pcbState, 13h"
                jnz     short .CpSignal10
                call    DecTimedProcesses

.CpSignal10:                             ; CODE XREF: CpSignal+5A↑j
                ;mov     byte [ds:PcbType.pcbState], 0
                mov     byte [ds:0Fh], 0                ;must be "mov byte [ds:PcbType.pcbState], 0"
                ;dec     word [es:ScbType.scbCount]
                dec     word [es:0Eh]                   ;must be "dec word [es:ScbType.scbCount]"
                mov     al, [bp+MODE]
                and     al, 7Fh
                cmp     al, 1
                jz      short .CpSignalReschedule
                push    si
                push    es
                push    es
                call    FirstWaitingProcess
                pop     es
                pop     si
                mov     ds, ax
                jmp     short .CpSignalTopOfLoop
; ---------------------------------------------------------------------------

.CpSignalNotExist:                       ; CODE XREF: CpSignal+15↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0FCh
                jmp     short .CpSignalDone
; ---------------------------------------------------------------------------

.CpSignalReschedule:                     ; CODE XREF: CpSignal+4D↑j
                                        ; CpSignal+70↑j
                cmp     byte [bp+MODE], 7Fh
                jnb     short .CpSignalDone
                push    si
                call    SEG_MAIN:Reschedule
                jmp     short $+2
; ---------------------------------------------------------------------------

.CpSignalDone:                           ; CODE XREF: CpSignal+29↑j
                                        ; CpSignal+3A↑j ...
                popf
                pop     bp
                pop     ds
                retf    0Ah
;CpSignal        endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpWait(__int32 pError, int timeLimit, int sid)
;CpWait          proc far                ; BCM_related_stuff+A3↓P ...
CpWait:

pError          equ     8
timeLimit       equ     0Ch
sid             equ     0Eh

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                lds     bx, [bp+pError]
                mov     word [bx], 0
                push    [bp+sid]        ; sid
                call    SemaphoreExists
                rcr     al, 1
                jnb     short .CpWaitNotExist
                mov     ds, [bp+sid]
                ;cmp     word [ds:8], 0FFFFh
                db      81h, 3Eh, 08h, 00, 0FFh, 0FFh           ; hack for "cmp word [ds:8], 0FFFFh"
                jnz     short .CpWaitNotSignalled
                call    SEG_MAIN:CpWhoAmI
                mov     [es:8], ax
                mov     ax, [ds:0Ah]
                jmp     short .CpWaitDone
; ---------------------------------------------------------------------------

.CpWaitNotSignalled:                     ; CODE XREF: CpWait+20↑j
                cmp     word [bp+timeLimit], 0
                jnz     short .CpWait10
                lds     bx, [bp+pError]
                mov     word [bx], 0FDh
        {rmsrc} xor     ax, ax
                jmp     short .CpWaitDone
; ---------------------------------------------------------------------------

.CpWait10:                               ; CODE XREF: CpWait+34↑j
                call    SEG_MAIN:CpWhoAmI
                mov     ds, ax
                mov     byte [ds:0Fh], 3
                ;cmp     word [bp+timeLimit], 0FFFFh
                db      81h, 7Eh, 0Ch, 0FFh, 0FFh           ; hack for "cmp word [bp+timeLimit], 0FFFFh"
                jz      short .CpWaitForever
                mov     byte [ds:0Fh], 13h
                call    IncTimedProcesses
                push    [bp+timeLimit]  ; time
                call    ComputeTime
                mov     [ds:1Ah], ax

.CpWaitForever:                          ; CODE XREF: CpWait+52↑j
                les     bx, [bp+pError]
                mov     word [ds:42h], es
                mov     [ds:40h], bx
                mov     ax, [bp+sid]
                mov     [ds:30h], ax
                mov     es, [bp+sid]
                inc     word [es:0Eh]
                mov     ax, 0FFFFh
                push    ax
                call    SEG_MAIN:Reschedule
                mov     ax, [ds:18h]
                jmp     short .CpWaitDone
; ---------------------------------------------------------------------------

.CpWaitNotExist:                         ; CODE XREF: CpWait+15↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0FCh
        {rmsrc} xor     ax, ax

.CpWaitDone:                             ; CODE XREF: CpWait+2E↑j
                                        ; CpWait+3F↑j ...
                popf
                pop     bp
                pop     ds
                retf    8
;CpWait          endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpSend          proc far
CpSend:

arg_0           equ     08h
arg_4           equ     0Ch
arg_8           equ     10h
arg_A           equ     12h
arg_C           equ     14h

                push    ds
                push    bp
       {rmsrc}  mov     bp, sp
                pushf
                cli
                lds     bx, [bp+arg_0]
                mov     word [bx], 0
                mov     ds, [bp+arg_C]
                push    ds
                call    ProcessExists
                rcr     al, 1
                jb      short .loc_FC8D6
                jmp     .loc_FC97A
; ---------------------------------------------------------------------------

.loc_FC8D6:                              ; CODE XREF: CpSend+16↑j
                mov     al, [ds:0Fh]
                and     al, 0Fh
                cmp     al, 2
                jnz     short .loc_FC927
                call    SEG_MAIN:CpWhoAmI
                cmp     ax, [ds:30h]
                jz      short .loc_FC8F2
                ;cmp     word [ds:30h], 0FFFFh
                db      81h, 3Eh, 30h, 00h, 0FFh, 0FFh          ;hack for "cmp word [ds:30h], 0FFFFh"
                jnz     short .loc_FC927

.loc_FC8F2:                              ; CODE XREF: CpSend+2D↑j
                mov     ax, [ds:16h]
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;hack for "cmp ax, 0FFFFh"
                jz      short .loc_FC8FF
                cmp     ax, [bp+arg_A]
                jnz     short .loc_FC927

.loc_FC8FF:                              ; CODE XREF: CpSend+3D↑j
                mov     ax, [bp+arg_8]
                mov     [ds:18h], ax
                les     bx, [bp+arg_4]
                mov     word [ds:14h], es
                mov     [ds:12h], bx
                cmp     byte [ds:0Fh], 12h
                jnz     short .loc_FC91A
                call    DecTimedProcesses

.loc_FC91A:                              ; CODE XREF: CpSend+5A↑j
                mov     byte [ds:0Fh], 0
                push    ds
                call    SEG_MAIN:Reschedule
                jmp     short .loc_FC981
; ---------------------------------------------------------------------------

.loc_FC927:                              ; CODE XREF: CpSend+22↑j
                                        ; CpSend+35↑j ...
                push    ds
                mov     ax, 10h
                push    ax
                les     bx, [bp+arg_0]
                push    es
                push    bx
                sti
                call    SEG_MAIN:IntAllocate
                cli
                mov     ax, es
                les     bx, [bp+arg_0]
                cmp     word [es:bx], 0
                jnz     short .loc_FC981
                mov     dx, ds
                mov     ds, ax
                mov     ax, [bp+arg_8]
                mov     [ds:06h], ax
                mov     ax, [bp+arg_A]
                mov     [ds:08h], ax
                les     bx, [bp+arg_4]
                mov     [ds:0Ah], bx
                mov     word [ds:0Ch], es
                call    SEG_MAIN:CpWhoAmI
                mov     [ds:0Eh], ax
                push    dx
                mov     bx, 6
                push    bx
                mov     es, dx
                push    word [es:08h]
                push    ds
                call    SEG_MAIN:OsInsertIntoQ
                jmp     short .loc_FC981
; ---------------------------------------------------------------------------

.loc_FC97A:                              ; CODE XREF: CpSend+18↑j
                lds     bx, [bp+arg_0]
                mov     word [bx], 0FBh

.loc_FC981:                              ; CODE XREF: CpSend+6A↑j
                                        ; CpSend+86↑j ...
                popf
                pop     bp
                pop     ds
                retf    0Eh
;CpSend          endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpReceive(__int32 pError, __int32 pNote, int timeLimit, int messageType, int sourceProcID)
;CpReceive       proc far
CpReceive:

pError          equ     08h
pNote           equ     0Ch
timeLimit       equ     10h
messageType     equ     12h
sourceProcID    equ     14h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                lds     bx, [bp+pError]
                mov     word [bx], 0
                ;cmp     word [bp+sourceProcID], 0FFFFh
                db      81h, 7Eh, 14h, 0FFh, 0FFh               ;hack for "cmp word [bp+sourceProcID], 0FFFFh"
                jz      short .loc_FC9AF
                push    [bp+sourceProcID]
                call    ProcessExists
                rcr     al, 1
                jb      short .loc_FC9AF
                lds     bx, [bp+pError]
                mov     word [bx], 0FBh
                jmp     short .loc_FC9F7
; ---------------------------------------------------------------------------
                db  90h
; ---------------------------------------------------------------------------

.loc_FC9AF:                              ; CODE XREF: CpReceive+12↑j
                                        ; CpReceive+1C↑j
                push    [bp+sourceProcID]
                push    [bp+messageType]
                call    AnyMessage
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                         ;hack for "cmp ax, 0FFFFh"
                jz      short .loc_FC9EA
                mov     ds, ax
                mov     ax, [ds:06h]
                les     bx, [bp+pNote]
                mov     [es:bx], ax
                mov     es, word [ds:0Ch]
                mov     bx, [ds:0Ah]
                push    es
                push    bx
                call    SEG_MAIN:CpWhoAmI
                push    ax
                mov     ax, 6
                push    ax
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                push    ds              ; sel
                call    FreeMe
                pop     bx
                pop     es
                jmp     short .loc_FCA56
; ---------------------------------------------------------------------------

.loc_FC9EA:                              ; CODE XREF: CpReceive+34↑j
                cmp     word [bp+timeLimit], 0
                jnz     short .loc_FCA01
                lds     bx, [bp+pError]
                mov     word [bx], 0FDh

.loc_FC9F7:                              ; CODE XREF: CpReceive+25↑j
                mov     ax, 0FFFFh
                mov     es, ax
                ;assume es:reset_vector
                mov     bx, 0Fh
                jmp     short .loc_FCA56
; ---------------------------------------------------------------------------

.loc_FCA01:                              ; CODE XREF: CpReceive+67↑j
                call    SEG_MAIN:CpWhoAmI
                mov     ds, ax
                mov     byte [ds:0Fh], 2
                ;cmp     word [bp+timeLimit], 0FFFFh
                db      81h, 7Eh, 10h, 0FFh, 0FFh           ;hack for "cmp word [bp+timeLimit], 0FFFFh"
                jz      short .loc_FCA25
                mov     byte [ds:0Fh], 12h
                push    [bp+timeLimit]  ; time
                call    ComputeTime
                mov     [ds:1Ah], ax
                call    IncTimedProcesses

.loc_FCA25:                              ; CODE XREF: CpReceive+8B↑j
                mov     ax, [bp+sourceProcID]
                mov     [ds:30h], ax
                mov     ax, [bp+messageType]
                mov     [ds:16h], ax
                les     bx, [bp+pError]
                ;assume es:nothing
                mov     word [ds:42h], es
                mov     [ds:40h], bx
                mov     ax, 0FFFFh
                push    ax
                call    SEG_MAIN:Reschedule
                mov     ax, [ds:18h]
                les     bx, [bp+pNote]
                mov     [es:bx], ax
                mov     es, word [ds:14h]
                mov     bx, [ds:12h]

.loc_FCA56:                              ; CODE XREF: CpReceive+61↑j
                                        ; CpReceive+78↑j
                popf
                pop     bp
                pop     ds
                retf    0Eh
;CpReceive       endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpCreateProcess proc far                ; initMultitasking+CA↓P ...
CpCreateProcess:

pid             equ     08h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                mov     ds, [bp+pid]
                mov     word [ds:46h+1], 0A5B5h
                push    ds
                ;mov     ax, PcbType.pcbMsgHeadOff
                mov     ax, 06h                                 ;must be "mov ax, PcbType.pcbMsgHeadOff"
                push    ax
                mov     al, 0
                push    ax
                mov     ax, 10h
                push    ax
                call    SEG_MAIN:OsInitQCB
                push    ds
                pop     es
                ;assume es:nothing
                ;lea     di, ds:PcbType.pcbHeap
                lea     di, [ds:20h]                            ;must be "lea di, ds:PcbType.pcbHeap"
                mov     cx, 10h
                mov     al, 0
                cld
                rep stosb
                ;mov     byte [ds:PcbType.pcbState], 0
                mov     byte [ds:0Fh], 0                        ;must be "mov byte [ds:PcbType.pcbState], 0"
                les     bx, dword [ds:1Ch]
                ;assume es:nothing
                mov     ax, PopStart
                ;mov    [es:bx+RegTableType.regKip], ax
                mov     [es:bx+02h], ax                         ;must be "mov [es:bx+RegTableType.regKip], ax"
                ;mov     [es:bx+RegTableType.regFl], 0F246h
                mov     word [es:bx+0Ch], 0F246h                ;must be "mov es:bx+RegTableType.regFl], 0F246h"
                push    ds
                call    AddToReadyQ
                popf
                pop     bp
                pop     ds
                retf    2
;CpCreateProcess endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpDeleteProcess proc far
CpDeleteProcess:

hariKari        equ     -2
pError          equ     08h
exitCode        equ     0Ch
pid             equ     0Eh

                push    ds
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                push    bp
        {rmsrc} mov     bp, sp
                sub     sp, 2
                pushf
                cli
                mov     ax, [OsCurrentPid]
                cmp     ax, [bp+pid]
                mov     al, 0FFh
                jz      short .CpDelete10
                mov     al, 0

.CpDelete10:                             ; CODE XREF: CpDeleteProcess+16↑j
                mov     [bp+hariKari], al
                push    [bp+pid]
                call    ProcessExists
                rcr     al, 1
                jnb     short .loc_FCB32
                mov     ds, [bp+pid]
                ;assume ds:nothing
                ;mov     al, ds:PcbType.pcbState
                mov     al, [ds:0Fh]                        ;must be "mov al, ds:PcbType.pcbState"
                test    al, 10h
                jz      short .CpDelete20
                push    ax
                call    DecTimedProcesses
                pop     ax

.CpDelete20:                             ; CODE XREF: CpDeleteProcess+2F↑j
                and     al, 0Fh
                cmp     al, 3
                jnz     short .CpDelete30
                mov     es, [ds:30h]
                ;cmp     word [es:ScbType.scbIdCode], 5A5Bh
                cmp     word [es:0Ch], 5A5Bh            ;must be "cmp word es:ScbType.scbIdCode, 5A5Bh"
                jnz     short .CpDelete30
                ;dec     word [es:ScbType.scbCount]
                dec     word [es:0Eh]                       ;must be "dec word [es:ScbType.scbCount]"

.CpDelete30:                             ; CODE XREF: CpDeleteProcess+3A↑j
                                        ; CpDeleteProcess+47↑j
                push    ds
                push    [bp+exitCode]
                call    SEG_MAIN:TellMessageWaiters
                inc     word [ds:46h+1]
                push    ds              ; sel
                call    FreeMe
                push    [cs:DataFrame1]
                mov     ax, OsProcessQ
                push    ax
                push    [bp+pid]
                call    SEG_MAIN:OsRemoveFromQ
                cmp     byte [bp+hariKari], 0FFh
                jnz     short .CpDelete40
                mov     ax, 0FFFEh
                push    ax
                call    SEG_MAIN:Reschedule

.CpDelete40:                             ; CODE XREF: CpDeleteProcess+74↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0
                jmp     short .loc_FCB39
; ---------------------------------------------------------------------------

.loc_FCB32:                              ; CODE XREF: CpDeleteProcess+25↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0FBh

.loc_FCB39:                              ; CODE XREF: CpDeleteProcess+86↑j
                popf
        {rmsrc} mov     sp, bp
                pop     bp
                pop     ds
                retf    8
;CpDeleteProcess endp

; =============== S U B R O U T I N E =======================================

; Milliseconds
; Attributes: bp-based frame

; int __stdcall __far CpDelay(int timeLimit)
;CpDelay         proc far                ; GPIBdriver+5EF↓P ...
CpDelay:

timeLimit       equ     08h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                cmp     word [bp+timeLimit], 0
                jz      short .CpDelayReschedule
                call    SEG_MAIN:CpWhoAmI
                mov     ds, ax
                push    [bp+timeLimit]  ; time
                call    ComputeTime
                mov     [ds:1Ah], ax
                mov     byte [ds:0Fh], 10h
                mov     ax, [cs:DataFrame1]
                mov     [ds:42h], ax
                mov     ax, dummyError
                mov     [ds:40h], ax
                call    IncTimedProcesses

.CpDelayReschedule:                      ; CODE XREF: CpDelay+A↑j
                mov     ax, 0FFFFh
                push    ax
                call    SEG_MAIN:Reschedule
                popf
                pop     bp
                pop     ds
                retf    2
;CpDelay         endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpSetPriority   proc far
CpSetPriority:

pError          equ     08h
priority        equ     0Ch
pid             equ     0Eh

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                lds     bx, [bp+pError]
                mov     word [bx], 0
                mov     ds, [bp+pid]
                push    ds
                call    ProcessExists
                rcr     al, 1
                jnb     short .loc_FCBBD
                push    [cs:DataFrame1]
                mov     ax, 13Eh
                push    ax
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                mov     al, [bp+priority]
                mov     byte [ds:10h], al
                push    ds
                call    AddToReadyQ
                call    FirstReadyProcess
                push    ax
                call    SEG_MAIN:Reschedule
                jmp     short .loc_FCBC4
; ---------------------------------------------------------------------------

.loc_FCBBD:                              ; CODE XREF: CpSetPriority+16↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0FBh

.loc_FCBC4:                              ; CODE XREF: CpSetPriority+3A↑j
                popf
                pop     bp
                pop     ds
                retf    8
;CpSetPriority   endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;CpCreateSemaphore proc far              ; GPIB_SendByte?-2E4↓P ...
CpCreateSemaphore:

sid             equ     08h

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                mov     ds, word [bp+sid]
                call    SEG_MAIN:CpWhoAmI
                ;mov     ds:ScbType.scbParentPid, ax
                mov     [ds:06h], ax                            ;must be "mov ds:ScbType.scbParentPid, ax"
        {rmsrc} xor     ax, ax
                ;mov     ds:ScbType.scbBusy, ax
                mov     [ds:08h], ax                            ;must be "mov ds:ScbType.scbBusy, ax"
                ;mov     ds:ScbType.scbNote, ax
                mov     [ds:0Ah], ax                            ;must be "mov ds:ScbType.scbNote, ax"
                ;mov     ds:ScbType.scbCount, ax
                mov     [ds:0Eh], ax                            ;must be "mov ds:ScbType.scbCount, ax"
                ;mov     word [ds:ScbType.scbIdCode], 5A5Bh
                mov     word [ds:0Ch], 5A5Bh                     ;must be "mov word [ds:ScbType.scbIdCode], 5A5Bh"
                push    [cs:DataFrame1]
                mov     ax, osSemaQ
                push    ax
                mov     ax, 0FFFFh
                push    ax
                push    ds
                call    SEG_MAIN:OsInsertIntoQ
                popf
                pop     bp
                pop     ds
                retf    2
;CpCreateSemaphore endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

; int __stdcall __far CpDeleteSemaphore(__int32 pError, int sid)
;CpDeleteSemaphore proc far
CpDeleteSemaphore:

pError          equ     08h
sid             equ     0Ch

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                pushf
                cli
                lds     bx, [bp+pError]
                mov     word [bx], 0
                mov     ds, word [bp+sid]
                push    ds              ; sid
                call    SemaphoreExists
                rcr     al, 1
                jnb     short .CpDSNotExist
                push    ds
                call    TellWaiters
                push    [cs:DataFrame1]
                mov     ax, osSemaQ
                push    ax
                push    ds
                call    SEG_MAIN:OsRemoveFromQ
                ;inc     word [ds:ScbType.scbIdCode]
                inc     word [ds:0Ch]             ;must be "inc word [ds:ScbType.scbIdCode]"
                push    ds              ; sel
                call    FreeMe
                call    FirstReadyProcess
                push    ax
                call    SEG_MAIN:Reschedule
                jmp     short .CpDsDone
; ---------------------------------------------------------------------------

.CpDSNotExist:                           ; CODE XREF: CpDeleteSemaphore+16↑j
                lds     bx, [bp+pError]
                mov     word [bx], 0FCh

.CpDsDone:                               ; CODE XREF: CpDeleteSemaphore+3C↑j
                popf
                pop     bp
                pop     ds
                retf    6
;CpDeleteSemaphore endp

; =============== S U B R O U T I N E =======================================

; Attributes: bp-based frame

;TimerInterrupt  proc far                ; j_TimerInterrupt↓J
TimerInterrupt:

                push    ds
                push    bp
        {rmsrc} mov     bp, sp
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                mov     si, [timedProcesses]
                mov     di, 0FFFFh
                call    HeadOfProcessQ
        {rmsrc} xor     cx, cx
                mov     ax, ds

.TimerTopOfLoop:                         ; CODE XREF: TimerInterrupt+3B↓j
                mov     ds, ax
                ;cmp     ax, 0FFFFh
                db      3Dh, 0FFh, 0FFh                 ;hack for "cmp ax, 0FFFFh"
                jz      short .TimerDone
        {rmsrc} cmp     cx, si
                jnb     short .TimerDone
                mov     al, [byte_298F]
        {rmsrc} mov     bl, al
                cmp     al, 10h
                jb      short .TimerNext
                mov     ax, word [busyStack+8]
                ;cmp     ax, 0
                db      3Dh, 00h, 00h                   ;hack for "cmp ax, 0"
                jz      short .TimerIsZero
                dec     ax
                mov     word [busyStack+8], ax

.TimerIncCount:                          ; CODE XREF: TimerInterrupt+60↓j
                                        ; TimerInterrupt+64↓j
                inc     cx

.TimerNext:                              ; CODE XREF: TimerInterrupt+29↑j
                mov     ax, [keyHandlerSeg]
                jmp     short .TimerTopOfLoop
; ---------------------------------------------------------------------------

.TimerIsZero:                            ; CODE XREF: TimerInterrupt+31↑j
                cmp     bl, 13h
                jnz     short .TimerNotSema
                mov     es, word [busyStack+1Eh]
                ;dec     word [es:ScbType.scbCount]
                dec     word [es:0Eh]                       ;must be "dec word [es:ScbType.scbCount]"

.TimerNotSema:                           ; CODE XREF: TimerInterrupt+40↑j
                mov     byte [byte_298F], 0
                les     bx, dword [busyStack+2Eh]
                mov     word [es:bx], 0FDh
                call    DecTimedProcesses
                ;cmp     di, 0FFFFh
                db      81h, 0FFh, 0FFh, 0FFh               ;hack for "cmp di, 0FFFFh"
                jnz     short .TimerIncCount
                mov     di, ds
                jmp     short .TimerIncCount
; ---------------------------------------------------------------------------

.TimerDone:                              ; CODE XREF: TimerInterrupt+1C↑j
                                        ; TimerInterrupt+20↑j
                ;cmp     di, 0FFFFh
                db      81h, 0FFh, 0FFh, 0FFh               ;hack for "cmp di, 0FFFFh"

                jz      short .TimerReturn
                push    di
                call    SEG_MAIN:Reschedule

.TimerReturn:                            ; CODE XREF: TimerInterrupt+6A↑j
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
;TimerInterrupt  endp

; =============== S U B R O U T I N E =======================================

; Attributes: noreturn

;LoopProc        proc near               ; DATA XREF: initMultitasking+A0↓o
LoopProc:
                sti
                jmp     short LoopProc
;LoopProc        endp

; =============== S U B R O U T I N E =======================================


;initMultitasking proc far
initMultitasking:

                push    ds
                mov     ds, [cs:DataFrame1]
                ;assume ds:CCPROM_RAM
                push    bp
                mov     ax, 30h ; '0'
                mov     [pFontTableOff], ax
                mov     ax, SEG_FONT_ROM
                mov     [pFontTableSeg], ax
                mov     [bubbleSemaphore], word 2C8h
                push    ds
                mov     ax, OsProcessQ
                push    ax
                mov     al, 0
                push    ax
                mov     ax, 82
                push    ax
                call    SEG_MAIN:OsInitQCB
                push    ds
                mov     ax, osSemaQ
                push    ax
                mov     al, 0
                push    ax
                mov     ax, 16
                push    ax
                call    SEG_MAIN:OsInitQCB
                call    SEG_MAIN:InitMemMgr
                mov     ax, 2BEh
                mov     [OsCurrentPid], ax
                mov     es, ax
                ;assume es:nothing
                mov     bx, word busyStack
                add     bx, 300
                sub     bx, 14
                ;mov     [bx+RegTableType.regIp], offset osDoBoot
                mov     word [bx+08h], osDoBoot             ;must be "mov [bx+RegTableType.regIp], offset osDoBoot"
                ;mov     [bx+RegTableType.regCs], segOSboot
                mov     word [bx+0Ah], SEG_OSBOOT           ;must be "mov [bx+RegTableType.regCs], segOSboot"
                ;mov     [bx+RegTableType.regDs], ds
                mov     word [bx+04h], ds                   ;must be "mov [bx+RegTableType.regDs], ds"
                ;mov     [bx+RegTableType.regFl], 0F246h
                mov     word [bx+0Ch], 0F246h               ;must be "mov [bx+RegTableType.regFl], 0F246h"
                
                mov     [busyStackOff], bx
                mov     word [busyStackSeg], ds
                ;mov     [es:pcbStackSeg], ds
                mov     word [es:1Eh], ds                   ;must be ";mov [es:pcbStackSeg], ds"
                ;mov     es:pcbStackOff], bx
                mov     [es:1Ch], bx                        ;must be "mov [es:pcbStackOff], bx"
                ;mov     [es:pcbPriority], 0FEh
                mov     byte [es:10h], 0FEh                 ;must be "mov [es:pcbPriority], 0FEh"
                push    es
                call    SEG_MAIN:CpCreateProcess
                mov     ax, 1FC0h
                mov     [loopPid], ax
                mov     es, ax
                ;assume es:nothing
                push    es
        {rmsrc} xor     di, di
                mov     cx, 52h ; 'R'
                mov     al, 0
                cld
                rep stosb
                mov     bx, 320h
                sub     bx, 0Eh
                mov     ax, 1FC0h
                mov     es, ax
                ;mov     [es:bx+RegTableType.regIp], offset LoopProc
                mov     word [es:bx+08h], LoopProc              ;must be "mov [es:bx+RegTableType.regIp], offset LoopProc"
                ;mov     [es:bx+RegTableType.regCs], SEG_MAIN
                mov     word [es:bx+0Ah], SEG_MAIN              ;must be "mov [es:bx+RegTableType.regCs], SEG_MAIN"
                ;mov     [es:bx+RegTableType.regDs], ds
                mov     word [es:bx+04h], ds                    ;must be "mov [es:bx+RegTableType.regDs], ds"
                ;mov     [es:bx+RegTableType.regFl], 0F246h
                mov     word [es:bx+0Ch], 0F246h                ;must be "mov [es:bx+RegTableType.regFl], 0F246h"
                pop     es
                ;assume es:nothing
                ;mov     word [es:PcbType.pcbStackSeg], 1FC0h
                mov     word [es:1Eh], 1FC0h                    ;must be "mov word [es:PcbType.pcbStackSeg], 1FC0h"
                ;mov     es:PcbType.pcbStackOff, bx
                mov     [es:1Ch], bx                            ;must be "mov [es:PcbType.pcbStackOff], bx"
                ;mov     byte [es:PcbType.pcbPriority], 0FFh
                mov     byte [es:10h], 0FFh                     ;must be "mov byte [es:PcbType.pcbPriority], 0FFh"
                push    es
                call    SEG_MAIN:CpCreateProcess
                mov     ax, SEG_MAIN
                mov     bx, 482h
                mov     es, [OsCurrentPid]
                ;mov     [es:PcbType.pcbPLoadTable], bx
                mov     [es:32h], bx                            ;must be "mov es:PcbType.pcbPLoadTable], bx"
                mov     [es:34h], ax                            ; MOV WORD PTR ES:pcbPLoadTable+2, AX
                mov     es, [loopPid]
                ;mov     [es:PcbType.pcbPLoadTable], bx
                mov     [es:32h], bx                            ;must be "mov [es:PcbType.pcbPLoadTable], bx"
                mov     [es:34h], ax                            ; MOV WORD PTR ES:pcbPLoadTable+2, AX
                call    SEG_FPU:initFPU
                mov     ax, 1
                push    ax              ; mode
                call    SEG_MAIN:CpSystemTick
                mov     ax, 0FFFEh
                push    ax
                call    SEG_MAIN:Reschedule
                pop     bp
                pop     ds
                ;assume ds:nothing
                retf
;initMultitasking endp

 


end match
