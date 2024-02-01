match FALSE, _reset_vector_asm
display 'Including Reset vector segment', 10

_reset_vector_asm equ TRUE


; ===========================================================================
; segment SEG_RESET
; point to reset address for 8086 CPU
; CPU jump here after hardware reset
; segment lenght: 0x10 bytes
org 0
j_BiosEntryPoint:
                ;jmp     SEG_MAIN:CompassPromStart
                jmp     SEG_EXTRA:extraInit
; ---------------------------------------------------------------------------
; just fill remaining bytes with 0x00
repeat 10h - $
    db 0
end repeat   


end match
