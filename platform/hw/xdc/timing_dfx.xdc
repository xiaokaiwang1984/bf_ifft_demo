create_clock -period 5.000 [get_ports sys_clk0_clk_p]
#create_clock -period 5.000 [get_ports CLK_IN1_D_clk_p]

#set_clock_uncertainty -hold  0.050 [get_clocks *]

set_property BLI TRUE [get_cells -filter REF_NAME=~FD* -of [get_pins -leaf -of [get_nets -of [get_pins -of [get_cells -hier -filter REF_NAME=~AIE_PL_*] -filter {!IS_CLOCK}]]]]



set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -100
set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -to [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -to [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -100

set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -100
set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -to [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -to [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -100

set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_aie_pl]] -100
set_max_delay -from [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] 100
set_min_delay -from [get_clocks -of_objects [get_pins design_1_i/versal_cips_0/inst/PS9_inst/PMCRCLKCLK[0]]] -to [get_clocks -of_objects [get_pins design_1_i/VitisRegion/clk_wizard_0/clk_ila]] -100


