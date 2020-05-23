.PHONY: clean build

all: ipgen build 


build:
	make all -C ./build

ipgen:
	make all -C ../IPs
	
clean:
	make clean -C ./build
	rm *.xpfm
	rm -rf hw sw
	
