#-----------------------------------------------------------
# Vivado v2019.1_meb1 (64-bit)
# SW Build 2400834 on Thu Nov 29 14:56:49 MST 2018
# IP Build 2398080 on Thu Nov 29 17:21:25 MST 2018
# Start of session at: Thu Apr  4 11:02:12 2019
# Process ID: 95060
#-----------------------------------------------------------
set IPNAME "bf_ifft_pl"
create_project -force rtlpackaging ./rtlpackaging -part xcvc1902-vsva2197-1LP-e-es1
add_files -norecurse ./vhd/scmapper.vhd
add_files -norecurse ./vhd/BRAM_DPWR.vhd
add_files -norecurse ./vhd/scmapper_axi2uram.vhd
add_files -norecurse ./vhd/scmapper_uram2fifo.vhd
add_files -norecurse ./vhd/scmapper_fifo2axi.vhd
add_files -norecurse ./verilog/scm_wrapper.v
add_files -norecurse ./verilog/coeff00.mem
add_files -norecurse ./verilog/coeff01.mem
add_files -norecurse ./verilog/coeff02.mem
add_files -norecurse ./verilog/coeff03.mem
add_files -norecurse ./verilog/din0.mem
add_files -norecurse ./verilog/din1.mem
add_files -norecurse ./verilog/din2.mem
add_files -norecurse ./verilog/din3.mem
add_files -norecurse ./verilog/uram_sdp.v
add_files -norecurse ./verilog/sync_fifo.v
add_files -norecurse ./verilog/async_fifo.v
add_files -norecurse ./verilog/ram2axi.v
add_files -norecurse ./verilog/axi2ram.v
add_files -norecurse ./verilog/dma_tx.v
add_files -norecurse ./verilog/dma_rx.v
add_files -norecurse ./verilog/bf_ifft_pl.v

import_files -force -norecurse
#set obj [get_filesets sim_1]
#set_property -name "top" -value "aietb_dl8a" -objects $obj
update_compile_order -fileset sources_1
#launch_simulation -scripts_only
#cd rtlpackaging/rtlpackaging.sim/sim_1/behav/xsim
#exec compile.sh
#exec elaborate.sh
#cd ../../../../..
ipx::package_project -root_dir ../iprepo/${IPNAME} -vendor user.org -library user -taxonomy /UserIP -import_files
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  ../iprepo/${IPNAME} [current_project]
update_ip_catalog
