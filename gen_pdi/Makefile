PETALNX_BSP	:=/opt/petalinux/xilinx-vck190-qspi-v2019.2-final.bsp

./Work/aiearchive.aieprj:
	aiecompiler --dataflow -v -AIESCSim -full-program=true -genArchive=true -include=../src_aie -include=../src_aie/kernels -include=../src_aie/inc ../src_aie/test_dl8a.cpp --device=VC1902.json -workdir=Work -heapsize=2048 -Xmapper="Disable Floorplanning" --new-placer=true --new-router=true -use-phy-shim=true -pl-freq=491 -pl-register-threshold=125 --test-iterations=-1


./iprepo/bf_ifft_pl:
	vivado -mode batch -source ./scripts/rtlpacker_v2.tcl
	

./xdc/aieshim_loc_constraints_mod.xdc:./Work/aiearchive.aieprj
	grep Instance "./Work/arch/aieshim_solution.aiesol" | paste - - | awk -F \" '{print $10,$16 }' | sed 's/^M0/M/g' | sed 's/^S0/S/g' | sed 's/^M/ai_plAIE_PL_ai_pl_ch_/g' | sed 's/^S/pl_aiAIE_PL_pl_ai_ch_/g' | sed 's/_AXIS //g' | sed 's/Y0_/Y0/g' | awk -F "AIE_PL_" '{print "set_property LOC AIE_PL_"$3" [get_cells design_1_i/ai_engine_0_ss/ai_engine_0/inst/"$2"/inst/"$1"_channel_inst]\nset_property BEL AIE_PL.AIE_PL_"$4" [get_cells design_1_i/ai_engine_0_ss/ai_engine_0/inst/"$2"/inst/"$1"_channel_inst]"}' > ./xdc/aieshim_loc_constraints_mod.xdc
	

./design_1.xsa:./Work/aiearchive.aieprj ./iprepo/bf_ifft_pl
	vivado -mode batch -source ./scripts/run_cosim.tcl
	
	
xsa:./design_1.xsa 




./bf_ifft_plat:./design_1.xsa 
	mkdir xfpm
	cp ./design_1.xsa ./xfpm
	cd ./xfpm ;\
	generate-platform.sh -name bf_ifft_plat -hw ./design_1.xsa \
        -domain ai_engine:aie_runtime \
        -domain psv_cortexa72_0:standalone ; \
	cp -rf bf_ifft_plat/export/bf_ifft_plat ..



aie_w_plat:./bf_ifft_plat 
	aiecompiler --target=hw --platform=./bf_ifft_plat/bf_ifft_plat.xpfm --dataflow -v -AIESCSim -full-program=true -genArchive=true -include=../src_aie -include=../src_aie/kernels -include=../src_aie/inc ../src_aie/test_dl8a.cpp --device=VC1902.json -workdir=Work -heapsize=2048 -Xmapper="Disable Floorplanning" --new-placer=true --new-router=true -use-phy-shim=true -pl-freq=491 -pl-register-threshold=125 --test-iterations=-1
	

../src_a72/main.elf:
	cd ../src_a72; \
	make all

	

cosim:./bf_ifft_plat ../src_a72/main.elf 
	if [ -d hw_emu ] ; then rm -rf hw_emu ;fi
	mkdir hw_emu
	cd hw_emu ; \
	${XILINX_VITIS}/scripts/vitis/util/prep_target -target hw_emu -pdi ../xfpm/design_1_presynth.pdi \
	-ps-elf ../../src_a72/main.elf -out-dir ./ -enable-aie-cores \
	-pmc-cdo ${XILINX_VITIS}/data/emulation/platforms/versal/sw/a72_standalone/qemu/pmc_cdo.bin \
	-plm-elf ${XILINX_VITIS}/data/emulation/platforms/versal/sw/a72_standalone/qemu/plm.elf \
	-aie-work-dir ../Work \
	-aie-device ${XILINX_VITIS}/cardano/data/devices/VC1902.json \
	-aie-shim-sol-file ../Work/arch/aieshim_solution.aiesol \
	-sim-dir ../bf_ifft_cosim/bf_ifft_cosim.sim/sim_1/behav/xsim; \
	./launch_hw_emulator.sh -noc-ddr-shared-mem qemu-memory-_ddr@0x00000000 -graphic-xsim





