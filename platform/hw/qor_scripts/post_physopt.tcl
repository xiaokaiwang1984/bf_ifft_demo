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

phys_opt_design -directive AggressiveExplore

#source [pwd]/qor_scripts/waive_hold_violations_sprite.tcl
# David Pefourque
# This script can be used to report or waive Hold violations that are not on intrasites or cascaded paths
# Version: 06/02/2020
########################################################################################
## 2020.06.02 - Improved messaging in debug mode
## 2019.12.20 - Added support for '-ignore_slack 1' to ignore the slack when searching
##              for candidate paths
##            - Added support for '-slack <threshold(ns)>' to change the slack threshold when
##              searching for candidate paths (default slack threshold: 0.0)
## 2019.08.14 - Added waive_hold_violations to add Min Delay on safe intra-site/cascaded
##              Hold violations
##            - Added support for cascaded DSPs (report_hold_violations)
##            - Change command line arguments (report_hold_violations)
##            - Added new categories for safe/unsafe intra-site/cascaded Hold violations
##              (report_hold_violations)
##            - Changed the default number of paths to 10000 (report_hold_violations)
##            - Code refactorization
## 2019.05.21 - Initial release
########################################################################################

# report_hold_violations [-prefix <prefix>] [-max <max_paths>]
#     Default: <prefix> = hold
#              <max_paths> = 10000
# If <max_paths>=-1 then report_timing_summary is run to extract the number
# of failing endpoints for Hold and report_hold_violations is run on all
# the failing endpoints.
#
# E.g: report_hold_violations -prefix hold -max 300

# waive_hold_violations [-max <max_paths>]
#     Default: <max_paths> = 10000
# If <max_paths>=-1 then report_timing_summary is run to extract the number
# of failing endpoints for Hold and waive_hold_violations is run on all
# the failing endpoints.
#
# E.g: waive_hold_violations -max 300

# Force analysis on DSPs:
#   set dsps [get_cells -hier -filter {IS_PRIMITIVE && PRIMITIVE_SUBGROUP==DSP}] ; llength $dsps
#   set paths [get_timing_paths -hold -from $dsps -to $dsps -slack_less_than 0.0 -max_paths 1000 -nworst 1]
#   # Timing paths passed through reference (not $paths)
#   report_hold_violations -paths paths

