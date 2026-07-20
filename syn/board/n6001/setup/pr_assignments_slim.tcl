# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains PR specific Quartus assignments
#------------------------------------
set BOTTOM_MEM_REGION "X0 Y0 X222 Y17"

if { [::config_env::verilog_macro_defined INCLUDE_PR] == 0 } {
    post_message "Compiling without PR region..."
} elseif { [info exist env(OFS_BUILD_TAG_FLAT) ] } {
    post_message "Compiling flat design..."
} else {

    post_message "Compiling PR Base revision with a tight(er) floorplan..."
    #-------------------------------
    # Specify PR Partition and turn PR ON for that partition
    #-------------------------------
    set_global_assignment -name REVISION_TYPE PR_BASE

    #####################################################
    # Main PR Partition -- green_region
    #####################################################
    set_instance_assignment -name PARTITION green_region -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PLACE_REGION "X197 Y2 X343 Y39;X90 Y31 X196 Y39;X79 Y31 X89 Y165;X73 Y31 X78 Y168;X37 Y31 X72 Y185;X90 Y40 X275 Y165;X276 Y40 X343 Y211;X79 Y166 X275 Y168;X73 Y169 X275 Y181;X73 Y182 X172 Y185;X173 Y182 X174 Y188;X175 Y182 X275 Y211;X37 Y186 X172 Y188;X174 Y189 X174 Y211" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name ROUTE_REGION "X0 Y0 X343 Y211" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_ROUTE_REGION OFF -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name REGION_NAME afu_top|pg_afu.port_gasket|pr_slot|afu_main -to afu_top|pg_afu.port_gasket|pr_slot|afu_main


     ## Bottom I/O row memory
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON       -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|intf_0
    set_instance_assignment -name PLACE_REGION $BOTTOM_MEM_REGION -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|intf_0

    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON       -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|msa_0
    set_instance_assignment -name PLACE_REGION $BOTTOM_MEM_REGION -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|msa_0
    
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON       -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|intf_1
    set_instance_assignment -name PLACE_REGION $BOTTOM_MEM_REGION -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|intf_1

    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON       -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|msa_1
    set_instance_assignment -name PLACE_REGION $BOTTOM_MEM_REGION -to mem_ss_top|mem_ss_fm_inst|mem_ss_fm|msa_1


}
