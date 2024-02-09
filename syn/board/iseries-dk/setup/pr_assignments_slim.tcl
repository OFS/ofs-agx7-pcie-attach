# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains PR specific Quartus assignments
#------------------------------------

if { [info exist env(OFS_BUILD_TAG_FLAT) ] } { 
    post_message "Compiling Flat design..." 
} else {

    post_message "Compiling PR Base revision..." 
    #-------------------------------
    # Specify PR Partition and turn PR ON for that partition
    #-------------------------------
    set_global_assignment -name REVISION_TYPE PR_BASE
    
    #####################################################
    # Main PR Partition -- green_region
    #####################################################
    set_instance_assignment -name PARTITION green_region -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name RESERVE_PLACE_REGION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    
    # Original
    #set_instance_assignment -name PLACE_REGION "X90 Y40 X385 Y265" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    # Version 1
    #set_instance_assignment -name PLACE_REGION "X50 Y4 X114 Y23;X334 Y4 X385 Y23;X12 Y4 X49 Y52;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y55;X90 Y53 X103 Y306;X334 Y307 X385 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    # Version 2
    #set_instance_assignment -name PLACE_REGION "X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X81 Y85 X89 Y313;X104 Y307 X309 Y313;X310 Y307 X385 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    #Version 3
    #set_instance_assignment -name PLACE_REGION "X306 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y101;X70 Y85 X89 Y313;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X306 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    # Version 4
    #set_instance_assignment -name PLACE_REGION "X143 Y4 X145 Y13;X306 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y105;X70 Y85 X89 Y313;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X295 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    # Version 5
    #set_instance_assignment -name PLACE_REGION "X306 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y94;X70 Y85 X89 Y313;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X306 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    #set_instance_assignment -name PLACE_REGION "X12 Y95 X69 Y329;X70 Y315 X305 Y329" -to pcie_wrapper
    # Version 6
    #set_instance_assignment -name PLACE_REGION "X143 Y4 X145 Y13;X295 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X146 Y13 X294 Y13;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y102;X70 Y85 X89 Y313;X69 Y103 X69 Y314;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X295 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    #set_instance_assignment -name PLACE_REGION "X12 Y103 X68 Y329;X69 Y315 X294 Y329" -to pcie_wrapper
    
    # Version 7
    #set_instance_assignment -name PLACE_REGION "X143 Y4 X145 Y13;X295 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X146 Y12 X294 Y13;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y102;X70 Y85 X89 Y313;X59 Y103 X69 Y314;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X295 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    #set_instance_assignment -name PLACE_REGION "X12 Y103 X58 Y329;X59 Y315 X294 Y329" -to pcie_wrapper
    #Version 8
    set_instance_assignment -name PLACE_REGION "X143 Y4 X145 Y13;X295 Y4 X306 Y13;X50 Y4 X142 Y23;X307 Y4 X385 Y23;X12 Y4 X49 Y52;X146 Y13 X294 Y13;X143 Y14 X306 Y23;X50 Y24 X103 Y52;X104 Y24 X385 Y306;X12 Y53 X89 Y84;X90 Y53 X103 Y313;X12 Y85 X69 Y102;X70 Y85 X89 Y313;X12 Y103 X68 Y107;X69 Y103 X69 Y314;X104 Y307 X309 Y313;X310 Y307 X385 Y329;X70 Y314 X309 Y314;X284 Y315 X309 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
    set_instance_assignment -name PLACE_REGION "X59 Y108 X68 Y314;X12 Y108 X58 Y329;X59 Y315 X283 Y329" -to pcie_wrapper
    set_instance_assignment -name RESERVE_PLACE_REGION OFF -to pcie_wrapper
    set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to pcie_wrapper
    set_instance_assignment -name REGION_NAME pcie_wrapper -to pcie_wrapper    
    set_instance_assignment -name ROUTE_REGION "X0 Y0 X385 Y329" -to afu_top|pg_afu.port_gasket|pr_slot|afu_main
        

}
