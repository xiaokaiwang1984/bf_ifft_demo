XDC = xdc/aieshim_loc_constraints_mod.xdc \
	xdc/ddr.xdc \
	xdc/design_1_wrapper_debug.xdc \
	xdc/timing.xdc \
	xdc/vck190_loc.xdc

.phony: clean all

all:design_1.xsa

design_1.xsa: run.tcl pfm.tcl bd_flat.tcl ${XDC}
	vivado -mode batch -source ./run.tcl
	
design_dfx.xsa:run_dfx.tcl pfm.tcl bd_flat.tcl ${XDC}
	vivado -mode batch -source ./run_dfx.tcl

clean:
	rm -rf .Xil NOC_Power.xpe *vivado* *.xsa bf_ifft_flat bf_ifft_dfx hd_visual
