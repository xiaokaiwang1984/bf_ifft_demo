
set project "bf_ifft_implt"
set ip_repo_dir "."
set proj_dir "."
#set ::env(sdx_me_app_dir) "../sdx/dl8a/Debug/Work"
set ::env(sdx_me_app_dir) "./Work"


puts "$::env(sdx_me_app_dir)"
#
#----------------------------------------------------------------------------------------
set_param bd.generateHybridSystemC true

#----------------------------------------------------------------------------------------
#VIVADO IPI project settings & BD creation
#set Part xc10S80-vsva2197-3-e-es1
set Part xcvc1902-vsva2197-1LP-e-es1
device_enable -enable ${Part}
create_project -force ${project} ${proj_dir}/${project} -part ${Part} 

set_property  ip_repo_paths  {./iprepo} [current_project]
update_ip_catalog

#------------------------------------------------------------------------------------
source ./scripts/bd.tcl

#----------------------------------------------------------------------------------------
#Simulation steps
#set_property SELECTED_SIM_MODEL tlm [get_bd_cells /ai_engine_0_ss/aietb_dl8a_0]
#set_property SELECTED_SIM_MODEL tlm [get_bd_cells /axi_noc_0]
#set_property SELECTED_SIM_MODEL tlm [get_bd_cells /pspmc_0]

assign_bd_address
validate_bd_design -force
generate_target -force all [get_files *design_1.bd]
make_wrapper -files [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v

#set obj [get_filesets sources_1]
#update_compile_order -fileset sim_1

#set input_file $::env(sdx_me_app_dir)/../data/input.txt

add_files -fileset constrs_1 -norecurse ./xdc/vck190_loc.xdc
add_files -fileset constrs_1 -norecurse ./xdc/ddr.xdc
add_files -fileset constrs_1 -norecurse ./xdc/timing.xdc
add_files -fileset constrs_1 -norecurse ./xdc/aieshim_loc_constraints_mod.xdc
add_files -fileset constrs_1 -norecurse ./xdc/design_1_wrapper_debug.xdc

set_property SOURCE_SET sources_1 [get_filesets sim_1]
#add_files -fileset sim_1 -norecurse ./verilog/tb_top.v

#set_property -name {xsim.simulate.runtime} -value {150us} -objects [get_filesets sim_1]
#set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
#set_property -name {xsim.simulate.no_quit} -value {true} -objects [current_fileset sim_1]

##xsim settings required for GUI launch & Transaction viewer
#set_property -name {xsim.simulate.xsim.more_options} -value {-gui &} -objects [get_filesets sim_1]
#set_property -name {xsim.simulate.xsim.more_options} -value " \$*" -objects [current_fileset -simset] 
#set_property SIM_ATTRIBUTE.MARK_SIM true [get_bd_intf_nets {me_0_ME_PL_AXIS_0 i6_po0 i0_po0 ps_pmc_0_IF_PMC_NOC_AXI_0 axi_noc_0_M00_AXI i5_pi0}]




# Set 'sources_1' fileset properties

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

#launch_simulation -scripts_only

#cd ${project}/${project}.sim/sim_1/behav/xsim/
#exec ./compile.sh
#exec ./elaborate.sh
#cd ../../../../../


#Vivado compile

add_files -fileset utils_1 -norecurse ./scripts/waive_BLI_AIE_timing_violations_postplace.tcl
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.TCL.POST [ get_files ./scripts/waive_BLI_AIE_timing_violations_postplace.tcl -of [get_fileset utils_1] ] [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE WLDrivenBlockPlacement [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

launch_runs synth_1 -jobs 16 -verbose
wait_on_run synth_1
launch_runs impl_1 -to_step write_device_image -jobs 16
wait_on_run impl_1

#open_run impl_1
#write_hw_platform -fixed -force  -include_bit -file ./design_1_wrapper.xsa

#2019.2_siea
open_checkpoint ./${project}/${project}.runs/impl_1/design_1_wrapper_postroute_physopt.dcp
set_property bitstream.general.compress zip [current_design]
set_property bitstream.general.npiDmaMode Yes [current_design]
write_device_image -force -raw_partitions -file design_1.pdi
write_debug_probes -force debug_nets.ltx

#----------------------------------------------------------------------------------------
# Write DSA steps!!
#set_param dsa.includeMEContent true
#set_property dsa.name design_1 [current_project]
#set_property dsa.board_id EvalDemoFlow2 [current_project]
#write_dsa -fixed -force ./design_1.dsa
#validate_dsa ./design_1.dsa



