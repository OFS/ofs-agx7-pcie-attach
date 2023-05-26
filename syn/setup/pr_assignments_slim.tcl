# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains PR specific Quartus assignments
#------------------------------------

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
    set_instance_assignment -name PARTITION green_region -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name PLACE_REGION "X240 Y0 X341 Y8;X223 Y0 X236 Y17;X237 Y0 X239 Y24;X342 Y0 X343 Y211;X240 Y9 X246 Y24;X247 Y9 X341 Y39;X77 Y18 X236 Y19;X74 Y18 X76 Y192;X199 Y20 X236 Y24;X113 Y20 X198 Y31;X77 Y20 X112 Y192;X199 Y25 X219 Y31;X220 Y25 X246 Y39;X113 Y32 X219 Y39;X113 Y40 X273 Y179;X274 Y40 X341 Y211;X113 Y180 X259 Y185;X260 Y180 X273 Y211;X113 Y186 X258 Y192;X259 Y186 X259 Y211;X201 Y193 X258 Y211" -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_PLACE_REGION ON -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name ROUTE_REGION "X0 Y0 X343 Y211" -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_ROUTE_REGION OFF -to afu_top|port_gasket|pr_slot|afu_main
    set_instance_assignment -name REGION_NAME afu_top|port_gasket|pr_slot|afu_main -to afu_top|port_gasket|pr_slot|afu_main

}
