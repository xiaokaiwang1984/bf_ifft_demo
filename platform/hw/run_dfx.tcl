set project "bf_ifft_dfx"
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
	./xdc/timing_dfx.xdc \
	./xdc/pblock.xdc \
	./xdc/vck190_loc.xdc}

import_files -fileset utils_1 -norecurse ./qor_scripts/pre_place.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_place.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_route.tcl
import_files -fileset utils_1 -norecurse ./qor_scripts/post_physopt.tcl
import_files -fileset utils_1 -norecurse ./remap_addrs.tcl

set_property platform.run.steps.place_design.tcl.pre [get_files pre_place.tcl] [current_project]
set_property platform.run.steps.place_design.tcl.post [get_files post_place.tcl] [current_project]
set_property platform.run.steps.route_design.tcl.post [get_files post_route.tcl] [current_project]
set_property platform.run.steps.phys_opt_design.tcl.post [get_files post_physopt.tcl] [current_project]
set_property platform.post_sys_link_overlay_tcl_hook [get_files remap_addrs.tcl] [current_project]

import_files

source ./create_bdc.tcl

validate_bd_design
set_property -dict [list CONFIG.LOCK_PROPAGATE {true} CONFIG.ENABLE_DFX {true}] [get_bd_cells VitisRegion]
validate_bd_design

set_property platform.platform_state "impl" [current_project]
set_property platform.uses_pr true [current_project]
set_property platform.dr_inst_path {design_1_i/VitisRegion} [current_project]
set_property platform.design_intent.embedded "true" [current_project]
set_property platform.design_intent.server_managed "false" [current_project]
set_property platform.design_intent.external_host "false" [current_project]
set_property platform.design_intent.datacenter "false" [current_project]
set_property platform.default_output_type "hw_export" [current_project]

update_compile_order -fileset sources_1
save_bd_design
launch_runs synth_1 -jobs 10
wait_on_run synth_1

create_pr_configuration -name config_1 -partitions [list design_1_i/VitisRegion:VitisRegion_inst_0 ]
set_property PR_CONFIGURATION config_1 [get_runs impl_1]

set_property STEPS.PLACE_DESIGN.TCL.PRE [get_files pre_place.tcl -of [get_fileset utils_1]] [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.TCL.POST [get_files post_place.tcl -of [get_fileset utils_1]] [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.TCL.POST [get_files post_route.tcl -of [get_fileset utils_1]] [get_runs impl_1]

reset_run synth_1

launch_runs impl_1 -to_step write_device_image -jobs 10
wait_on_run impl_1
open_run impl_1

write_hw_platform -include_bit -force ./design_dfx.xsa
validate_hw_platform -verbose ./design_dfx.xsa

