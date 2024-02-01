match FALSE, _fpu_init_asm
display 'Including FPU init segment', 10

_fpu_init_asm equ TRUE

;segment SEG_FPUINIT
org 0
initFPU:
    nop
    fninit
    retf

repeat 16 - $       ; fill/aling to segment size
    db 0
end repeat   


end match
