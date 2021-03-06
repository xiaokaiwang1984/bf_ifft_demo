
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvc1902-vsva2197-1LP-e-S-es1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axi_noc:1.0\
xilinx.com:ip:c_counter_binary:12.0\
xilinx.com:ip:clk_wizard:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:versal_cips:1.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:ai_engine:1.0\
xilinx.com:ip:axi_dbg_hub:1.0\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axis_ila:1.0\
user.org:user:bf_ifft_pl:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: ai_engine_0_ss
proc create_hier_cell_ai_engine_0_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_ai_engine_0_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 dma_rx

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 dma_tx


  # Create pins
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I clk_aie
  create_bd_pin -dir I clk_dma
  create_bd_pin -dir I clk_scope
  create_bd_pin -dir O -type clk s00_axi_aclk

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine:1.0 ai_engine_0 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {1} \
   CONFIG.NUM_MI_AXI {0} \
   CONFIG.NUM_MI_AXIS {3} \
   CONFIG.NUM_NOC_AXIS_CLKS {0} \
   CONFIG.NUM_SI_AXI {1} \
   CONFIG.NUM_SI_AXIS {10} \
 ] $ai_engine_0

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/M00_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/M01_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/M02_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S00_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S01_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S02_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S03_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S04_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S05_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S06_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S07_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S08_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
   CONFIG.IS_REGISTERED {true} \
 ] [get_bd_intf_pins /ai_engine_0_ss/ai_engine_0/S09_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS:M01_AXIS:M02_AXIS:S00_AXIS:S01_AXIS:S02_AXIS:S03_AXIS:S04_AXIS:S05_AXIS:S06_AXIS:S07_AXIS:S08_AXIS:S09_AXIS} \
 ] [get_bd_pins /ai_engine_0_ss/ai_engine_0/aclk0]

  # Create instance: axi_dbg_hub_0, and set properties
  set axi_dbg_hub_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dbg_hub:1.0 axi_dbg_hub_0 ]
  set_property -dict [ list \
   CONFIG.C_AXI_DATA_WIDTH {128} \
   CONFIG.C_NUM_DEBUG_CORES {0} \
 ] $axi_dbg_hub_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {0} \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {0} \
   CONFIG.C_GPIO2_WIDTH {10} \
   CONFIG.C_GPIO_WIDTH {3} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axis_ila_0, and set properties
  set axis_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_ila:1.0 axis_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_BRAM_CNT {14.5} \
   CONFIG.C_DATA_DEPTH {2048} \
   CONFIG.C_INPUT_PIPE_STAGES {2} \
   CONFIG.C_NUM_OF_PROBES {5} \
   CONFIG.C_PROBE2_WIDTH {128} \
   CONFIG.C_PROBE4_WIDTH {128} \
 ] $axis_ila_0

  # Create instance: axis_ila_1, and set properties
  set axis_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_ila:1.0 axis_ila_1 ]
  set_property -dict [ list \
   CONFIG.C_BRAM_CNT {8} \
   CONFIG.C_DATA_DEPTH {16384} \
   CONFIG.C_INPUT_PIPE_STAGES {2} \
   CONFIG.C_NUM_OF_PROBES {2} \
   CONFIG.C_PROBE1_WIDTH {16} \
 ] $axis_ila_1

  # Create instance: bf_ifft_pl_0, and set properties
  set bf_ifft_pl_0 [ create_bd_cell -type ip -vlnv user.org:user:bf_ifft_pl:1.0 bf_ifft_pl_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins ai_engine_0/M00_AXIS] [get_bd_intf_pins bf_ifft_pl_0/bfo]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ai_engine_0/M01_AXIS] [get_bd_intf_pins bf_ifft_pl_0/ifoa]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins ai_engine_0/M02_AXIS] [get_bd_intf_pins bf_ifft_pl_0/ifob]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins ai_engine_0/S00_AXIS] [get_bd_intf_pins bf_ifft_pl_0/din0]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins ai_engine_0/S01_AXIS] [get_bd_intf_pins bf_ifft_pl_0/din1]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins ai_engine_0/S02_AXIS] [get_bd_intf_pins bf_ifft_pl_0/din2]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins ai_engine_0/S03_AXIS] [get_bd_intf_pins bf_ifft_pl_0/din3]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins ai_engine_0/S04_AXIS] [get_bd_intf_pins bf_ifft_pl_0/cin0]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins ai_engine_0/S05_AXIS] [get_bd_intf_pins bf_ifft_pl_0/cin1]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins ai_engine_0/S06_AXIS] [get_bd_intf_pins bf_ifft_pl_0/cin2]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins ai_engine_0/S07_AXIS] [get_bd_intf_pins bf_ifft_pl_0/cin3]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins ai_engine_0/S08_AXIS] [get_bd_intf_pins bf_ifft_pl_0/ifia]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins ai_engine_0/S09_AXIS] [get_bd_intf_pins bf_ifft_pl_0/ifib]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins dma_rx] [get_bd_intf_pins bf_ifft_pl_0/dma_rx]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins dma_tx] [get_bd_intf_pins bf_ifft_pl_0/dma_tx]
  connect_bd_intf_net -intf_net Conn16 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_dbg_hub_0/S_AXI]
  connect_bd_intf_net -intf_net Conn17 [get_bd_intf_pins S_AXI1] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins ai_engine_0/S00_AXI]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins aresetn] [get_bd_pins axi_dbg_hub_0/aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn]
  connect_bd_net -net ai_engine_0_s00_axi_aclk [get_bd_pins s00_axi_aclk] [get_bd_pins ai_engine_0/s00_axi_aclk]
  connect_bd_net -net axi_gpio_0_gpio_io_i [get_bd_pins axi_gpio_0/gpio2_io_i] [get_bd_pins bf_ifft_pl_0/gpio_output]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins bf_ifft_pl_0/gpio_input]
  connect_bd_net -net bf_ifft_pl_0_scope_a_axi_data [get_bd_pins axis_ila_0/probe2] [get_bd_pins bf_ifft_pl_0/scope_a_axi_data]
  connect_bd_net -net bf_ifft_pl_0_scope_a_axi_valid [get_bd_pins axis_ila_0/probe1] [get_bd_pins bf_ifft_pl_0/scope_a_axi_valid]
  connect_bd_net -net bf_ifft_pl_0_scope_b_axi_data [get_bd_pins axis_ila_0/probe4] [get_bd_pins bf_ifft_pl_0/scope_b_axi_data]
  connect_bd_net -net bf_ifft_pl_0_scope_b_axi_valid [get_bd_pins axis_ila_0/probe3] [get_bd_pins bf_ifft_pl_0/scope_b_axi_valid]
  connect_bd_net -net bf_ifft_pl_0_scope_rdy_vld [get_bd_pins axis_ila_1/probe1] [get_bd_pins bf_ifft_pl_0/scope_rdy_vld]
  connect_bd_net -net bf_ifft_pl_0_start_aie [get_bd_pins axis_ila_0/probe0] [get_bd_pins axis_ila_1/probe0] [get_bd_pins bf_ifft_pl_0/start_aie]
  connect_bd_net -net clk_aie_1 [get_bd_pins clk_aie] [get_bd_pins ai_engine_0/aclk0] [get_bd_pins bf_ifft_pl_0/clk]
  connect_bd_net -net clk_dma_1 [get_bd_pins clk_dma] [get_bd_pins axi_dbg_hub_0/aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins bf_ifft_pl_0/clk_dma]
  connect_bd_net -net clk_scope_1 [get_bd_pins clk_scope] [get_bd_pins axis_ila_0/clk] [get_bd_pins axis_ila_1/clk] [get_bd_pins bf_ifft_pl_0/clk_scope]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set CH0_DDR4_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0 ]

  set sys_clk0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0 ]


  # Create ports
  set led_0 [ create_bd_port -dir O -from 0 -to 0 led_0 ]
  set led_1 [ create_bd_port -dir O -from 0 -to 0 led_1 ]
  set led_rst [ create_bd_port -dir O led_rst ]

  # Create instance: ai_engine_0_ss
  create_hier_cell_ai_engine_0_ss [current_bd_instance .] ai_engine_0_ss

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_s2mm {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_m_axi_mm2s_data_width {64} \
   CONFIG.c_m_axis_mm2s_tdata_width {64} \
   CONFIG.c_mm2s_burst_size {8} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {20} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list \
   CONFIG.c_include_s2mm {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {20} \
 ] $axi_dma_1

  # Create instance: axi_dma_2, and set properties
  set axi_dma_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_2 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s {0} \
   CONFIG.c_include_s2mm {1} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_m_axi_s2mm_data_width {64} \
   CONFIG.c_s_axis_s2mm_tdata_width {64} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {20} \
 ] $axi_dma_2

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 axi_noc_0 ]
  set_property -dict [ list \
   CONFIG.LOGO_FILE {data/noc_mc.png} \
   CONFIG.MC_ADDR_BIT9 {BA1} \
   CONFIG.MC_INPUTCLK0_PERIOD {5000} \
   CONFIG.MC_INPUT_FREQUENCY0 {200.000} \
   CONFIG.MC_MEMORY_DEVICETYPE {UDIMMs} \
   CONFIG.NUM_CLKS {10} \
   CONFIG.NUM_MC {1} \
   CONFIG.NUM_MCP {4} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {11} \
 ] $axi_noc_0

  set_property -dict [ list \
   CONFIG.CATEGORY {aie} \
 ] [get_bd_intf_pins /axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5}} } \
   CONFIG.DEST_IDS {M00_AXI:0xc0} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {M00_AXI:0xc0} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {M00_AXI:0xc0} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S02_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {M00_AXI:0xc0} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /axi_noc_0/S03_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {M00_AXI:0xc0} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /axi_noc_0/S04_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 { read_bw {640} write_bw {200} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S05_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_2 { read_bw {640} write_bw {200} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S06_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_3 { read_bw {200} write_bw {640} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S07_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /axi_noc_0/S08_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /axi_noc_0/S09_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /axi_noc_0/S10_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI:S06_AXI:S07_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S08_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk7]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S09_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk8]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S10_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk9]

  # Create instance: c_counter_binary_1, and set properties
  set c_counter_binary_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_1 ]
  set_property -dict [ list \
   CONFIG.Output_Width {27} \
 ] $c_counter_binary_1

  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0 ]
  set_property -dict [ list \
   CONFIG.AUTO_PRIMITIVE {DPLL} \
   CONFIG.BANDWIDTH {OPTIMIZED} \
   CONFIG.CLKFBOUT_MULT {59} \
   CONFIG.CLKOUT1_DIVIDE {20} \
   CONFIG.CLKOUT2_DIVIDE {6} \
   CONFIG.CLKOUT3_DIVIDE {12} \
   CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
   CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
   CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
   CONFIG.CLKOUT_MBUFGCE_MODE {PERFORMANCE,PERFORMANCE,PERFORMANCE,PERFORMANCE,PERFORMANCE,PERFORMANCE,PERFORMANCE} \
   CONFIG.CLKOUT_PORT {clk_out1,clk_aie_pl,clk_ila,clk_out4,clk_out5,clk_out6,clk_out7} \
   CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
   CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {147.5,491,245,100.000,100.000,100.000,100.000} \
   CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
   CONFIG.CLKOUT_USED {true,true,true,false,false,false,false} \
   CONFIG.DIVCLK_DIVIDE {4} \
   CONFIG.PRIMITIVE_TYPE {Auto} \
   CONFIG.PRIM_IN_FREQ {199.998001} \
   CONFIG.PRIM_SOURCE {Global_buffer} \
   CONFIG.USE_CLKFB_STOPPED {false} \
   CONFIG.USE_INCLK_STOPPED {false} \
   CONFIG.USE_LOCKED {true} \
 ] $clk_wizard_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {5} \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

  # Create instance: versal_cips_0, and set properties
  set versal_cips_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:1.0 versal_cips_0 ]
  set_property -dict [ list \
   CONFIG.PMC_CRP_PL0_REF_CTRL_FREQMHZ {200} \
   CONFIG.PMC_EXTERNAL_TAMPER_ENABLE {0} \
   CONFIG.PMC_EXTERNAL_TAMPER_IO {PMC_MIO 12} \
   CONFIG.PMC_GPIO0_MIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_GPIO1_MIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
   CONFIG.PMC_GPIO_EMIO_WIDTH {1} \
   CONFIG.PMC_I2CPMC_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_I2CPMC_PERIPHERAL_IO {PMC_MIO 46 .. 47} \
   CONFIG.PMC_MIO_37_DIRECTION {out} \
   CONFIG.PMC_MIO_37_OUTPUT_DATA {high} \
   CONFIG.PMC_MIO_37_USAGE {GPIO} \
   CONFIG.PMC_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PMC_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_QSPI_PERIPHERAL_MODE {Dual Parallel} \
   CONFIG.PMC_SD1_GRP_CD_ENABLE {1} \
   CONFIG.PMC_SD1_GRP_POW_ENABLE {1} \
   CONFIG.PMC_SD1_GRP_WP_ENABLE {1} \
   CONFIG.PMC_SD1_PERIPHERAL_ENABLE {1} \
   CONFIG.PMC_SD1_PERIPHERAL_IO {PMC_MIO 26 .. 36} \
   CONFIG.PMC_SD1_SLOT_TYPE {SD 3.0} \
   CONFIG.PMC_USE_PMC_NOC_AXI0 {1} \
   CONFIG.PS_CAN0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_CAN0_PERIPHERAL_IO {PMC_MIO 38 .. 39} \
   CONFIG.PS_CAN1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_CAN1_PERIPHERAL_IO {PMC_MIO 40 .. 41} \
   CONFIG.PS_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PS_ENET0_GRP_MDIO_IO {PS_MIO 24 .. 25} \
   CONFIG.PS_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_ENET0_PERIPHERAL_IO {PS_MIO 0 .. 11} \
   CONFIG.PS_ENET1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_ENET1_PERIPHERAL_IO {PS_MIO 12 .. 23} \
   CONFIG.PS_GEN_IPI_0_ENABLE {1} \
   CONFIG.PS_GEN_IPI_1_ENABLE {1} \
   CONFIG.PS_GEN_IPI_2_ENABLE {1} \
   CONFIG.PS_GEN_IPI_3_ENABLE {1} \
   CONFIG.PS_GEN_IPI_4_ENABLE {1} \
   CONFIG.PS_GEN_IPI_5_ENABLE {1} \
   CONFIG.PS_GEN_IPI_6_ENABLE {1} \
   CONFIG.PS_GPIO2_MIO_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_I2C1_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_I2C1_PERIPHERAL_IO {PMC_MIO 44 .. 45} \
   CONFIG.PS_M_AXI_GP0_DATA_WIDTH {128} \
   CONFIG.PS_NUM_FABRIC_RESETS {1} \
   CONFIG.PS_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_UART0_PERIPHERAL_IO {PMC_MIO 42 .. 43} \
   CONFIG.PS_USB3_PERIPHERAL_ENABLE {1} \
   CONFIG.PS_USE_M_AXI_GP0 {1} \
   CONFIG.PS_USE_M_AXI_GP2 {0} \
   CONFIG.PS_USE_NOC_PS_CCI_0 {0} \
   CONFIG.PS_USE_PMCPL_CLK0 {1} \
   CONFIG.PS_USE_PS_NOC_CCI {1} \
   CONFIG.PS_USE_PS_NOC_NCI_0 {1} \
   CONFIG.PS_USE_PS_NOC_NCI_1 {1} \
   CONFIG.PS_USE_PS_NOC_RPU_0 {1} \
 ] $versal_cips_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {26} \
   CONFIG.DIN_TO {26} \
   CONFIG.DIN_WIDTH {27} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins ai_engine_0_ss/S00_AXI] [get_bd_intf_pins axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net ai_engine_0_ss_dma_rx [get_bd_intf_pins ai_engine_0_ss/dma_rx] [get_bd_intf_pins axi_dma_2/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins ai_engine_0_ss/dma_tx] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_noc_0/S05_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_MM2S [get_bd_intf_pins axi_dma_1/M_AXI_MM2S] [get_bd_intf_pins axi_noc_0/S06_AXI]
  connect_bd_intf_net -intf_net axi_dma_2_M_AXI_S2MM [get_bd_intf_pins axi_dma_2/M_AXI_S2MM] [get_bd_intf_pins axi_noc_0/S07_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_CH0_DDR4_0 [get_bd_intf_ports CH0_DDR4_0] [get_bd_intf_pins axi_noc_0/CH0_DDR4_0]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_dma_2/S_AXI_LITE] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins ai_engine_0_ss/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins ai_engine_0_ss/S_AXI1] [get_bd_intf_pins smartconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net sys_clk0_1 [get_bd_intf_ports sys_clk0] [get_bd_intf_pins axi_noc_0/sys_clk0]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PMC_NOC_AXI_0 [get_bd_intf_pins axi_noc_0/S04_AXI] [get_bd_intf_pins versal_cips_0/IF_PMC_NOC_AXI_0]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_CCI_0 [get_bd_intf_pins axi_noc_0/S00_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_CCI_0]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_CCI_1 [get_bd_intf_pins axi_noc_0/S01_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_CCI_1]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_CCI_2 [get_bd_intf_pins axi_noc_0/S02_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_CCI_2]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_CCI_3 [get_bd_intf_pins axi_noc_0/S03_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_CCI_3]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_NCI_0 [get_bd_intf_pins axi_noc_0/S08_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_NCI_0]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_NCI_1 [get_bd_intf_pins axi_noc_0/S09_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_NCI_1]
  connect_bd_intf_net -intf_net versal_cips_0_IF_PS_NOC_RPU_0 [get_bd_intf_pins axi_noc_0/S10_AXI] [get_bd_intf_pins versal_cips_0/IF_PS_NOC_RPU_0]
  connect_bd_intf_net -intf_net versal_cips_0_M_AXI_GP0 [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins versal_cips_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net ai_engine_0_ss_s00_axi_aclk [get_bd_pins ai_engine_0_ss/s00_axi_aclk] [get_bd_pins axi_noc_0/aclk5]
  connect_bd_net -net c_counter_binary_1_Q [get_bd_pins c_counter_binary_1/Q] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net clk_wizard_0_clk_aie_pl [get_bd_pins ai_engine_0_ss/clk_aie] [get_bd_pins clk_wizard_0/clk_aie_pl]
  connect_bd_net -net clk_wizard_0_clk_ila [get_bd_pins ai_engine_0_ss/clk_scope] [get_bd_pins clk_wizard_0/clk_ila]
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins ai_engine_0_ss/clk_dma] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins axi_dma_2/m_axi_s2mm_aclk] [get_bd_pins axi_dma_2/s_axi_lite_aclk] [get_bd_pins axi_noc_0/aclk6] [get_bd_pins c_counter_binary_1/CLK] [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins versal_cips_0/m_axi_gp0_aclk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins ai_engine_0_ss/aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins axi_dma_2/axi_resetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net versal_cips_0_pl_clk0 [get_bd_pins clk_wizard_0/clk_in1] [get_bd_pins versal_cips_0/pl_clk0]
  connect_bd_net -net versal_cips_0_pl_resetn0 [get_bd_ports led_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins versal_cips_0/pl_resetn0]
  connect_bd_net -net versal_cips_0_ps_pmc_noc_axi0_clk [get_bd_pins axi_noc_0/aclk4] [get_bd_pins versal_cips_0/ps_pmc_noc_axi0_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_cci_axi0_clk [get_bd_pins axi_noc_0/aclk0] [get_bd_pins versal_cips_0/ps_ps_noc_cci_axi0_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_cci_axi1_clk [get_bd_pins axi_noc_0/aclk1] [get_bd_pins versal_cips_0/ps_ps_noc_cci_axi1_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_cci_axi2_clk [get_bd_pins axi_noc_0/aclk2] [get_bd_pins versal_cips_0/ps_ps_noc_cci_axi2_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_cci_axi3_clk [get_bd_pins axi_noc_0/aclk3] [get_bd_pins versal_cips_0/ps_ps_noc_cci_axi3_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_nci_axi0_clk [get_bd_pins axi_noc_0/aclk7] [get_bd_pins versal_cips_0/ps_ps_noc_nci_axi0_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_nci_axi1_clk [get_bd_pins axi_noc_0/aclk8] [get_bd_pins versal_cips_0/ps_ps_noc_nci_axi1_clk]
  connect_bd_net -net versal_cips_0_ps_ps_noc_rpu_axi0_clk [get_bd_pins axi_noc_0/aclk9] [get_bd_pins versal_cips_0/ps_ps_noc_rpu_axi0_clk]
  connect_bd_net -net xlconstant_0_dout [get_bd_ports led_1] [get_bd_pins clk_wizard_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net xlslice_0_Dout [get_bd_ports led_0] [get_bd_pins xlslice_0/Dout]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_noc_0/S05_AXI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs axi_noc_0/S06_AXI/C2_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces axi_dma_2/Data_S2MM] [get_bd_addr_segs axi_noc_0/S07_AXI/C3_DDR_LOW0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_PMC] [get_bd_addr_segs ai_engine_0_ss/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI3] [get_bd_addr_segs ai_engine_0_ss/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI2] [get_bd_addr_segs ai_engine_0_ss/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI0] [get_bd_addr_segs ai_engine_0_ss/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0x020000000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI1] [get_bd_addr_segs ai_engine_0_ss/ai_engine_0/S00_AXI/AIE_ARRAY_0] -force
  assign_bd_address -offset 0xA4200000 -range 0x00200000 -target_address_space [get_bd_addr_spaces versal_cips_0/Data1] [get_bd_addr_segs ai_engine_0_ss/axi_dbg_hub_0/S_AXI_DBG_HUB/Mem0] -force
  assign_bd_address -offset 0xA4000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/Data1] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA4010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/Data1] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA4020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/Data1] [get_bd_addr_segs axi_dma_2/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA4030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces versal_cips_0/Data1] [get_bd_addr_segs ai_engine_0_ss/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI0] [get_bd_addr_segs axi_noc_0/S00_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI1] [get_bd_addr_segs axi_noc_0/S01_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI2] [get_bd_addr_segs axi_noc_0/S02_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_CCI3] [get_bd_addr_segs axi_noc_0/S03_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_NCI0] [get_bd_addr_segs axi_noc_0/S08_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_NCI1] [get_bd_addr_segs axi_noc_0/S09_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_PMC] [get_bd_addr_segs axi_noc_0/S04_AXI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces versal_cips_0/DATA_RPU0] [get_bd_addr_segs axi_noc_0/S10_AXI/C0_DDR_LOW0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
################################################################## 

#Set the AIE Archive file
set aie_archive ./Work/aiearchive.aieprj
if { [file exists $aie_archive] == 1 } {
   bd::util_cmd set_aie_archive $aie_archive
} else {
   common::send_msg_id "BD_TCL-2001" "CRITICAL WARNING" "The original design used the AIE archive <$aie_archive>, but it does not exist. Please check the path."
}


create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."