proc find_hold_violations { &paths &db args } {

  upvar 1 ${&paths} paths
  upvar 1 ${&db} db

  array set defaults [list \
      -verbose 0 \
      -debug 0 \
      -uncertainty 1 \
    ]
  array set options [array get defaults]
  array set options $args

  set start [clock seconds]
  # Only consider paths with user uncertainty
  if {$options(-uncertainty)} {
    set FAILING_HOLD_PATHS [filter $paths {USER_UNCERTAINTY != {}}]
    puts " -I- find_hold_violations: [llength $FAILING_HOLD_PATHS] failing hold paths considered (with user uncertainty)"
#     set FAILING_HOLD_PATHS [filter $paths {(USER_UNCERTAINTY != {}) && (USER_UNCERTAINTY != 0)}]
  } else {
    set FAILING_HOLD_PATHS $paths
  }

  if {$options(-debug)} {
    puts " -D- find_hold_violations: [llength [filter $paths {USER_UNCERTAINTY == {}}]] failing hold paths without user uncertainty"
    puts " -D- find_hold_violations: [llength [filter $paths {USER_UNCERTAINTY != {}}]] failing hold paths with user uncertainty"
  }

  set sps [get_property -quiet STARTPOINT_PIN $FAILING_HOLD_PATHS]
  set eps [get_property -quiet ENDPOINT_PIN $FAILING_HOLD_PATHS]
  set slacks [get_property -quiet SLACK $FAILING_HOLD_PATHS]
  set uncertainties [get_property -quiet USER_UNCERTAINTY $FAILING_HOLD_PATHS]
  # Intra-site paths that have a negative slack caused by the user clock uncertainty: ok to waive
  catch {unset arrIntOK}
  # Intra-site paths that have a negative slack that is not entirely caused by the user clock uncertainty: shouldn't be waived
  catch {unset arrInt}
  # Cascaded paths that have a negative slack caused by the user clock uncertainty: ok to waive
  catch {unset arrCasOK}
  # Cascaded paths that have a negative slack that is not entirely caused by the user clock uncertainty: shouldn't be waived
  catch {unset arrCas}
  catch {unset arrVio}
  set arrIntOK(-) [list]
  set arrInt(-) [list]
  set arrCasOK(-) [list]
  set arrCas(-) [list]
  set arrVio(-) [list]
  set idx -1
  foreach PATH $FAILING_HOLD_PATHS {
    incr idx
    set sp [lindex $sps $idx]
    set ep [lindex $eps $idx]
    # Get the absolute value of the path slack to make it easier to compare to the user clock uncertainty
    set slack [expr abs([lindex $slacks $idx])]
    set uncertainty [lindex $uncertainties $idx]
    set NETS [get_nets -of $PATH]
    if {[lsort -unique [get_property -quiet ROUTE_STATUS $NETS]] == "INTRASITE"} {
      # Intra-site path
      if {$options(-verbose)} { puts "Failing hold path ([get_property -quiet SLACK $PATH]) $PATH is INTRASITE" }
      set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
      if {$slack <= $uncertainty} {
        # Safe
        lappend arrIntOK($key) $PATH
        lappend arrIntOK(-) $PATH
      } else {
        # Unsafe
        lappend arrInt($key) $PATH
        lappend arrInt(-) $PATH
      }
    } elseif {[llength $NETS] == 1} {
      # Single net: verify the endpoint pin name
      switch -regexp -- [get_property -quiet REF_PIN_NAME $ep] {
        {^ACIN.+$} -
        {^BCIN.+$} -
        {^PCIN.+$} -
        {^CARRYCAS.+$} -
        {^CAS.+$} {
          # Cascaded path
          set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
          if {$slack <= $uncertainty} {
            # Safe
            lappend arrCasOK($key) $PATH
            lappend arrCasOK(-) $PATH
          } else {
            # Unsafe
            lappend arrCas($key) $PATH
            lappend arrCas(-) $PATH
          }
        }
        default {
          # Valid hold violation
          if {$options(-verbose)} { puts "Failing hold path ([get_property -quiet SLACK $PATH]) $PATH is not INTRASITE" }
          set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
          lappend arrVio($key) $PATH
          lappend arrVio(-) $PATH
        }
      }
    } else {
      # Multiple nets
      set CELLS [get_cells -quiet -of $PATH]
      if {([llength [lsort -unique [get_property -quiet PARENT $CELLS]]] == 2) && ([lsort -unique [get_property -quiet PRIMITIVE_SUBGROUP $CELLS]] == {DSP})} {
        # The path is made of 2 different DSP macros
        # If one of the ACIN/BCIN/CARRYCASCIN/PCIN is found on the path, it means that the 2 DSPs macros are cascaded
        set PINS [get_property -quiet BUS_NAME [get_pins -quiet -of $PATH]]
        if {[regexp {(ACIN|BCIN|CARRYCASCIN|PCIN)} $PINS]} {
          # The 2 DSPs macros are cascaded
          set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
          if {$slack <= $uncertainty} {
            # Safe
            lappend arrCasOK($key) $PATH
            lappend arrCasOK(-) $PATH
          } else {
            # Unsafe
            lappend arrCas($key) $PATH
            lappend arrCas(-) $PATH
          }
        } else {
          # The 2 DSPs macros are not cascaded -> valid hold violation
          if {$options(-verbose)} { puts "Failing hold path ([get_property -quiet SLACK $PATH]) $PATH is not INTRASITE" }
          set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
          lappend arrVio($key) $PATH
          lappend arrVio(-) $PATH
        }
      } else {
        # Valid hold violation
        if {$options(-verbose)} { puts "Failing hold path ([get_property -quiet SLACK $PATH]) $PATH is not INTRASITE" }
        set key [get_property -quiet REF_NAME $sp]/[get_property -quiet REF_PIN_NAME $sp]->[get_property -quiet REF_NAME $ep]/[regsub {\[[0-9]+\]$} [get_property -quiet REF_PIN_NAME $ep] {}]
        lappend arrVio($key) $PATH
        lappend arrVio(-) $PATH
      }
    }
  }

  set db(arrVio)   [array get arrVio]
  set db(arrCasOK) [array get arrCasOK]
  set db(arrCas)   [array get arrCas]
  set db(arrIntOK) [array get arrIntOK]
  set db(arrInt)   [array get arrInt]

  set end [clock seconds]
  if {$options(-debug)} {
    puts " -D- find_hold_violations completed in [expr $end - $start] seconds"
  }
  return -code ok
}

