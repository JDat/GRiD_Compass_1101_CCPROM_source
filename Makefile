ASM = ./fasmg
#ASM_PARAMS =



#all: ccprom.bin
ccprom.bin: ccprom.asm
#	rm ccprom.bin
	$(ASM) $^ $@
#fpuinit.bin: fpuinit.asm
#	$(ASM) -o $@ $^ $(ASM_PARAMS)
#	$(ASM) $^ $@

#main.bin: main.asm
#	$(ASM) -o $@ $^ $(ASM_PARAMS)
#	$(ASM) $^ $@

#ccprom.bin: ccprom.asm
#ccprom.bin: fpuinit.bin main.bin
#	cat fpuinit.bin main.bin > $@
#	mv main.bin ccprom.bin
#	$(ASM) $^ $@

clean:
	rm ccprom.bin

