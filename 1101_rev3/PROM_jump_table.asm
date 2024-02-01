match FALSE, _PROM_jump_table_asm
display 'Including PROM jump table segment', 10

_PROM_jump_table_asm equ TRUE

; ===========================================================================
; segment SEG_PROM_JUMP_TABLE
; some information come from following files:
; /CCPROM/CPPROM.PUB
; /CCPROM/JUMPEXT.ASM
; /CCPROM/JUMPPUB.ASM
;
; all jumps are FAR

org 0

;FIXME: generate 0x00 in beginning to fill segment correctly
repeat 3        ; 3 empty bytes to aling
    db 0
end repeat

repeat 6        ; there are free space for 6 jump entries/instructions
    repeat 5    ; each jump is 5 byte long
        db 0
    end repeat
end repeat

; ===========================================================================
j_TimerInterrupt:
                jmp     SEG_MAIN:TimerInterrupt
; ===========================================================================
j_CnoLineOut:
                jmp     SEG_MAIN:CnoLineOut
; ===========================================================================
j_CnoCharOut:
                jmp     SEG_MAIN:CnoCharOut
; ===========================================================================
j_TellMessageWaiters:
                jmp     SEG_MAIN:TellMessageWaiters
; ===========================================================================
j_CpAddressOf:
                jmp     SEG_MAIN:CpAddressOf
; ===========================================================================
j_BubbleDriver:
                jmp     SEG_BUBBLE:bubbleDrvService
; ===========================================================================
j_GpibDriver:
                jmp     SEG_CCPROM_RAM:gpibJump
; ===========================================================================
j_OsDskDriver:
                jmp     SEG_OS_DRIVER:OsDskDriver
; ===========================================================================
j_CpSetKeyHandler:

                jmp     SEG_MAIN:CpSetKeyHandler
; ===========================================================================
j_CpSetWatchDogHandler:
                jmp     SEG_MAIN:CpSetWatchDogHandler
; ===========================================================================
j_CpCatchAll:
                jmp     SEG_MAIN:CpCatchAll
; ===========================================================================
j_CpEnableInterrupt:
                jmp     SEG_MAIN:CpEnableInterrupt
; ===========================================================================
j_CpDisableInterrupt:
                jmp     SEG_MAIN:CpDisableInterrupt
; ===========================================================================
j_CpSetInterrupt:
                jmp     SEG_MAIN:CpSetInterrupt
; ===========================================================================
j_CpEndOfInterrupt:
                jmp     SEG_MAIN:CpEndOfInterrupt
; ===========================================================================
j_CpSystemTick:
                jmp     SEG_MAIN:CpSystemTick
; ===========================================================================
j_CpRealTimeClock:
                jmp     SEG_MAIN:CpRealTimeClock
; ===========================================================================
j_CpMachineID:
                jmp     SEG_MAIN:CpMachineID
; ===========================================================================
j_OsNewQElement:
                jmp     SEG_MAIN:OsNewQElement
; ===========================================================================
j_OsInitQCB:
                jmp     SEG_MAIN:OsInitQCB
; ===========================================================================
j_OsElementChecksum:
                jmp     SEG_MAIN:OsElementChecksum
; ===========================================================================
j_OsVerifyChecksum:
                jmp     SEG_MAIN:OsVerifyChecksum
; ===========================================================================
j_OsInsertIntoQ:
                jmp     SEG_MAIN:OsInsertIntoQ
; ===========================================================================
j_OsRemoveFromQ:
                jmp     SEG_MAIN:OsRemoveFromQ
; ===========================================================================
j_OsReplaceInQ:
                jmp     SEG_MAIN:OsReplaceInQ
; ===========================================================================
j_OsElementInQ:
                jmp     SEG_MAIN:OsElementInQ
; ===========================================================================
j_OsSearchInQ:
                jmp     SEG_MAIN:OsSearchInQ
; ===========================================================================
j_CpFree:
                jmp     SEG_MAIN:CpFree
; ===========================================================================
j_CpGetSize:
                jmp     SEG_MAIN:CpGetSize
; ===========================================================================
j_IntAllocate:
                jmp     SEG_MAIN:IntAllocate
; ===========================================================================
j_CpAllocate:
                jmp     SEG_MAIN:CpAllocate
; ===========================================================================
j_CpMemInit:
                jmp     SEG_MAIN:CpMemInit
; ===========================================================================
j_CpFreeTaskMem:
                jmp     SEG_MAIN:CpFreeTaskMem
; ===========================================================================
j_CpGetMemStatus:
                jmp     SEG_MAIN:CpGetMemStatus
; ===========================================================================
j_CpWhoAmI:
                jmp     SEG_MAIN:CpWhoAmI
; ===========================================================================
j_Reschedule:
                jmp     SEG_MAIN:Reschedule
; ===========================================================================
j_CpSignal:
                jmp     SEG_MAIN:CpSignal
; ===========================================================================
j_CpWait:
                jmp     SEG_MAIN:CpWait
; ===========================================================================
j_CpSend:
                jmp     SEG_MAIN:CpSend
; ===========================================================================
j_CpReceive:
                jmp     SEG_MAIN:CpReceive
; ===========================================================================
j_CpCreateProcess:
                jmp     SEG_MAIN:CpCreateProcess
; ===========================================================================
j_CpDeleteProcess:
                jmp     SEG_MAIN:CpDeleteProcess
; ===========================================================================
j_CpDelay:
                jmp     SEG_MAIN:CpDelay
; ===========================================================================
j_CpSetPriority:
                jmp     SEG_MAIN:CpSetPriority
; ===========================================================================
j_CpCreateSemaphore:
                jmp     SEG_MAIN:CpCreateSemaphore
; ===========================================================================
j_CpDeleteSemaphore:
                jmp     SEG_MAIN:CpDeleteSemaphore
; ===========================================================================
j_Upper:
                jmp     SEG_UNKOWN:Upper
; ===========================================================================
j_CompareChars:
                jmp     SEG_UNKOWN:CompareChars
; ===========================================================================
j_MakeChecksum:
                jmp     SEG_MAIN:MakeChecksum
; ===========================================================================
j_SetException:
                jmp     SEG_MAIN:SetException
; ===========================================================================
j_Exception:
                jmp     SEG_MAIN:Exception

end match
