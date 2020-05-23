.PHONY:clea

all:compile



compile:
	aiecompiler --dataflow -v --target=aiesim -full-program=true -genArchive=true -include=./ -include=./kernels -include=./inc ./test_dl8a.cpp --device=VC1902.json -workdir=Work -heapsize=2048 -Xmapper="Disable Floorplanning" --new-placer=true --new-router=true -use-phy-shim=true -pl-freq=491 -pl-register-threshold=125 --test-iterations=-1
	
clean:
	rm -rf Work xnwOut
	rm NOC_Power.xpe
	