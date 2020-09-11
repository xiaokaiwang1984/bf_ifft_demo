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
#Create hierachy for RP region

group_bd_cells VitisRegion [get_bd_cells xlslice_0] [get_bd_cells smartconnect_0] [get_bd_cells axi_dma_0] [get_bd_cells axi_dma_1] [get_bd_cells axi_register_slice_1] [get_bd_cells bf_ifft_pl_0] [get_bd_cells axi_noc_aie] [get_bd_cells clk_wizard_0] [get_bd_cells axi_dma_2] [get_bd_cells PRst_aie_pl] [get_bd_cells axi_gpio_0] [get_bd_cells proc_sys_reset_2] [get_bd_cells axi_noc_rp_ddr] [get_bd_cells axi_dbg_hub_0] [get_bd_cells axis_ila_0] [get_bd_cells axis_ila_1] [get_bd_cells ai_engine_0] [get_bd_cells c_counter_binary_1]


########################################

validate_bd_design

set curdesign [current_bd_design]

create_bd_design -cell [get_bd_cells /VitisRegion] VitisRegion

current_bd_design $curdesign

set new_cell [create_bd_cell -type container -reference VitisRegion VitisRegion_temp]
replace_bd_cell [get_bd_cells /VitisRegion] $new_cell
delete_bd_objs  [get_bd_cells /VitisRegion]
set_property name VitisRegion $new_cell

validate_bd_design


set intfApertureSet [dict create \
	    S_AXI [get_property APERTURES [get_bd_intf_pins /versal_cips_0/M_AXI_FPD]] \
        ]


current_bd_design [get_bd_designs VitisRegion]

foreach {intf aperture} ${intfApertureSet} {
	set_property APERTURES ${aperture} [get_bd_intf_ports /${intf}]
	set_property HDL_ATTRIBUTE.LOCKED TRUE [get_bd_intf_ports /${intf}]
}
set_property PFM_NAME {xilinx.com:vck190_bf_ifft:vck190_bf_ifft:1.0} [get_files VitisRegion.bd]

validate_bd_design
save_bd_design

current_bd_design ${curdesign}

upgrade_bd_cells [get_bd_cells VitisRegion] [get_bd_cells VitisRegion]
validate_bd_design
save_bd_design

