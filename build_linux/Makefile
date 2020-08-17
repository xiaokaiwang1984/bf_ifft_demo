PATH_TO_BSP := /opt/petalinux/2020.2_SAM
BSP := xilinx-vck190-es1-v2020.2_SAM-final.bsp

ifneq ($(BSP_FILE), $(wildcard $(BSP_FILE)))
BSP_FILE := $(PATH_TO_BSP)/$(BSP)
endif

PETALINUX_DIR := vck190_linux

.PHONY: all clean copy_xsa petalinux

all: copy_xsa petalinux

copy_xsa:
	cp -f ../hw/bf_ifft_hw.xsa ./
	
petalinux:vck190_linux/images
	
vck190_linux/images :
	@echo "using BSP file: $(BSP_FILE)"
	petalinux-create -t project -s $(BSP_FILE) -n $(PETALINUX_DIR)
	petalinux-config -p $(PETALINUX_DIR) --get-hw-description=. --silentconfig
# update_yocto_config enable state-cache
	@sed -i -E 's/CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL="/CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL="\/opt\/petalinux\/2020.2_SAM\/sstate_aarch64_2020.2_SAM\/aarch64/' $(PETALINUX_DIR)/project-spec/configs/config	
	@sed -i -E 's/CONFIG_PRE_MIRROR_URL=/#CONFIG_PRE_MIRROR_URL=/g' $(PETALINUX_DIR)/project-spec/configs/config
	@sed -i -E '/CONFIG_PRE_MIRROR_URL=/a CONFIG_PRE_MIRROR_URL="file:///opt/petalinux/2020.2_SAM/downloads"' $(PETALINUX_DIR)/project-spec/configs/config
	
# update_rootfs_config
	@sed -i -E 's/.*CONFIG_libmetal.+/CONFIG_libmetal=y/' $(PETALINUX_DIR)/project-spec/configs/rootfs_config
	@sed -i -E 's/.*CONFIG_libsysfs.+/CONFIG_libsysfs=y/' $(PETALINUX_DIR)/project-spec/configs/rootfs_config
	@sed -i -E 's/.*CONFIG_open-amp.+/CONFIG_open-amp=y/' $(PETALINUX_DIR)/project-spec/configs/rootfs_config
	@sed -i -E 's/.*CONFIG_ai-engine-driver.+/CONFIG_ai-engine-driver=y/' $(PETALINUX_DIR)/project-spec/configs/rootfs_config	
	
# update_dtsi
	@cp -f ./system-user.dtsi $(PETALINUX_DIR)/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi	
	
# copy_xrt
	@cp -rf recipes-xrt $(PETALINUX_DIR)/project-spec/meta-user/
	
# building
	petalinux-config -p $(PETALINUX_DIR) -c rootfs --silentconfig 
	petalinux-config -p $(PETALINUX_DIR) --silentconfig
	petalinux-build -p $(PETALINUX_DIR)
	petalinux-build -p $(PETALINUX_DIR) --sdk
	cd $(PETALINUX_DIR) && petalinux-package --sysroot
	cd $(PETALINUX_DIR) && petalinux-package --boot --u-boot
	
clean:
	rm -rf $(PETALINUX_DIR) *.xsa

