set_property HDL_ATTRIBUTE.DEBUG true [get_bd_intf_nets {bf_ifft_pl_0_cin0 bf_ifft_pl_0_din0 ai_engine_0_M00_AXIS}]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
                                                          [get_bd_intf_nets ai_engine_0_M00_AXIS] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/clk_wizard_0/clk_aie_pl" AXIS_ILA "Auto" APC_EN "0" } \
                                                          [get_bd_intf_nets bf_ifft_pl_0_cin0] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/clk_wizard_0/clk_aie_pl" AXIS_ILA "Auto" APC_EN "0" } \
                                                          [get_bd_intf_nets bf_ifft_pl_0_din0] {AXIS_SIGNALS "Data and Trigger" CLK_SRC "/clk_wizard_0/clk_aie_pl" AXIS_ILA "Auto" APC_EN "0" } \
                                                         ]
endgroup


startgroup
set_property -dict [list CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH.VALUE_SRC USER CONFIG.C_SLOT_1_AXIS_TDATA_WIDTH.VALUE_SRC USER CONFIG.C_SLOT_2_AXIS_TDATA_WIDTH.VALUE_SRC USER] [get_bd_cells axis_ila_2]
set_property -dict [list CONFIG.C_SLOT {2} CONFIG.C_INPUT_PIPE_STAGES {3} CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH {8} CONFIG.C_SLOT_1_AXIS_TDATA_WIDTH {8} CONFIG.C_SLOT_2_AXIS_TDATA_WIDTH {8}] [get_bd_cells axis_ila_2]
endgroup