.PHONY: clean build xsa output hw/design_1.xsa

all:bf_ifft_v1_0.xpfm


hw/design_1.xsa:
	make -C hw

bf_ifft_v1_0.xpfm: hw/design_1.xsa
	xsct -nodisp -sdx ./scripts/plat_gen.tcl bf_ifft_v1_0 ./hw/design_1.xsa output
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0/sw ./
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0/bf_ifft_v1_0.xpfm ./

clean:
	make -C hw clean
	rm -rf output *.xpfm sw

