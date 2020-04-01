
# GPIO_PB0 SW4
set_property PACKAGE_PIN G37 [get_ports rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports rst_n]

set_property IOSTANDARD LVCMOS18 [get_ports led_0]
set_property IOSTANDARD LVCMOS18 [get_ports led_1]
set_property IOSTANDARD LVCMOS18 [get_ports led_rst]

# GPIO_LED_0_LS
# GPIO_LED_1_LS
# GPIO_LED_2_LS
set_property PACKAGE_PIN H34 [get_ports led_0]
set_property PACKAGE_PIN J33 [get_ports led_1]
set_property PACKAGE_PIN K36 [get_ports led_rst]

#set_property bitstream.general.write0frames No [current_design]
#set_property bitstream.general.npiDmaMode Yes [current_design]
#set_property bitstream.general.processallveams true [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design] 

# LPDDR4_SMA_CLK2_P 200Mhz
#set_property PACKAGE_PIN AW27 [get_ports CLK_IN1_D_clk_p]
#set_property IOSTANDARD DIFF_LVSTL_11 [get_ports CLK_IN1_D_clk_p]
#set_property PACKAGE_PIN AY27 [get_ports CLK_IN1_D_clk_n]
#set_property IOSTANDARD DIFF_LVSTL_11 [get_ports CLK_IN1_D_clk_n]


# LPDDR4_SMA_CLK1_P 200Mhz
#set_property PACKAGE_PIN AK8 [get_ports CLK_IN1_D_clk_p]
#set_property IOSTANDARD DIFF_LVSTL_11 [get_ports CLK_IN1_D_clk_p]
#set_property PACKAGE_PIN AK7 [get_ports CLK_IN1_D_clk_n]
#set_property IOSTANDARD DIFF_LVSTL_11 [get_ports CLK_IN1_D_clk_n]

