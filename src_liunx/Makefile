# #########################################################################
#            Makefile used for AIE linux application 
#				 
# #########################################################################


BOARD_IP    :=192.168.1.188
CC			:= aarch64-linux-gnu-g++
AIE_APP		:= bf_ifft_test.cpp 
AIE_APP_EXE	:= bf_ifft_test.exe
PLAT_INC    :=../gen_pdi/bf_ifft_plat/sw/bf_ifft_plat/standalone_domain/bspinclude/include
CFLAGS		:= -O3 -DPS_INIT_AIE -DPS_ENABLE_AIE -DXAIE_DEBUG



all:
	$(CC) $(CFLAGS) $(AIE_APP) -o $(AIE_APP_EXE) -I$(PLAT_INC) -I./ -Wl,-rpath,$(LIB),--warn-unresolved-symbols


send:${AIE_APP_EXE}
	scp -r bf_ifft_test.exe ./data root@${BOARD_IP}:/home/root
	
clean:
	rm *.exe
	rm *.o
	

