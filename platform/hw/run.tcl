set project "bf_ifft_flat"
set proj_dir "."
set Part xcvc1902-vsva2197-1LP-e-es1

create_project -force ${project} ${proj_dir}/${project} -part ${Part} 

set_property  ip_repo_paths  {../../IPs/iprepo} [current_project]
update_ip_catalog

##added to speed up the runtime
config_ip_cache -import_from_project -use_cache_location ../../hw/ipcache

 
#------------------------------------------------------------------------------------
source ./bd_flat.tcl
source ./pfm.tcl

make_wrapper -files [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v


add_files -fileset constrs_1 -norecurse { \
	./xdc/ddr.xdc \
	./xdc/timing.xdc \
	./xdc/vck190_loc.xdc}



update_compile_order -fileset sources_1
update_compile_order -fileset constrs_1

#----------------------------------------------------------------------------------------

import_files -fileset utils_1 -norecurse ./qor_scripts/pre_place.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_place.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_route.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_physopt.tcl

set_property platform.run.steps.place_design.tcl.pre [get_files pre_place.tcl] [current_project]
set_property platform.run.steps.place_design.tcl.post [get_files post_place.tcl] [current_project]
set_property platform.run.steps.route_design.tcl.post [get_files post_route.tcl] [current_project]
#set_property platform.run.steps.phys_opt_design.tcl.post [get_files post_physopt.tcl] [current_project]


validate_bd_design

set_property PLATFORM.LINK_XP_SWITCHES_DEFAULT [list param:compiler.skipTimingCheckAndFrequencyScaling=true param:hw_em.enableProfiling=false] [current_project]

#----------------------------------------------------------------------------------------
#Simulation steps

set_property SELECTED_SIM_MODEL tlm [get_bd_cells /versal_cips_0]
set_property SELECTED_SIM_MODEL tlm [get_bd_cells /axi_noc*]

#----------------------------------------------------------------------------------------

 
set_property platform.default_output_type "hw_export" [current_project]
update_compile_order -fileset sources_1
save_bd_design

set_param dsa.includeMEContent true
import_files

generate_target all [get_files ${proj_dir}/${project}/${project}.srcs/sources_1/bd/design_1/design_1.bd]

write_hw_platform -force ./design_1.xsa

#for debugging purpose
#launch_runs synth_1 -jobs 10
#wait_on_run synth_1
#launch_runs impl_1 -to_step write_device_image -jobs 10
#wait_on_run impl_1
#open_run impl_1