proc report_hold_violations { args } {

  if {$args != {}} {
    puts " -I- report_hold_violations: $args"
  }

  array set defaults [list \
      -verbose 0 \
      -debug 0 \
      -uncertainty 1 \
      -prefix {hold} \
      -max 10000 \
      -file 1 \
      -gui 1 \
      -paths {} \
      -slack 0.0 \
      -ignore_slack 0 \
    ]
  array set options [array get defaults]
  array set options $args

  # Paths passed by reference: &paths -> variable name in caller space
  set &paths $options(-paths)
  upvar 1 ${&paths} paths

  set prefix $options(-prefix)
  set max $options(-max)
  set uncertainty $options(-uncertainty)
  set verbose $options(-verbose)
  set debug $options(-debug)
  set start [clock seconds]

  if {![info exists paths]} {
    set paths {}
  }

  if {$paths != {}} {
    puts " -I- report_hold_violations: using user timing paths"
    set FAILING_HOLD_PATHS $paths
  } elseif {$max == -1} {
    puts " -I- report_hold_violations: running report_timing_summary"
    set starttmp [clock seconds]
    set report [report_timing_summary -quiet -no_check_timing -no_detailed_paths -return_string]
    set endtmp [clock seconds]
    if {$options(-debug)} {
      puts " -D- report_timing_summary completed in [expr $endtmp - $starttmp] seconds"
    }
    set report [split $report \n]
    if {[set i [lsearch -regexp $report {Design Timing Summary}]] != -1} {
       foreach {wns tns tnsFallingEp tnsTotalEp whs ths thsFallingEp thsTotalEp wpws tpws tpwsFailingEp tpwsTotalEp} [regexp -inline -all -- {\S+} [lindex $report [expr $i + 6]]] { break }
    }
    if {[info exist thsFallingEp] && ($thsFallingEp != 0)} {
      puts " -I- report_hold_violations: $thsFallingEp failing Hold endpoints extracted from report_timing_summary"
      set starttmp [clock seconds]
      if {$options(-ignore_slack)} {
        set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -max_paths $thsFallingEp -nworst 1]
      } else {
        set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than $options(-slack) -max_paths $thsFallingEp -nworst 1]
      }
      set endtmp [clock seconds]
      if {$options(-debug)} {
        puts " -D- get_timing_paths completed in [expr $endtmp - $starttmp] seconds"
      }
#       set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $thsFallingEp -nworst 1]
    } else {
      puts " -I- report_hold_violations: no failing Hold path found"
      return -code ok
    }
  } else {
    set starttmp [clock seconds]
    if {$options(-ignore_slack)} {
      set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -max_paths $max -nworst 1]
    } else {
      set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than $options(-slack) -max_paths $max -nworst 1]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} {
      puts " -D- get_timing_paths completed in [expr $endtmp - $starttmp] seconds"
    }
#     set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $max -nworst 1]
  }
