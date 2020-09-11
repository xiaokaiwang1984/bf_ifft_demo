PFM_VER = v1_0

.PHONY: clean IPs platform src_aie src_barem src_linux hw_emu boot_barem build_linux 

all:cosim

cosim:IPs platform src_aie src_barem hw_emu

hw_barem:IPs platform src_aie src_barem xclbin boot_barem

hw_linux:IPs platform src_aie xclbin build_linux src_linux boot_linux



IPs:
	make -C IPs

platform:
	make -C platform ${PFM_VER}
	
src_aie:
	make -C src_aie	
	
src_barem:
	make -C src_barem PFM_VER=${PFM_VER}
	
src_linux:
	make -C src_linux PFM_VER=${PFM_VER}
	
build_linux:
	make -C build_linux PFM_VER=${PFM_VER}

hw_emu:
	make -C hw_emu
	
xclbin:
	make -C hw xclbin PFM_VER=${PFM_VER}
	
boot_barem:
	make -C hw boot_barem PFM_VER=${PFM_VER}
	
boot_linux:
	make -C hw boot_linux PFM_VER=${PFM_VER}
	
tftp:
ifeq ($(PFM_VER),v1_0)
	cp build_linux/vck190_linux/images/linux/BOOT.BIN /var/lib/tftpboot/bf_ifft/
	cp build_linux/vck190_linux/images/linux/image.ub /var/lib/tftpboot/bf_ifft/
endif

ifeq ($(PFM_VER),v2_0)
	cp build_linux/vck190_linux/images/linux/BOOT.BIN /var/lib/tftpboot/bf_ifft_dfx/
	cp build_linux/vck190_linux/images/linux/image.ub /var/lib/tftpboot/bf_ifft_dfx/
	cp hw/_x/link/int/partial.pdi /var/lib/tftpboot/bf_ifft_dfx/
endif



clean:
	make clean -C IPs
	make clean -C platform
	make clean -C hw_emu
	make clean -C src_barem
	make clean -C src_aie
	make clean -C src_linux
	make clean -C hw
	make clean -C build_linux
