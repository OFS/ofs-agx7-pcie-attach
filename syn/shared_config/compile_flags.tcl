# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

if { [info exist env(OFS_BUILD_TAG_NULL_HE_LB) ] } { set_global_assignment -name VERILOG_MACRO "USE_NULL_HE_LB" }
if { [info exist env(OFS_BUILD_TAG_NULL_HE_HSSI) ] } { set_global_assignment -name VERILOG_MACRO "USE_NULL_HE_HSSI"}
if { [info exist env(OFS_BUILD_TAG_NULL_HE_MEM) ] } { set_global_assignment -name VERILOG_MACRO "USE_NULL_HE_MEM"}
if { [info exist env(OFS_BUILD_TAG_NULL_HE_MEM_TG) ] } { set_global_assignment -name VERILOG_MACRO "USE_NULL_HE_MEM_TG"}
