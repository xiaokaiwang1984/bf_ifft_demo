set project "bf_ifft_plat"
set proj_dir "."

#----------------------------------------------------------------------------------------
set_param bd.generateHybridSystemC true

#----------------------------------------------------------------------------------------
#VIVADO IPI project settings & BD creation
#set Part xc10S80-vsva2197-3-e-es1
set Part xcvc1902-vsva2197-1LP-e-es1

create_project -force ${project} ${proj_dir}/${project} -part ${Part} 

set_property  ip_repo_paths  {../../IPs/iprepo} [current_project]
update_ip_catalog

#------------------------------------------------------------------------------------
source ./bd_platform.tcl
source ./pfm.tcl

#----------------------------------------------------------------------------------------
add_files -fileset constrs_1 -norecurse ./xdc/vck190_loc.xdc
add_files -fileset constrs_1 -norecurse ./xdc/ddr.xdc
add_files -fileset constrs_1 -norecurse ./xdc/timing.xdc
#add_files -fileset constrs_1 -norecurse ./xdc/aieshim_loc_constraints_mod.xdc
add_files -fileset constrs_1 -norecurse ./xdc/design_1_wrapper_debug.xdc

make_wrapper -files [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset constrs_1
#----------------------------------------------------------------------------------------

import_files -fileset utils_1 -norecurse ./waive_BLI_AIE_timing_violations_postplace.tcl

set_property platform.run.steps.place_design.tcl.post [get_files waive_BLI_AIE_timing_violations_postplace.tcl] [current_project]

#examples
#set_property platform.run.steps.place_design.tcl.post [get_files post_place.tcl] [current_project]
#set_property platform.run.steps.route_design.tcl.post [get_files post_route.tcl] [current_project]


set_property PLATFORM.LINK_XP_SWITCHES_DEFAULT [list param:compiler.skipTimingCheckAndFrequencyScaling=true param:hw_em.enableProfiling=false] [current_project]

#----------------------------------------------------------------------------------------
#Simulation steps

set_property SELECTED_SIM_MODEL tlm [get_bd_cells /versal_cips_0]
set_property SELECTED_SIM_MODEL tlm [get_bd_cells /axi_noc_0]

#----------------------------------------------------------------------------------------

 
set_property platform.default_output_type "hw_export" [current_project]
update_compile_order
assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

set_param dsa.includeMEContent true
import_files

generate_target all [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd]

write_hw_platform -force ./design_1.xsa


