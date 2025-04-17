# Copyright (C) 2024 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# HBM/NoC pin and location assignments
#
#-----------------------------------------------------------------------------
set NUM_HBM 2
set NUM_NOC_CHANNELS 8

# BOTTOM
set_location_assignment PIN_EC36 -to uib_refclk[0]
set_location_assignment PIN_EE56 -to noc_ctrl_refclk[0]

# TOP
set_location_assignment PIN_AR36 -to uib_refclk[1]
set_location_assignment PIN_AU52 -to noc_ctrl_refclk[1]

set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to uib_refclk

# Pre-selected Top and bottom edge coordinates for NoC channels
# taken from BTS reference design
set noc_xcoord {{X134 X204 X160 X242 X105 X188 X149 X215 X269 X350 X312 X376 X258 X323 X269 X365}
                {X134 X204 X160 X242 X105 X188 X149 X215 X269 X350 X312 X376 X258 X323 X269 X365}}

# Map 0 to bottom and 1 to top
set noc_ycoord {Y6 Y417}

for {set device 0} {$device < $NUM_HBM} {incr device} {
    #-----------------------------------------------------------------------------
    # NoC Logical Assignments
    #-----------------------------------------------------------------------------
    # Group Assignments

    set_instance_assignment -name NOC_GROUP NOC_${device} -to noc_${device}_ctrl|*|pll_inst -entity hbm_ss
    set_instance_assignment -name NOC_GROUP NOC_${device} -to noc_${device}_ctrl|*|ssm_inst -entity hbm_ss
    # Initiators
    set_instance_assignment -name NOC_GROUP NOC_${device} -to noc_${device}|*|iniu_*|initiator_inst_0 -entity hbm_ss
    # Targets
    set_instance_assignment -name NOC_GROUP NOC_${device} -to hbm_${device}|*|tniu_ch*|target_0.target_inst_0 -entity hbm_ss

    # Misc
    set_instance_assignment -name PRESERVE_FANOUT_FREE_WYSIWYG ON -to noc_${device}_ctrl|*|pll_inst -entity hbm_ss
    set_instance_assignment -name PRESERVE_FANOUT_FREE_WYSIWYG ON -to noc_${device}_ctrl|*|ssm_inst -entity hbm_ss


    
}
set_location_assignment NOCINITIATOR_X149_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_0|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X215_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_1|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X188_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_2|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X258_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_3|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X134_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_4|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X204_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_5|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X160_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_6|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X242_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_7|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X296_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_8|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X365_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_9|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X323_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_10|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X404_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_11|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X269_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_12|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X350_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_13|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X312_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_14|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X376_Y6_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_0|noc_0|iniu_15|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X322_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_0|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X258_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_1|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X296_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_2|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X215_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_3|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X357_Y417_N204 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_4|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X269_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_5|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X311_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_6|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X242_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_7|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X188_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_8|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X105_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_9|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X150_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_10|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X79_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_11|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X204_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_12|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X134_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_13|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X161_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_14|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCINITIATOR_X94_Y417_N202 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|noc_1|noc_1|iniu_15|initiator_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X204_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch0_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X231_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch0_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X215_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch1_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X242_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch1_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X194_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch2_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X221_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch2_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X210_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch3_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X237_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch3_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X269_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch4_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X296_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch4_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X285_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch5_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X312_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch5_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X264_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch6_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X291_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch6_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X275_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch7_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X302_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch7_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X188_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch0_ch1_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X183_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch2_ch3_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X323_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch4_ch5_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X318_Y6_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_0|hbm_0|tniu_ch6_ch7_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X248_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch0_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X221_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch0_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X237_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch1_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X210_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch1_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X258_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch2_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X231_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch2_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X242_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch3_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X215_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch3_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X183_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch4_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X156_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch4_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X167_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch5_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X140_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch5_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X188_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch6_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X161_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch6_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X177_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch7_u0|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCTARGET_X150_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch7_u1|target_0.target_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X264_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch0_ch1_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X269_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch2_ch3_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X129_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch4_ch5_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"
set_location_assignment NOCAXILITETARGET_X134_Y417_N200 -to {local_mem_wrapper|hbm_ss_top|hbm_ss_sv|hbm_ss|hbm_1|hbm_1|tniu_ch6_ch7_sb|target_0.target_lite_inst_0} -tag "Interface Planner Location Assignment"

