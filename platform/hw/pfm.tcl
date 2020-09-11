#setup the name
set_property PFM_NAME {xilinx.com:vck190_bf_ifft:vck190_bf_ifft:1.0} [get_files [current_bd_design].bd]

#DDR interfaces from RP
set_property PFM.AXI_PORT {S03_AXI {memport "S_AXI_HP" sptag lpddr0} } [get_bd_cells /axi_noc_rp_ddr]


#AIE 
set_property PFM.AXI_PORT {M00_AXI {memport "M_AXI_NOC" sptag "GP"}} [get_bd_cells /axi_noc_aie]

#PS GP interfaces
set_property PFM.AXI_PORT {M05_AXI {memport "M_AXI_GP" sptag "GP"} M06_AXI {memport "M_AXI_GP" sptag "GP"}} [get_bd_cells /smartconnect_0]

#clocks
set_property PFM.CLOCK {clk_aie_pl {id "0" is_default "true" proc_sys_reset "PRst_aie_pl" status "fixed"} } [get_bd_cells /clk_wizard_0]

#Other PL AXI interfaces

set_property PFM.AXIS_PORT {din0 {type "M_AXIS" sptag bf_input_din0} din1 {type "M_AXIS" sptag bf_input_din1} din2 {type "M_AXIS" sptag bf_input_din2} din3 {type "M_AXIS" sptag bf_input_din3} cin0 {type "M_AXIS" sptag bf_input_cin0} cin1 {type "M_AXIS" sptag bf_input_cin1} cin2 {type "M_AXIS" sptag bf_input_cin2} cin3 {type "M_AXIS" sptag bf_input_cin3} ifia {type "M_AXIS" sptag ifft_input_a} ifib {type "M_AXIS" sptag ifft_input_b} bfo  {type "S_AXIS" sptag bf_output_bf0} ifoa {type "S_AXIS" sptag ifft_output_a} ifob {type "S_AXIS" sptag ifft_output_b} } [get_bd_cells /bf_ifft_pl_0]

