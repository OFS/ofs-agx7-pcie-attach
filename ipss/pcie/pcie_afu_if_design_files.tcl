# Copyright (C) 2020 Intel Corporation
# SPDX-License-Identifier: MIT

#
# PCIe interfaces passed to AFUs. These files are used by both FIM and PR builds.
#

#--------------------
# Packages
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_hdr_def.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_axis_if.sv

