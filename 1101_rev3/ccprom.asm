use16
use 8087
format binary

; fasmg specifics for some asm instructions
include 'x86-2/x86-2.inc'

; some constants for segment numbers, cuntion parametrs eytc
include 'constants.inc'

; some pointers to CCROM Data RAM are
include 'RAM_stuff.inc'

;=======================================================================
; CCPROM binary starts here
;=======================================================================
; included files must be in correct order
include 'fpu_init.asm'
include 'CCPROM_Main.asm'
include 'String_utils.asm'
include 'LQ_DWORD_MUL.asm'
include 'Bubble_drv.asm'
include 'OS_boot_process.asm'
include 'OS_disk_drv.asm'
include 'ROM_font.inc'

; empty space in PROM
org 0h
repeat 3A0h - $
    db 0
end repeat   

include 'PROM_jump_table.asm'
include 'reset_vector.asm'
