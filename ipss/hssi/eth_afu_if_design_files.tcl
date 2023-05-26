# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT


#
# Ethernet interfaces passed to AFUs. These files are used by both FIM and PR builds.
#

set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_plat_defines.svh
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_plat_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_avst_if_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/inc/ofs_fim_eth_avst_if.sv

# These modules are used in mapping FIM interfaces to Platform Interface Manager (PIM)
# interfaces, so are included here because they are needed during construction of the
# PR environment.
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/hssi/rtl/lib/ofs_fim_hssi_axis_connect.sv
