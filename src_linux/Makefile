# #########################################################################
#            Makefile used for AIE linux application 
#				 
# #########################################################################


BOARD_IP    :=192.168.1.188
CC			:= aarch64-linux-gnu-g++
AIE_APP		:= bf_ifft_test.cpp 
AIE_APP_EXE	:= bf_ifft_test.exe
PLAT_INC    :=../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include
CFLAGS		:= -O3 -DPS_INIT_AIE -DPS_ENABLE_AIE -DXAIE_DEBUG


#DIR_PFM := /group/techsup/robiny/vck190/Vitis_Embedded_Platform_Source/Xilinx_Official_Platforms/xilinx_vck190_base_202010_1/petalinux
DIR_PFM 		:= ../build_linux/vck190_linux
PFM_SYSROOT     := ${DIR_PFM}/images/linux/sdk/sysroots/aarch64-xilinx-linux/
SYSROOT_INCLUDE := ${PFM_SYSROOT}/usr/include
SYSROOT_LIB     := ${PFM_SYSROOT}/usr/lib
AIE_INCLUDE     := $(PFM_SYSROOT)/usr/include/xaiengine
AIE_LINKER      := $(PFM_SYSROOT)/lib
LIB             := $(PFM_SYSROOT)

XRT_INCLUDE     := $(PFM_SYSROOT)/usr/include/xrt



all:bf_ifft_test.exe



bf_ifft_test.exe:bf_ifft_test.cpp
	$(CC) $(CFLAGS) -DXRT_LD_AIE -I$(PLAT_INC) $(AIE_APP) -o $(AIE_APP_EXE) --sysroot=$(PFM_SYSROOT) -I$(SYSROOT_INCLUDE) -I$(CARDANO_ROOT)/include/ -I$(AIE_INCLUDE) -I$(XRT_INCLUDE) $(PINV_INCLUDE_EXE) -Xlinker -rpath-link=$(PFM_SYSROOT)  -L$(PFM_SYSROOT)/../ -lxaiengine -lmetal -lopen_amp -lsysfs -lxrt_coreutil -lxrt_core -L$(AIE_LINKER) -Wl,-rpath,$(LIB),--warn-unresolved-symbol

send:${AIE_APP_EXE}
	scp -r bf_ifft_test.exe ./data root@${BOARD_IP}:/home/root
	
clean:
	rm -rf *.exe *.o
	

