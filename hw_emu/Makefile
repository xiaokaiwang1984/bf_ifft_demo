#VPP_FLAGS=--save-temps --verbose  --user_ip_repo_paths ${USER_IPREPO} --xp param:hw_emu.enableDebugWaveform=true --vivado.prop fileset.sim_1.xsim.simulate.runtime=100us --remote_ip_cache ./ip_cache
#ROOTFS=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
#IMAGE=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/Image
#ROOTFS=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
#IMAGE=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/Image



.PHONY:clean sim pack

all:bf_ifft.xclbin pack sim


pdi:
	v++ -l -t hw_emu ../src_aie/libsdf.a -o bf_ifft.xclbin --save-temps -g \
	--user_ip_repo_paths ../IPs/iprepo \
	--platform ../platform/bf_ifft_v1_0.xpfm \
	--config ./system.cfg \
	

bf_ifft.xclbin:
	v++ -l -t hw_emu ../src_aie/libsdf.a -o bf_ifft.xclbin --save-temps -g \
	--user_ip_repo_paths ../IPs/iprepo \
	--platform ../platform/bf_ifft_v1_0.xpfm \
	--config ./system.cfg \


	
pack:bf_ifft.xclbin
	v++ -p -t hw_emu  bf_ifft.xclbin ../src_aie/libsdf.a \
	-f ../platform/bf_ifft_v1_0.xpfm \
	--package.out_dir ./ \
	--package.domain aiengine \
	--package.boot_mode sd \
	--package.image_format fat32 \
	--package.ps_elf ../src_barem/main.elf,a72-0
	
	
sim:
	./launch_hw_emu.sh -g

	

clean:
	rm -rf *xclbin* *.log BOOT* *.xsa *.bin _x sd_card sim emu_qemu_scripts ipcache libsdf boot_* launch* qemu_* hw.* pmc_* sd_* v++*