design_1.pdi:./Work/aiearchive.aieprj ./xdc/aieshim_loc_constraints_mod.xdc ./iprepo/bf_ifft_pl 
	vivado -mode batch -source ./scripts/run_implt.tcl
	
design_1_aie.pdi:design_1.pdi
	python ./scripts/addAieToBif.py design_1.pdi.bif design_1_aie.pdi.bif ./Work/
	cd ./Work/ps/cdo; \
	./generateAIEConfig -e
	bootgen -arch versal -image ./design_1_aie.pdi.bif -w -o ./design_1_aie.pdi
	cp design_1_aie.pdi ../images
	cp debug_nets.ltx ../images

pdi:design_1_aie.pdi

	
	
	
	


hw.pdi:design_1.pdi ../src_a72/main.elf ./Work/aiearchive.aieprj
	${XILINX_VITIS}/scripts/vitis/util/prep_target -target hw -pdi ./design_1.pdi \
	-ps-elf ../src_a72/main.elf -out-dir ./ \
	-aie-work-dir ./Work \
	-aie-device ${XILINX_VITIS}/cardano/data/devices/VC1902.json \
	-aie-shim-sol-file ./Work/arch/aieshim_solution.aiesol \
	-enable-aie-cores \
	-boot-mode qspi \
	-name hw.pdi
	
./vck190_petalnx:./bf_ifft_plat
	petalinux-create -t project -s ${PETALNX_BSP} -n vck190_petalnx
	petalinux-config -p ./vck190_petalnx --get-hw-description=. --silentconfig
	cp ./scripts/system-user.dtsi ./vck190_petalnx/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi
	cd vck190_petalnx;petalinux-build

lnx_app:./bf_ifft_plat
	cd ../src_app;make all
	
images: design_1_aie.pdi ./vck190_petalnx ../src_a72/main.elf lnx_app
	cp ./scripts/xsdb* ../images
	cp ./vck190_petalnx/images/linux/system.dtb  ../images
	cp ./vck190_petalnx/images/linux/u-boot.elf  ../images
	cp ./vck190_petalnx/images/linux/image.ub  ../images

	

all:images 

clean:
	if [ -d .Xil 				]; then rm -rf .Xil 				;fi
	if [ -d vck190_petalnx		]; then rm -rf vck190_petalnx		;fi
	if [ -d aie_init			]; then rm -rf aie_init				;fi
	if [ -d static_files		]; then rm -rf static_files			;fi
	if [ -d gen_files			]; then rm -rf gen_files			;fi
	if [ -d Work 				]; then rm -rf Work 				;fi
	if [ -d bf_ifft_cosim		]; then rm -rf bf_ifft_cosim		;fi
	if [ -d bf_ifft_implt	    ]; then rm -rf bf_ifft_implt	  	;fi
	if [ -d bf_ifft_plat        ]; then rm -rf bf_ifft_plat         ;fi
	if [ -d hw_emu              ]; then rm -rf hw_emu               ;fi
	if [ -d iprepo              ]; then rm -rf iprepo               ;fi
	if [ -d rtlpackaging        ]; then rm -rf rtlpackaging         ;fi
	if [ -d rtlpackaging_1      ]; then rm -rf rtlpackaging_1       ;fi
	if [ -d xfpm                ]; then rm -rf xfpm                 ;fi
	if [ -d xnwOut              ]; then rm -rf xnwOut               ;fi
	if [ -f design_1.xsa 		]; then rm design_1.xsa 			;fi
	if [ -f vivado.log 			]; then rm vivado*					;fi
	if [ -f NOC_Power.xpe		]; then rm NOC_Power.xpe			;fi
	if [ -f design_1.pdi		]; then rm design_1*				;fi
	if [ -f debug_nets.ltx		]; then rm debug_nets.ltx			;fi
	cd ../src_a72;make clean;
	cd ../src_app;make clean;
	if [ -f ../images/u-boot.elf ]; then rm ../images/*              ;fi
	
	
	
