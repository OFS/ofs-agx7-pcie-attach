# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT


#
# EMIF interfaces passed to AFUs. These files are used by both FIM and PR builds.
#

# Board-specific definitions
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/mem_ss_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/ofs_fim_emif_axi_mm_if.sv
