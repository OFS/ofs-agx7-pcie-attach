# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains PR specific Quartus assignments
#------------------------------------
set BOTTOM_MEM_REGION "X0 Y0 X222 Y17"

if { [info exist env(OFS_BUILD_TAG_FLAT) ] } { 
    post_message "Compiling Flat design..." 
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
    set_instance_assignment -name PLACE_REGION "X240 Y0 X341 Y8;X223 Y0 X239 Y24;X342 Y0 X343 Y211;X240 Y9 X246 Y24;X247 Y9 X341 Y39;X223 Y25 X246 Y39;X113 Y37 X222 Y39;X83 Y37 X112 Y169;X113 Y40 X200 Y169;X201 Y40 X341 Y211" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
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
