match FALSE, _RAM_stuff_inc
display 'Including RAM Data!', 10

_RAM_stuff_inc equ TRUE


; =============== D A T A  s t r u c t u r e ===========================
; CCPROM DATA memory
keyboardDataPort    equ 0
keyboardCommandPort equ 2

keyboardCommandLow  equ 0Ch

keyHandlerOff   equ 0
keyHandlerSeg   equ 2

watchDogHandlerOff equ 4
watchDogHandlerSeg equ 6

keyboardDelayRepeat equ 8
keyboardStatusKey   equ 0Ah
byte_298F           equ 0Fh
dummyError      equ 10h

busyStack       equ 12h
OsProcessQ      equ 13Eh
osSemaQ         equ 147h
OsCurrentPid    equ 150h
loopPid         equ 152h
busyStackOff    equ 155h
busyStackSeg    equ 157h
sysCounter      equ 159h

timedProcesses  equ 15Dh

gpibJump        equ 15Fh
gpibOff         equ 160h
gpibSeg         equ 162h
pFontTableOff   equ 164h
pFontTableSeg   equ 166h
nextpidToSchedule   equ 168h
bubbleSemaphore equ 16Ah

OsFreeMemQ      equ 170h
OsAllocMemQ     equ 179h
dummyError_0    equ 182h

RATBL           equ 190h

unk_2B40        equ 1C0h

word_2B60       equ 1E0h
dword_2B62      equ 1E2h
gpError         equ 1E6h
gtimelimit      equ 1EAh
byte_2B6C       equ 1ECh
byte_2B6E       equ 1EEh
byte_2B6F       equ 1EFh
byte_2B70       equ 1F0h
byte_2B71       equ 1F1h
word_2B72       equ 1F2h
word_2B74       equ 1F4h
word_2B76       equ 1F6h

gsid             equ 23Ch
word_2BBE       equ 23Eh
dmaHackCode     equ 240h

ROMfontOffset   equ 259h
ROMfontSegment  equ 25Bh

pcbPriority     equ 270h
pcbStackOff     equ 27Ch
pcbStackSeg     equ 27Eh

word_2C48       equ 2C8h

;OS boot data segment
bootLoaderOffset        equ 0
bootLoaderSegment       equ 2

osKeyHandlerOffset      equ 40h
osKeyHandlerSeg         equ 42h

byte_2CF7       equ 057h

end match
