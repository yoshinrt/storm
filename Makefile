SIMOPT = +define+OUTPUT_LOG

ifdef WAVE
	SIMOPT	+= +define+VCD_WAVE
endif

%.v: %.def.v
	vpp/vpp.pl $<

storm_test.v: storm.def.v storm.h

%_text.obj %_data.obj: %.asm
	sgcc/stormas.pl -s $<

%.sim: storm_test.v prog/%_text.obj prog/%_data.obj
	rm -f text.obj data.obj
	ln -s prog/$*_text.obj text.obj
	ln -s prog/$*_data.obj data.obj
	cver $(SIMOPT) $<

%.emu:
	sgcc/stormas.pl -e prog/$*.asm

clean:
	rm -f storm_test.list storm_test.v *.log *.list *.obj *.vcd
