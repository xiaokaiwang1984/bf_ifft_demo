
set project "bf_ifft_cosim"
set ip_repo_dir "."
set proj_dir "."
#set ::env(sdx_me_app_dir) "../sdx/dl8a/Debug/Work"
set ::env(sdx_me_app_dir) "../Debug/Work"


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
set_property SELECTED_SIM_MODEL tlm [get_bd_cells /versal_cips_0]
set_property SELECTED_SIM_MODEL tlm [get_bd_cells /axi_noc_0]

validate_bd_design -force
generate_target -force all [get_files *design_1.bd]
make_wrapper -files [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v

#set obj [get_filesets sources_1]
update_compile_order -fileset sim_1

#set input_file $::env(sdx_me_app_dir)/../data/input.txt

set_property SOURCE_SET sources_1 [get_filesets sim_1]
#add_files -fileset sim_1 -norecurse $input_file

set_property -name {xsim.simulate.runtime} -value {500ns} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.no_quit} -value {true} -objects [current_fileset sim_1]

#xsim settings required for GUI launch & Transaction viewer
set_property -name {xsim.simulate.xsim.more_options} -value {-gui &} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value " \$*" -objects [current_fileset -simset] 
#set_property SIM_ATTRIBUTE.MARK_SIM true [get_bd_intf_nets {me_0_ME_PL_AXIS_0 i6_po0 i0_po0 ps_pmc_0_IF_PMC_NOC_AXI_0 axi_noc_0_M00_AXI i5_pi0}]




# Set 'sources_1' fileset properties

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_simulation -scripts_only
launch_simulation -step compile
launch_simulation -step elaborate

set_param dsa.includeMEContent true
set_property dsa.name design_1 [current_project]
##set_property dsa.board_id bf_ifft_board [current_project]
write_hw_platform -fixed -force -file ./design_1.xsa
validate_hw_platform ./design_1.xsa -verbose

