XSA = design_1.xsa
XDC = xdc/aieshim_loc_constraints_mod.xdc \
	xdc/ddr.xdc \
	xdc/design_1_wrapper_debug.xdc \
	xdc/timing.xdc \
	xdc/vck190_loc.xdc

.phony: clean all

all: ${XSA}

${XSA}: run.tcl pfm.tcl bd_platform.tcl ${XDC}
	vivado -mode batch -source ./run.tcl

clean:
	rm -rf .Xil NOC_Power.xpe *vivado* ${XSA} bf_ifft_plat
