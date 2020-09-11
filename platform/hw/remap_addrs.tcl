########################################
# (c) Copyright 2014 – 2020 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and XILINX INTERNAL
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same. 
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#
# 
########################################

assign_bd_address

set __ddr_segs [get_bd_addr_segs -filter {NAME=~"SEG_DDR_*_Reg" && PATH !~"/PL_CTRL_S_AXI*"}]
set __lpddr0_segs [get_bd_addr_segs -filter {NAME=~"SEG_LPDDR0_*_Reg" && PATH !~"/PL_CTRL_S_AXI*"}]
set __lpddr1_segs [get_bd_addr_segs -filter {NAME=~"SEG_LPDDR1_*_Reg" && PATH !~"/PL_CTRL_S_AXI*"}]

if {[llength ${__ddr_segs}] > 0} {
	set_property offset 0x0 ${__ddr_segs}
	set_property range 2G ${__ddr_segs}
}
if {[llength ${__lpddr0_segs}] > 0} {
	set_property offset 0x50000000000 ${__lpddr0_segs}
	set_property range 4G ${__lpddr0_segs}
}
if {[llength ${__lpddr1_segs}] > 0} {
	set_property offset 0x58000000000 ${__lpddr1_segs}
	set_property range 4G ${__lpddr1_segs}
}

#This is to work around an issue in write_hw_platform being called from a vivado other than the parent-most context:

rename ocl_util::copy_impl_run_output_files ocl_util::copy_impl_run_output_files_orig
proc ::ocl_util::copy_impl_run_output_files {best_run hw_platform_info config_info} {
	set output_dir [dict get $config_info output_dir]
	set vpl_output_dir [dict get $config_info vpl_output_dir]
	set fixed_xsa [dict get $config_info fixed_xsa]
	set target $vpl_output_dir/$fixed_xsa
	if {[file exists $target]} {
		open_run $best_run
		write_hw_platform -fixed -include_bit -force $target
	}
	ocl_util::copy_impl_run_output_files_orig $best_run $hw_platform_info $config_info
}
