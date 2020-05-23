all:xsa output


xsa:
	vivado -mode batch -source ./scripts/run.tcl
	
hw_only:xsa
	cp design_1.xsa ../hw
	

output:
	xsct -nodisp -sdx ./scripts/plat_gen.tcl bf_ifft_v1_0 ./design_1.xsa output
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0/hw ../
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0/sw ../
	cp -r output/bf_ifft_v1_0/export/bf_ifft_v1_0/bf_ifft_v1_0.xpfm ../
	
clean:
	rm -rf vivado*
	rm -rf .Xil
	rm -rf NOC_Power.xpe design_1.xsa bf_ifft_plat
	rm -rf output
	
