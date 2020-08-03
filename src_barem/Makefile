
main.elf:main.cpp platform.cpp
	aarch64-none-elf-gcc -I../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include -I. \
	-I$(CARDANO_ROOT)/include \
	-I../src_aie/ \
	-I../src_aie/inc/ \
	-g -c -D__PS_BARE_METAL__ -D__PS_ENABLE_AIE__ -std=c++11 -o main.o ./main.cpp
	
	aarch64-none-elf-gcc -I../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include -I. \
	-I$(CARDANO_ROOT)/include \
	-I../src_aie/ \
	-I../src_aie/inc/ \
	-g -c -D__PS_BARE_METAL__ -D__PS_ENABLE_AIE__ -std=c++11 -o aie_control.o ../src_aie/Work/ps/c_rts/aie_control.cpp
	
	aarch64-none-elf-gcc -I../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include -I. \
	-I$(CARDANO_ROOT)/include \
	-I../src_aie/ \
	-I../src_aie/inc/ \
	-g -c -D__PS_BARE_METAL__ -D__PS_ENABLE_AIE__ -std=c++11 -o platform.o ./platform.cpp
	
	
	aarch64-none-elf-gcc -o main.elf *.o -g -mcpu=cortex-a72 -Wl,-T -Wl,./lscript.ld \
	-L../platform/sw/bf_ifft_v1_0/standalone_domain/bsplib/lib \
	-L$(CARDANO_ROOT)/lib/aarchnone64.o \
	-lcardano_api -Wl,--start-group,-lxil,-lgcc,-lc,-lstdc++,--end-group 

all:main.elf
	cp main.elf ../images

clean:
	rm -rf *.o main.elf
	