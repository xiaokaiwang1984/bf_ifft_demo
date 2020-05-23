.PHONY: clean hw 

all: ipgen hw 


hw:
	make all -C ./hw

ipgen:
	make all -C ../IPs
	
clean:
	make clean -C ./hw
	make clean -C ../IPs