#   set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $max -nworst 1]

  puts " -I- report_hold_violations: [llength $FAILING_HOLD_PATHS] failing hold paths found"

  catch {unset db}
  catch {unset arrIntOK}
  catch {unset arrInt}
  catch {unset arrCasOK}
  catch {unset arrCas}
  catch {unset arrVio}
  find_hold_violations FAILING_HOLD_PATHS db -uncertainty $uncertainty -verbose $verbose -debug $debug
  array set arrIntOK $db(arrIntOK)
  array set arrInt $db(arrInt)
  array set arrCasOK $db(arrCasOK)
  array set arrCas $db(arrCas)
  array set arrVio $db(arrVio)

  puts " -I- report_hold_violations: [llength $arrVio(-)] failing hold paths are real violations"
  puts " -I- report_hold_violations: [llength $arrCasOK(-)] failing hold paths that are safe to waive (CASCADED)"
  puts " -I- report_hold_violations: [llength $arrCas(-)] failing hold paths that are UNSAFE to waive (CASCADED)"
  puts " -I- report_hold_violations: [llength $arrIntOK(-)] failing hold paths that are safe to waive (INTRASITE)"
  puts " -I- report_hold_violations: [llength $arrInt(-)] failing hold paths that are UNSAFE to waive (INTRASITE)"

  if {[llength [array names arrCasOK]] > 1} {
    set starttmp [clock seconds]
    puts "\n -I- report_hold_violations: safe cascaded violations summary:"
    foreach r [lsort [array names arrCasOK]] {
      if {$r == {-}} { continue }
      puts [format "%10s = %s" [llength $arrCasOK($r)] $r]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- safe cascaded violations summary completed in [expr $endtmp - $starttmp] seconds" }
  }

  if {[llength [array names arrCas]] > 1} {
    set starttmp [clock seconds]
    puts "\n -I- report_hold_violations: UNSAFE cascaded violations summary:"
    foreach r [lsort [array names arrCas]] {
      if {$r == {-}} { continue }
      puts [format "%10s = %s" [llength $arrCas($r)] $r]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- UNSAFE cascaded violations summary completed in [expr $endtmp - $starttmp] seconds" }
  }

  if {[llength [array names arrIntOK]] > 1} {
    set starttmp [clock seconds]
    puts "\n -I- report_hold_violations: safe intra-site violations summary:"
    foreach r [lsort [array names arrIntOK]] {
      if {$r == {-}} { continue }
      puts [format "%10s = %s" [llength $arrIntOK($r)] $r]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- safe intra-site violations summary completed in [expr $endtmp - $starttmp] seconds" }
  }

  if {[llength [array names arrInt]] > 1} {
    set starttmp [clock seconds]
    puts "\n -I- report_hold_violations: UNSAFE intra-site violations summary:"
    foreach r [lsort [array names arrInt]] {
      if {$r == {-}} { continue }
      puts [format "%10s = %s" [llength $arrInt($r)] $r]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- UNSAFE intra-site violations summary completed in [expr $endtmp - $starttmp] seconds" }
  }

  if {[llength [array names arrVio]] > 1} {
    set starttmp [clock seconds]
    puts "\n -I- report_hold_violations: Hold violations summary:"
    foreach r [lsort [array names arrVio]] {
      if {$r == {-}} { continue }
      puts [format "%10s = %s" [llength $arrVio($r)] $r]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- Hold violations summary completed in [expr $endtmp - $starttmp] seconds" }
  }

  if {$options(-gui)} {
    report_timing -quiet -of $arrIntOK(-) -name "${prefix} - safe intrasites ([llength $arrIntOK(-)])"
    report_timing -quiet -of $arrInt(-) -name "${prefix} - unsafe intrasites ([llength $arrInt(-)])"
    report_timing -quiet -of $arrCasOK(-) -name "${prefix} - safe cascaded ([llength $arrCasOK(-)])"
    report_timing -quiet -of $arrCas(-) -name "${prefix} - unsafe cascaded ([llength $arrCas(-)])"
    report_timing -quiet -of $arrVio(-) -name "${prefix} - violations ([llength $arrVio(-)])"
  }

  if {$options(-file)} {
    puts ""
    if {[llength $arrIntOK(-)]} {
      report_timing -quiet -of $arrIntOK(-) -file ${prefix}_intrasites_safe.rpt
      puts " -I- report_hold_violations: generated file [file normalize ${prefix}_intrasites_safe.rpt]"
    }
    if {[llength $arrInt(-)]} {
      report_timing -quiet -of $arrInt(-) -file ${prefix}_intrasites_unsafe.rpt
      puts " -I- report_hold_violations: generated file [file normalize ${prefix}_intrasites_unsafe.rpt]"
    }
    if {[llength $arrCasOK(-)]} {
      report_timing -quiet -of $arrCasOK(-) -file ${prefix}_cascaded_safe.rpt
      puts " -I- report_hold_violations: generated file [file normalize ${prefix}_cascaded_safe.rpt]"
    }
    if {[llength $arrCas(-)]} {
      report_timing -quiet -of $arrCas(-) -file ${prefix}_cascaded_unsafe.rpt
      puts " -I- report_hold_violations: generated file [file normalize ${prefix}_cascaded_unsafe.rpt]"
    }
    if {[llength $arrVio(-)]} {
      report_timing -quiet -of $arrVio(-) -file ${prefix}_violations.rpt
      puts " -I- report_hold_violations: generated file [file normalize ${prefix}_violations.rpt]"
    }
  }

  set end [clock seconds]
  puts "\n -I- report_hold_violations completed in [expr $end - $start] seconds"
  return -code ok
}

proc waive_hold_violations { args } {

  if {$args != {}} {
    puts " -I- waive_hold_violations: $args"
  }

  array set defaults [list \
      -verbose 0 \
      -debug 0 \
      -uncertainty 1 \
      -max 10000 \
      -paths {} \
      -slack 0.0 \
      -ignore_slack 0 \
    ]
  array set options [array get defaults]
  array set options $args

  # Paths passed by reference: &paths -> variable name in caller space
  set &paths $options(-paths)
  upvar 1 ${&paths} paths

  set max $options(-max)
  set uncertainty $options(-uncertainty)
  set verbose $options(-verbose)
  set debug $options(-debug)
  set start [clock seconds]

  if {![info exists paths]} {
    set paths {}
  }

  if {$paths != {}} {
    puts " -I- waive_hold_violations: using user timing paths"
    set FAILING_HOLD_PATHS $paths
  } elseif {$max == -1} {
    puts " -I- waive_hold_violations: running report_timing_summary"
    set starttmp [clock seconds]
    set report [report_timing_summary -quiet -no_check_timing -no_detailed_paths -return_string]
    set endtmp [clock seconds]
    if {$options(-debug)} {
      puts " -D- report_timing_summary completed in [expr $endtmp - $starttmp] seconds"
    }
    set report [split $report \n]
    if {[set i [lsearch -regexp $report {Design Timing Summary}]] != -1} {
       foreach {wns tns tnsFallingEp tnsTotalEp whs ths thsFallingEp thsTotalEp wpws tpws tpwsFailingEp tpwsTotalEp} [regexp -inline -all -- {\S+} [lindex $report [expr $i + 6]]] { break }
    }
    if {[info exist thsFallingEp] && ($thsFallingEp != 0)} {
      puts " -I- waive_hold_violations: $thsFallingEp failing Hold endpoints extracted from report_timing_summary"
      set starttmp [clock seconds]
      if {$options(-ignore_slack)} {
        set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -max_paths $thsFallingEp -nworst 1]
      } else {
        set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than $options(-slack) -max_paths $thsFallingEp -nworst 1]
      }
      set endtmp [clock seconds]
      if {$options(-debug)} {
        puts " -D- get_timing_paths completed in [expr $endtmp - $starttmp] seconds"
      }
#       set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $thsFallingEp -nworst 1]
    } else {
      puts " -I- waive_hold_violations: no failing Hold path found"
      return -code ok
    }
  } else {
    set starttmp [clock seconds]
    if {$options(-ignore_slack)} {
      set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -max_paths $max -nworst 1]
    } else {
      set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than $options(-slack) -max_paths $max -nworst 1]
    }
    set endtmp [clock seconds]
    if {$options(-debug)} {
      puts " -D- get_timing_paths completed in [expr $endtmp - $starttmp] seconds"
    }
#     set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $max -nworst 1]
  }
#   set FAILING_HOLD_PATHS [get_timing_paths -quiet -hold -slack_less_than 0.0 -max_paths $max -nworst 1]

  puts " -I- waive_hold_violations: [llength $FAILING_HOLD_PATHS] failing hold paths found"

  catch {unset db}
  catch {unset arrIntOK}
  catch {unset arrInt}
  catch {unset arrCasOK}
  catch {unset arrCas}
  catch {unset arrVio}
  find_hold_violations FAILING_HOLD_PATHS db -uncertainty $uncertainty -verbose $verbose -debug $debug
  array set arrIntOK $db(arrIntOK)
  array set arrInt $db(arrInt)
  array set arrCasOK $db(arrCasOK)
  array set arrCas $db(arrCas)
  array set arrVio $db(arrVio)

  puts " -I- waive_hold_violations: [llength $arrVio(-)] failing hold paths are real violations"
  puts " -I- waive_hold_violations: [llength $arrCasOK(-)] failing hold paths that are safe to waive (CASCADED)"
  puts " -I- waive_hold_violations: [llength $arrCas(-)] failing hold paths that are UNSAFE to waive (CASCADED)"
  puts " -I- waive_hold_violations: [llength $arrIntOK(-)] failing hold paths that are safe to waive (INTRASITE)"
  puts " -I- waive_hold_violations: [llength $arrInt(-)] failing hold paths that are UNSAFE to waive (INTRASITE)"

  # Adding Min Delay constraint on safe path endpoint
  if {[llength $arrCasOK(-)]} {
    set starttmp [clock seconds]
    catch {unset arr}
    foreach p [get_property -quiet ENDPOINT_PIN $arrCasOK(-)] u [get_property -quiet USER_UNCERTAINTY $arrCasOK(-)] {
      lappend arr($u) $p
    }
    foreach u [lsort -real [array names arr]] {
      puts " -I- waive_hold_violations: Added Min Delay constraint of $u on [llength $arr($u)] safe endpoints (CASCADED)"
      # Change the sign to convert the user uncertainty to the Min Delay value
      set_min_delay [expr -1.0 * $u] -to $arr($u)
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- Adding Min Delay constraint on safe path endpoint completed in [expr $endtmp - $starttmp] seconds" }
  }

  # Adding Min Delay constraint on unsafe path endpoint
  if {[llength $arrCas(-)]} {
    set starttmp [clock seconds]
    catch {unset arr}
    foreach p [get_property -quiet ENDPOINT_PIN $arrCas(-)] u [get_property -quiet USER_UNCERTAINTY $arrCas(-)] {
      lappend arr($u) $p
    }
    foreach u [lsort -real [array names arr]] {
      puts " -I- waive_hold_violations: Added Min Delay constraint of $u on [llength $arr($u)] unsafe endpoints (CASCADED)"
      # Change the sign to convert the user uncertainty to the Min Delay value
      set_min_delay [expr -1.0 * $u] -to $arr($u)
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- Adding Min Delay constraint on unsafe path endpoint completed in [expr $endtmp - $starttmp] seconds" }
  }

  # Adding Min Delay constraint on safe path endpoint
  if {[llength $arrIntOK(-)]} {
    set starttmp [clock seconds]
    catch {unset arr}
    foreach p [get_property -quiet ENDPOINT_PIN $arrIntOK(-)] u [get_property -quiet USER_UNCERTAINTY $arrIntOK(-)] {
      lappend arr($u) $p
    }
    foreach u [lsort -real [array names arr]] {
      puts " -I- waive_hold_violations: Added Min Delay constraint of $u on [llength $arr($u)] safe endpoints (INTRASITE)"
      # Change the sign to convert the user uncertainty to the Min Delay value
      set_min_delay [expr -1.0 * $u] -to $arr($u)
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- Adding Min Delay constraint on safe path endpoint completed in [expr $endtmp - $starttmp] seconds" }
  }

  # Adding Min Delay constraint on unsafe path endpoint
  if {[llength $arrInt(-)]} {
    set starttmp [clock seconds]
    catch {unset arr}
    foreach p [get_property -quiet ENDPOINT_PIN $arrInt(-)] u [get_property -quiet USER_UNCERTAINTY $arrInt(-)] {
      lappend arr($u) $p
    }
    foreach u [lsort -real [array names arr]] {
      puts " -I- waive_hold_violations: Added Min Delay constraint of $u on [llength $arr($u)] unsafe endpoints (INTRASITE)"
      # Change the sign to convert the user uncertainty to the Min Delay value
      set_min_delay [expr -1.0 * $u] -to $arr($u)
    }
    set endtmp [clock seconds]
    if {$options(-debug)} { puts " -D- Adding Min Delay constraint on unsafe path endpoint completed in [expr $endtmp - $starttmp] seconds" }
  }

  set end [clock seconds]
  puts " -I- waive_hold_violations completed in [expr $end - $start] seconds"
  return -code ok
}
waive_hold_violations -max -1 -debug 1


