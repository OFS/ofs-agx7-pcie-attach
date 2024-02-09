# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: MIT

##
## This script is invoked as the POST_MODULE_SCRIPT_FILE. It creates an SOF
## with en embedded bootloader, if an HPS is present, and then invokes the
## platform-independent post-module script.
##

set module [lindex $quartus(args) 0]
set proj [lindex $quartus(args) 1]
set rev [lindex $quartus(args) 2]

# Directory of script
set THIS_DIR [file dirname [info script]]

if [string match "quartus_asm" $module] {
   # Look in the Fitter Report to see if an HPS is present in this design.
   if {[catch {exec grep "Total.*HPS" ./output_files/ofs_top.fit.rpt | sed -r {s/.*([0-1]) \/ [0-1].*/\1/}} hps_present]} {
      post_message -type info "Error was encountered checking for HPS presence.  Perhaps fitter report was not available."
   } else {
      if {$hps_present=="1"} {
          post_message -type info ">>> HPS Detected. Creating HPS SOF. <<<"

          project_open -revision $rev $proj
          # Check for VAB Enable
          set vab_en [get_global_assignment -name ENABLE_MULTI_AUTHORITY]
          if { [string equal "ON" $vab_en ] } {
              set hexfile "$::env(BUILD_ROOT_REL)/syn/shared_config/vab_sw/u-boot-spl-dtb.hex"
              post_message -type info ">>> VAB Enabled. Using u-boot=$hexfile <<<"
          } else {
              set hexfile "$::env(BUILD_ROOT_REL)/syn/shared_config/non_vab_sw/u-boot-spl-dtb.hex"
              post_message -type info ">>> VAB Enabled. Using u-boot=$hexfile <<<"
          }
          project_close

          # After the .sof is created, the bootloader .hex must be integrated.
          # Look first in the synthesis directory
          set hexfile_exists [file exists $hexfile]
          if {!($hexfile_exists)} {
              # No instance-specific bootloader found. Look for a common version
              # in the same directory as this script.
              set hexfile "${THIS_DIR}/${hexfile}"
              set hexfile_exists [file exists $hexfile]
          }

          set no_hex_sof "./output_files/ofs_top.sof"
          set output_sof "./output_files/ofs_top_hps.sof"
          set sof_exists [file exists $no_hex_sof]

          if {$hexfile_exists && $sof_exists} {
              post_message -type info ">>> HPS SOF Generation Commencing with $hexfile <<<"
              if {[catch {qexec "quartus_pfg -c $no_hex_sof $output_sof -o hps_path=$hexfile"} result]} {
                  post_message -type error "$result  >>> HPS SOF Generation Failed. Missing $no_hex_sof or $hexfile? <<<"
                  return -code error "Script failed"
              } else {
                  post_message -type info ">>> Created HPS SOF: $output_sof <<<"
              }
          } else {
             post_message -type info "Problem Encountered: Files are missing."
             if {!($hexfile_exists)} {
                post_message -type info "  HEX file $hexfile is missing."
             }
             if {!($sof_exists)} {
                post_message -type info "  SOF file $no_hex_sof is missing."
             }
          }
       } else {
          post_message -type info "Skipping HPS SOF Creation. No HPS is present in the design."
       }
   }
}


# Invoke the platform-independent POST_MODULE_SCRIPT_FILE. Most platforms should
# run this script. It handles common tasks, such as setting the FME interface ID.
source "$::env(BUILD_ROOT_REL)/ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl"
