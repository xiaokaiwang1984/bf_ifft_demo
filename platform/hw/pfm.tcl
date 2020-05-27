#setup the name
set_property PFM_NAME {xilinx.com:vck190_bf_ifft:vck190_bf_ifft:1.0} [get_files [current_bd_design].bd]

#setup the dbg_hub
set_property PFM.AXIS_PORT {S00_AXIS {type "S_AXIS" sptag dbg_S00_AXIS} S01_AXIS {type "S_AXIS" sptag dbg_S01_AXIS} S02_AXIS {type "S_AXIS" sptag dbg_S02_AXIS} S03_AXIS {type "S_AXIS" sptag dbg_S03_AXIS} S04_AXIS {type "S_AXIS" sptag dbg_S04_AXIS} S05_AXIS {type "S_AXIS" sptag dbg_S05_AXIS} S06_AXIS {type "S_AXIS" sptag dbg_S06_AXIS} S07_AXIS {type "S_AXIS" sptag dbg_S07_AXIS} M00_AXIS {type "M_AXIS" sptag dbg_M00_AXIS} M01_AXIS {type "M_AXIS" sptag dbg_M01_AXIS} M02_AXIS {type "M_AXIS" sptag dbg_M02_AXIS} M03_AXIS {type "M_AXIS" sptag dbg_M03_AXIS} M04_AXIS {type "M_AXIS" sptag dbg_M04_AXIS} M05_AXIS {type "M_AXIS" sptag dbg_M05_AXIS} M06_AXIS {type "M_AXIS" sptag dbg_M06_AXIS} M07_AXIS {type "M_AXIS" sptag dbg_M07_AXIS}} [get_bd_cells /axi_dbg_hub_0]

#DDR interfaces
set_property PFM.AXI_PORT {S11_AXI {memport "S_AXI_HP" sptag lpddr0} S12_AXI {memport "S_AXI_HP" sptag lpddr0}} [get_bd_cells /axi_noc_0]

#PS GP interfaces
set_property PFM.AXI_PORT {M05_AXI {memport "M_AXI_GP" sptag "GP"} M06_AXI {memport "M_AXI_GP" sptag "GP"}} [get_bd_cells /smartconnect_0]

#clocks
set_property PFM.CLOCK {clk_out1 {id "0" is_default "false" proc_sys_reset "/proc_sys_reset_0" status "fixed"} clk_aie_pl {id "1" is_default "true" proc_sys_reset "/proc_sys_reset_1" status "fixed"} } [get_bd_cells /clk_wizard_0]

#Other PL AXI interfaces

set_property PFM.AXIS_PORT {din0 {type "M_AXIS" sptag bf_input_din0} din1 {type "M_AXIS" sptag bf_input_din1} din2 {type "M_AXIS" sptag bf_input_din2} din3 {type "M_AXIS" sptag bf_input_din3} cin0 {type "M_AXIS" sptag bf_input_cin0} cin1 {type "M_AXIS" sptag bf_input_cin1} cin2 {type "M_AXIS" sptag bf_input_cin2} cin3 {type "M_AXIS" sptag bf_input_cin3} ifia {type "M_AXIS" sptag ifft_input_a} ifib {type "M_AXIS" sptag ifft_input_b} bfo  {type "S_AXIS" sptag bf_output_bf0} ifoa {type "S_AXIS" sptag ifft_output_a} ifob {type "S_AXIS" sptag ifft_output_b} } [get_bd_cells /bf_ifft_pl_0]


