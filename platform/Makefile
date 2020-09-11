.PHONY: clean v1_0 v2_0

all:v1_0


hw/design_1.xsa:hw/run.tcl hw/bd_flat.tcl
	make -C hw design_1.xsa
	
hw/design_dfx.xsa:hw/run_dfx.tcl hw/bd_flat.tcl	
	make -C hw design_dfx.xsa

v1_0/bf_ifft_v1_0.xpfm:hw/design_1.xsa
	xsct -nodisp -sdx ./scripts/plat_gen.tcl bf_ifft_v1_0 ./hw/design_1.xsa output
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0 ./v1_0

v1_0:v1_0/bf_ifft_v1_0.xpfm


v2_0/bf_ifft_v2_0.xpfm:hw/design_dfx.xsa
	xsct -nodisp -sdx ./scripts/plat_gen.tcl bf_ifft_v2_0 ./hw/design_dfx.xsa output
	cp -r output/bf_ifft_v2_0/export/bf_ifft_v2_0 ./v2_0

v2_0:v2_0/bf_ifft_v2_0.xpfm

clean:
	make -C hw clean
	rm -rf output *.xpfm sw v1_0 v2_0 .Xil 

