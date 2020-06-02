
main.elf:main.cpp platform.cpp
	aarch64-none-elf-gcc -I../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include -I. -c -std=c++11 -o main.o main.cpp; \
	aarch64-none-elf-gcc -I../platform/sw/bf_ifft_v1_0/standalone_domain/bspinclude/include -I. -c -std=c++11 -o platform.o platform.cpp; \
	aarch64-none-elf-gcc *.o -mcpu=cortex-a72 -Wl,-T -Wl,./lscript.ld -L../platform/sw/bf_ifft_v1_0/standalone_domain/bsplib/lib \
-Wl,--start-group,-lxil,-lgcc,-lc,-lstdc++,--end-group -o main.elf

all:main.elf
	cp main.elf ../images

clean:
	rm *.o
	rm main.elf
	