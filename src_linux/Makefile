# #########################################################################
#			 Makefile used for AIE linux application 
#				 
# #########################################################################



BOARD_IP		:=192.168.1.10
CC				:= aarch64-linux-gnu-g++
AIE_APP			:= bf_ifft_test.cpp 
AIE_APP_CTRL	:=../src_aie/Work/ps/c_rts/aie_control.cpp
PLAT_INC		:=../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include
CFLAGS			:= -O3 -DPS_INIT_AIE -DXAIE_DEBUG


DIR_PFM			:= ../build_linux/vck190_linux
PFM_SYSROOT		:= ${DIR_PFM}/images/linux/sdk/sysroots/aarch64-xilinx-linux/
SYSROOT_INCLUDE := ${PFM_SYSROOT}/usr/include
SYSROOT_LIB		:= ${PFM_SYSROOT}/usr/lib
AIE_INCLUDE		:= $(PFM_SYSROOT)/usr/include/xaiengine
AIE_LINKER		:= $(PFM_SYSROOT)/lib
LIB				:= $(PFM_SYSROOT)
XRT_INCLUDE		:= $(PFM_SYSROOT)/usr/include/xrt


AIE_APP_CTRL	:= ../src_aie/Work/ps/c_rts/aie_control.cpp
AIE_DIR			:= ../src_aie
AIE_INC			:= $(AIE_DIR)/inc
AIE_KERNELS		:= $(AIE_DIR)/kernels



all:bf_ifft_test_xrt.exe bf_ifft_test_dut.exe

bf_ifft_test_xrt.exe:bf_ifft_test.cpp
	$(CC)  -DXRT_LD_AIE $(CFLAGS) -I$(PLAT_INC) $(AIE_APP) -o bf_ifft_test_xrt.exe \
	--sysroot=$(PFM_SYSROOT) -I$(SYSROOT_INCLUDE) -I$(CARDANO_ROOT)/include/ -I$(AIE_INCLUDE) -I$(XRT_INCLUDE) \
	-Xlinker -rpath-link=$(PFM_SYSROOT)	-L$(PFM_SYSROOT)/../ -L$(AIE_LINKER) \
	-lxaiengine -lmetal -lopen_amp -lsysfs -lxrt_coreutil -lxrt_core -Wl,-rpath,$(LIB),--warn-unresolved-symbol


bf_ifft_test_dut.exe:bf_ifft_test.cpp
	$(CC) -DDUT_LD_AIE -DPS_ENABLE_AIE $(CFLAGS) $(AIE_APP_CTRL) $(AIE_APP) -o bf_ifft_test_dut.exe \
	--sysroot=$(PFM_SYSROOT) -I$(PLAT_INC) -I$(CARDANO_ROOT)/include/ -I$(AIE_INCLUDE) -I$(AIE_DIR) -I$(AIE_INC) -I$(AIE_KERNELS)  -I$(SYSROOT_INCLUDE) -I./ \
	-Xlinker -rpath-link=$(PFM_SYSROOT) -L$(CARDANO_ROOT)/lib/aarch64.o -L$(AIE_LINKER) -L$(PFM_SYSROOT)/../ \
	-lxaiengine -lmetal -lopen_amp -lsysfs -lcardano_api -Wl,-rpath,$(LIB),--warn-unresolved-symbols



send:bf_ifft_test_xrt.exe bf_ifft_test_dut.exe
	@sed -i -E '/${BOARD_IP}/d' ~/.ssh/known_hosts
	./send2board root@${BOARD_IP}:/home/root/

	
clean:
	rm -rf *.exe *.o
	

