VPP_FLAGS=--save-temps --verbose  --user_ip_repo_paths ${USER_IPREPO} --xp param:hw_emu.enableDebugWaveform=true --vivado.prop fileset.sim_1.xsim.simulate.runtime=100us --remote_ip_cache ./ip_cache
ROOTFS=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
IMAGE=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/Image
#ROOTFS=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
#IMAGE=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/Image



.PHONY:clean

all:sim

bf_ifft.xclbin:
	v++ -l --platform ../platform/bf_ifft_v1_0.xpfm ../src_aie/Work/temp/test_dl8a.o -t hw_emu --config ./system.cfg -g -o bf_ifft.xclbin
	
sim:bf_ifft.xclbin
	v++ -p -t hw_emu -f ../platform/bf_ifft_v1_0.xpfm --package.rootfs=${ROOTFS} --package.image_format=ext4 --package.boot_mode=sd --package.kernel_image=${IMAGE} --package.sd_file ../src_barem/main.elf bf_ifft.xclbin ../src_aie/libsdf.a
	./launch_hw_emu.sh -noc-ddr-shared-mem qemu-memory-_ddr@0x00000000 -add-env VITIS_LAUNCH_WAVEFORM_BATCH=1 -graphic-xsim
	

clean:
	rm *.xclbin.*
	rm *.log BOOT* *.xsa *.bin
	rm -rf _x sd_card sim

