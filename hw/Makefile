#VPP_FLAGS=--save-temps --verbose  --user_ip_repo_paths ${USER_IPREPO} --xp param:hw_emu.enableDebugWaveform=true --vivado.prop fileset.sim_1.xsim.simulate.runtime=100us --remote_ip_cache ./ip_cache
ROOTFS=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
IMAGE=/opt/xilinx/platforms/sw/versal/xilinx-versal-common-v2020.1/Image
#ROOTFS=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/rootfs.ext4
#IMAGE=/proj/xbuilds/2020.1_daily_latest/internal_platforms/sw/versal/xilinx-versal-common-v2020.1/Image

PFM_VER = v1_0

.PHONY:clean bf_ifft_hw.xclbin boot_linux boot_barem

xclbin:bf_ifft_hw_${PFM_VER}.xclbin

##--to_step=vpl.update_bd
##--to_step vpl.impl.opt_design
##--to_step vpl.impl.place_design
#-R2 generate DCPs
##--reuse_impl ./_x/link/vivado/route4.dcp

bf_ifft_hw_${PFM_VER}.xclbin:../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm ../src_aie/libsdf.a system.cfg ./axi4s_regslice_64b.xo
	v++ -l -t hw ../src_aie/libsdf.a -o bf_ifft_hw_${PFM_VER}.xclbin ./axi4s_regslice_64b.xo --save-temps -g \
	-R2 \
	--user_ip_repo_paths ../IPs/iprepo \
	--platform ../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm \
	--config ./system.cfg \
	
boot_barem:
	v++ -p -t hw bf_ifft_hw_${PFM_VER}.xclbin ../src_aie/libsdf.a \
	-f ../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm \
	--package.out_dir ./boot_barem \
	--package.domain aiengine \
	--package.boot_mode sd \
	--package.image_format fat32 \
	--package.ps_elf ../src_barem/main.elf,a72-0
	
boot_wo_barem:
	v++ -p -t hw bf_ifft_hw_${PFM_VER}.xclbin ../src_aie/libsdf.a \
	-f ../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm \
	--package.out_dir ./boot_barem \
	--package.domain aiengine \
	--package.boot_mode sd \
	--package.image_format fat32
	
	

boot_linux:xclbin_w_aie package_dut
	tar zcvf app.tgz aie_only.xclbin ../src_linux/bf_ifft_test_xrt.exe ../src_linux/data
	v++ -p -t hw bf_ifft_hw_${PFM_VER}.xclbin ../src_aie/libsdf.a \
	-f ../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm \
	--package.out_dir ./boot_linux \
	--package.rootfs ../build_linux/vck190_linux/images/linux/rootfs.cpio.gz.u-boot \
	--package.kernel_image ../build_linux/vck190_linux/images/linux/Image \
	--package.bl31_elf ../build_linux/vck190_linux/images/linux/bl31.elf \
	--package.uboot ../build_linux/vck190_linux/images/linux/u-boot.elf \
	--package.dtb ../build_linux/vck190_linux/images/linux/system.dtb \
	--package.boot_mode=sd \
	--package.image_format fat32 \
	--package.sd_file ./app.tgz 
	
xclbin_w_aie:
	v++ -s -p -t hw ../src_aie/libsdf.a \
	-f ../platform/${PFM_VER}/bf_ifft_${PFM_VER}.xpfm \
	--package.out_dir  ./ \
	--config package.cfg
	mv a.xclbin aie_only.xclbin


package_dut:
	rm -rf package package.zip
	mkdir -p package/Work/aie
	./create_work.sh
	cp -r ../src_linux/bf_ifft_test_dut.exe ./package
	cp -r ../src_aie/data ./package
	zip -r package.zip package

	

clean:
	rm -rf *xclbin* *.log BOOT* *.xsa *.bin _x sd_card sim emu_qemu_scripts libsdf boot_* launch* qemu_* hw.* pmc_* sd_* v++* *.ltx vivado* .Xil app.tgz package.zip package

