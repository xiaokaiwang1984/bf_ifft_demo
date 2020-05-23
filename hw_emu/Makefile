VPP_FLAGS=--save-temps --verbose  --user_ip_repo_paths ${USER_IPREPO} --xp param:hw_emu.enableDebugWaveform=true --vivado.prop fileset.sim_1.xsim.simulate.runtime=100us --remote_ip_cache ./ip_cache


.PHONY:clea

all:bf_ifft.xclbin



bf_ifft.xclbin:
	v++ -l --platform ../platform/bf_ifft_v1_0.xpfm ../src_aie/Work/temp/test_dl8a.o -t hw_emu --config ./system.cfg -g -o bf_ifft.xclbin
	
clean:
	rm bf_ifft.xclbin.*
	rm *.log
	rm -rf _x

	