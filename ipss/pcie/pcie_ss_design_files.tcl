# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#--------------------
# Packages
#--------------------
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/rtl/ofs_fim_pcie_pkg.sv

#--------------------
# PCIE IP
#--------------------
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/pcie/qip/pcie_ss.ip
# Add the PCIe SS to the dictionary of IP files that will be parsed by OFS
# into the project's ofs_ip_cfg_db directory. Parameters from the configured
# IP will be turned into Verilog macros.
dict set ::ofs_ip_cfg_db::ip_db $::env(BUILD_ROOT_REL)/ipss/pcie/qip/pcie_ss.ip [list pcie_ss pcie_ss_get_cfg.tcl]
