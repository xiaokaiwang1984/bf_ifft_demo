.PHONY: clean IPs platform src_aie src_barem src_linux hw_emu boot_barem build_linux 

all:cosim

cosim:IPs platform src_aie src_barem hw_emu

hw_barem:IPs platform src_aie src_barem xclbin boot_barem

hw_linux:IPs platform src_aie xclbin build_linux src_linux boot_linux



IPs:
	make -C IPs

platform:
	make -C platform
	
src_aie:
	make -C src_aie	
	
src_barem:
	make -C src_barem
	
src_linux:
	make -C src_linux
	
build_linux:
	make -C build_linux

hw_emu:
	make -C hw_emu
	
xclbin:
	make -C hw xclbin
	
boot_barem:
	make -C hw boot_barem 
	
boot_linux:
	make -C hw boot_linux 
	



clean:
	make clean -C IPs
	make clean -C platform
	make clean -C hw_emu
	make clean -C src_barem
	make clean -C src_aie
	make clean -C src_linux
	make clean -C hw
	make clean -C build_linux
