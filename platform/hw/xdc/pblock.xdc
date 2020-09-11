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
create_pblock pblock_VitisRegion
add_cells_to_pblock [get_pblocks pblock_VitisRegion] [get_cells -quiet [list design_1_i/VitisRegion]]
resize_pblock [get_pblocks pblock_VitisRegion] -add {SLICE_X44Y0:SLICE_X359Y327 SLICE_X0Y140:SLICE_X41Y327}
resize_pblock [get_pblocks pblock_VitisRegion] -add {AIE_CORE_X0Y0:AIE_CORE_X49Y7}
resize_pblock [get_pblocks pblock_VitisRegion] -add {AIE_NOC_X0Y0:AIE_NOC_X23Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {AIE_PL_X0Y0:AIE_PL_X48Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BLI_X24Y0:BLI_X201Y1 BLI_X0Y1:BLI_X22Y1}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BLI_TMR_X24Y0:BLI_TMR_X201Y1 BLI_TMR_X0Y1:BLI_TMR_X22Y1}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BUFGCE_HDIO_X0Y0:BUFGCE_HDIO_X1Y3}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BUFG_FABRIC_X0Y95:BUFG_FABRIC_X4Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BUFG_GT_X0Y95:BUFG_GT_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {BUFG_GT_SYNC_X0Y163:BUFG_GT_SYNC_X1Y0}
#resize_pblock [get_pblocks pblock_VitisRegion] -add {BUFG_PS_X0Y0:BUFG_PS_X0Y11}
resize_pblock [get_pblocks pblock_VitisRegion] -add {DPLL_X14Y1:DPLL_X14Y6 DPLL_X3Y7:DPLL_X12Y7 DPLL_X1Y4:DPLL_X1Y6}
resize_pblock [get_pblocks pblock_VitisRegion] -add {DSP58_CPLX_X0Y0:DSP58_CPLX_X5Y163}
resize_pblock [get_pblocks pblock_VitisRegion] -add {DSP_X0Y0:DSP_X11Y163}
resize_pblock [get_pblocks pblock_VitisRegion] -add {GCLK_DELAY_X6Y0:GCLK_DELAY_X6Y167 GCLK_DELAY_X2Y0:GCLK_DELAY_X5Y191 GCLK_DELAY_X0Y48:GCLK_DELAY_X1Y191}
resize_pblock [get_pblocks pblock_VitisRegion] -add {GTY_QUAD_X0Y6:GTY_QUAD_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {GTY_REFCLK_X0Y13:GTY_REFCLK_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {HDIOLOGIC_X0Y0:HDIOLOGIC_X1Y10}
resize_pblock [get_pblocks pblock_VitisRegion] -add {HDIO_BIAS_X0Y0:HDIO_BIAS_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {HDLOGIC_APB_X0Y0:HDLOGIC_APB_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {IOB_X96Y3:IOB_X96Y13}
resize_pblock [get_pblocks pblock_VitisRegion] -add {MRMAC_X0Y0:MRMAC_X0Y3}
resize_pblock [get_pblocks pblock_VitisRegion] -add {NOC_NMU128_X1Y10:NOC_NMU128_X16Y10}
resize_pblock [get_pblocks pblock_VitisRegion] -add {NOC_NMU512_X0Y0:NOC_NMU512_X3Y6}
resize_pblock [get_pblocks pblock_VitisRegion] -add {NOC_NSU128_X1Y6:NOC_NSU128_X16Y6}
resize_pblock [get_pblocks pblock_VitisRegion] -add {NOC_NSU512_X0Y0:NOC_NSU512_X3Y6}
resize_pblock [get_pblocks pblock_VitisRegion] -add {PCIE40_X0Y2:PCIE40_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {RAMB18_X11Y0:RAMB18_X11Y165 RAMB18_X1Y0:RAMB18_X10Y167 RAMB18_X0Y72:RAMB18_X0Y165}
resize_pblock [get_pblocks pblock_VitisRegion] -add {RAMB36_X11Y0:RAMB36_X11Y82 RAMB36_X1Y0:RAMB36_X10Y83 RAMB36_X0Y36:RAMB36_X0Y82}
resize_pblock [get_pblocks pblock_VitisRegion] -add {RPI_HD_APB_X0Y0:RPI_HD_APB_X1Y0}
resize_pblock [get_pblocks pblock_VitisRegion] -add {URAM288_X2Y0:URAM288_X5Y82 URAM288_X1Y0:URAM288_X1Y83 URAM288_X0Y36:URAM288_X0Y82}
resize_pblock [get_pblocks pblock_VitisRegion] -add {XPIPE_QUAD_X0Y0:XPIPE_QUAD_X0Y3}
resize_pblock [get_pblocks pblock_VitisRegion] -add {CLOCKREGION_X7Y0:CLOCKREGION_X7Y0}
set_property SNAPPING_MODE ON [get_pblocks pblock_VitisRegion]
set_property IS_SOFT FALSE [get_pblocks pblock_VitisRegion]
