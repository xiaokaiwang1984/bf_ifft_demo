#VPP_FLAGS=--save-temps --verbose  --user_ip_repo_paths ${USER_IPREPO} --xp param:hw_emu.enableDebugWaveform=true --vivado.prop fileset.sim_1.xsim.simulate.runtime=100us --remote_ip_cache ./ip_cache
ROOTFS=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
IMAGE=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/Image
#ROOTFS=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
#IMAGE=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/Image



.PHONY:clean bf_ifft_hw.xclbin boot_linux boot_barem

xclbin:bf_ifft_hw.xclbin


bf_ifft_hw.xclbin:
	v++ -l -t hw ../src_aie/libsdf.a -o bf_ifft_hw.xclbin --save-temps -g \
	--user_ip_repo_paths ../IPs/iprepo \
	--platform ../platform/bf_ifft_v1_0.xpfm \
	--config ./system.cfg \
	
boot_barem:
	v++ -p -t hw bf_ifft_hw.xclbin ../src_aie/libsdf.a \
	-f ../platform/bf_ifft_v1_0.xpfm \
	--package.out_dir ./boot_barem \
	--package.domain aiengine \
	--package.boot_mode sd \
	--package.image_format fat32 \
	--package.ps_elf ../src_barem/main.elf,a72-0
	
	
boot_linux:
	v++ -p -t hw bf_ifft_hw.xclbin ../src_aie/libsdf.a \
	-f ../platform/bf_ifft_v1_0.xpfm \
	--package.out_dir ./boot_linux \
	--package.rootfs ../build_linux/vck190_linux/images/linux/rootfs.cpio.gz.u-boot \
	--package.kernel_image ../build_linux/vck190_linux/images/linux/Image \
	--package.bl31_elf ../build_linux/vck190_linux/images/linux/bl31.elf \
	--package.uboot ../build_linux/vck190_linux/images/linux/u-boot.elf \
	--package.dtb ../build_linux/vck190_linux/images/linux/system.dtb \
	--package.boot_mode=sd \
	--package.image_format=fat32 
	
	

	

clean:
	rm -rf *xclbin* *.log BOOT* *.xsa *.bin _x sd_card sim emu_qemu_scripts libsdf boot_* launch* qemu_* hw.* pmc_* sd_* v++* *.ltx vivado* .Xil

