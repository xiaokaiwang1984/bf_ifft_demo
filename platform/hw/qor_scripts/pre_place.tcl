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

#source [pwd]/qor_scripts/prohibitCascBramAcrossRbrk.tcl
#source [pwd]/qor_scripts/prohibitCascUramAcrossRbrk.tcl
#source [pwd]/qor_scripts/prohibitCascDspAcrossRbrk.tcl

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#source [pwd]/qor_scripts/prohibit.tcl

catch {unset ys}
foreach cr [get_clock_regions {X*Y1 X*Y2 X*Y3}] {
  set bram [get_sites -quiet -filter NAME=~RAMB36_X*Y* -of $cr]
  if {$bram == {}} { continue }
  lappend ys [lindex [lsort -integer -increasing [regsub -all {RAMB36_X\d+Y(\d+)} $bram {\1}]] end]
}
foreach y $ys {
  set_property PROHIBIT FALSE [get_sites RAMB36_X*Y$y]
  set_property PROHIBIT FALSE [get_sites RAMB18_X*Y[expr 2 * $y]]
  set_property PROHIBIT FALSE [get_sites RAMB18_X*Y[expr 2 * $y + 1]]
}

catch {unset ys}
foreach cr [get_clock_regions {X*Y1 X*Y2 X*Y3}] {
  set uram [get_sites -quiet -filter NAME=~URAM288_X*Y* -of $cr]
  if {$uram == {}} { continue }
  lappend ys [lindex [lsort -integer -increasing [regsub -all {URAM288_X\d+Y(\d+)} $uram {\1}]] end]
}
foreach y $ys {
  set_property PROHIBIT FALSE [get_sites URAM288_X*Y$y]
}

catch {unset ys}
foreach cr [get_clock_regions {X*Y1 X*Y2 X*Y3}] {
  set dsp [get_sites -quiet -filter NAME=~DSP_X*Y* -of $cr]
  if {$dsp == {}} { continue }
  lappend ys [lindex [lsort -integer -increasing [regsub -all {DSP_X\d+Y(\d+)} $dsp {\1}]] end]
}
foreach y $ys {
  set_property PROHIBIT FALSE [get_sites DSP*_X*Y$y]
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#source [pwd]/qor_scripts/waive_BLI_AIE_timing_violations_preplace.tcl
# Last update; 2019/09/06
# Last change: checking on AIE_PL BEL location to make sure there is a BLI site available
#
# Last update; 2019/11/20
# Last change: adding support for 128b interfaces
#
set debug 0
foreach aiePL [get_cells -quiet -hier -filter "REF_NAME=~AIE_PL_* && PRIMITIVE_LEVEL!=MACRO"] {
  set loc [get_property LOC $aiePL]
  if {$loc == ""} { if {$debug} { puts "D - Missing LOC - $aiePL" }; continue } ;# Unplace AIE_PL cell => unsafe to waive timing
  set bel [get_property BEL $aiePL]
  if {$bel == "AIE_PL.AIE_PL_S_AXIS_3"} { if {$debug} { puts "D - BEL 3 - $aiePL" }; continue } ;# No BLI register site available
  if {$bel == "AIE_PL.AIE_PL_S_AXIS_7"} { if {$debug} { puts "D - BEL 7 - $aiePL" }; continue } ;# No BLI register site available
  foreach dir {IN OUT} {
    set bliFD [get_cells -quiet -filter "REF_NAME=~FD* && BLI==TRUE" -of [get_pins -leaf -of [get_nets -filter "FLAT_PIN_COUNT==2" -of [get_pins -filter "!IS_CLOCK && DIRECTION==$dir" -of $aiePL]]]]
    if {$bliFD == {}} { if {$debug} { puts "D - no BLI FD - $dir - $aiePL" }; continue }
    set refName [get_property REF_NAME $aiePL]
    set locBel "$loc/[regsub {.*\.} $bel {}]"
    if {$dir == "IN"} {
      puts [format "INFO - Adding False Path waiver from %2s BLI registers to   $refName ($locBel) - $aiePL" [llength $bliFD]]
      set_false_path -from $bliFD -to $aiePL
    } else {
      puts [format "INFO - Adding False Path waiver to   %2s BLI registers from $refName ($locBel) - $aiePL" [llength $bliFD]]
      set_false_path -from $aiePL -to $bliFD
    }
  }
}

