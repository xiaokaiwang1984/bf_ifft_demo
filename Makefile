.PHONY: clean IPs platform aie hw_emu

all:IPs platform aie src_barem hw_emu

IPs:
	make -C IPs

platform:
	make -C platform
	
aie:
	make -C src_aie	
	
barem:
	make -C src_barem

hw_emu:
	make -C hw_emu
	



clean:
	make clean -C IPs
	make clean -C platform
	make clean -C hw_emu
	make clean -C src_barem
	make clean -C src_aie
