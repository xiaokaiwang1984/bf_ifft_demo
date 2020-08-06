########################################################################
# NOTE: This is a tool-generated file and should not be edited manually.
########################################################################

set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/bfo_axi_trdy]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/bfo_axi_tvld]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin0_axi_trdy]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin0_axi_tvld]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin1_axi_trdy]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin1_axi_tvld]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin2_axi_trdy]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin2_axi_tvld]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin3_axi_trdy]
set_property MARK_DEBUG true [get_nets design_1_i/bf_ifft_pl_0/cin3_axi_tvld]
# Core: u_ila_0
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_NUM_OF_PROBES 1 [get_debug_cores u_ila_0]
connect_debug_port u_ila_0/clk [get_nets [list {design_1_i/clk_wizard_0/inst/clock_primitive_inst/clk_aie_pl} ]]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/bf_ifft_pl_0/bfo_axi_trdy} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/bf_ifft_pl_0/bfo_axi_tvld} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {design_1_i/bf_ifft_pl_0/cin0_axi_trdy} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {design_1_i/bf_ifft_pl_0/cin0_axi_tvld} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {design_1_i/bf_ifft_pl_0/cin1_axi_trdy} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {design_1_i/bf_ifft_pl_0/cin1_axi_tvld} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {design_1_i/bf_ifft_pl_0/cin2_axi_trdy} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {design_1_i/bf_ifft_pl_0/cin2_axi_tvld} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {design_1_i/bf_ifft_pl_0/cin3_axi_trdy} ]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {design_1_i/bf_ifft_pl_0/cin3_axi_tvld} ]]

