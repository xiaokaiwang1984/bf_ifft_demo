.PHONY: clean IPs platform aie hw_emu hw

all:cosim

cosim:IPs platform aie barem hw_emu

pdi:IPs platform aie barem hw

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
	
hw:
	make -C hw
	



clean:
	make clean -C IPs
	make clean -C platform
	make clean -C hw_emu
	make clean -C src_barem
	make clean -C src_aie
	make clean -C hw
