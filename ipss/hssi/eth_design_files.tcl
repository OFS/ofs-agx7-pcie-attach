# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Ethernet
#--------------------

set_global_assignment -name SEARCH_PATH "$::env(BUILD_ROOT_REL)/ipss"

#-----------------
# HSSI SS IP
#-----------------
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/hssi_ss/hssi_ss.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/ptp_iopll/ptp_sample_clk_pll.ip
# Add the HSSI SS to the dictionary of IP files that will be parsed by OFS
# into the project's ofs_ip_cfg_db directory. Parameters from the configured
# IP will be turned into Verilog macros.
dict set ::ofs_ip_cfg_db::ip_db $::env(BUILD_ROOT_REL)/ipss/hssi/qip/hssi_ss/hssi_ss.ip [list hssi_ss hssi_ss_get_cfg.tcl]

#----------------------------------
# HSSI SS CSR Interconnect
#----------------------------------
set_global_assignment -name QSYS_FILE             $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/hssi_ss_csr_ic.qsys
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_clock_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_ic_reset_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_csr_mst.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_ip_slv.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/hssi/qip/axilite_ic/ip/hssi_ss_csr_ic/hssi_ss_wrapper_slv.ip

#-----------------
# QSFP Controller
#-----------------
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl.qsys
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_reset_in.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_i2c_0.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_onchip_memory2_0.ip
set_global_assignment -name IP_FILE               $::env(BUILD_ROOT_REL)/ipss/qsfp/ip/qsfp_ctrl_clock_in.ip

set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/csr_wr_logic.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/poller_fsm.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/qsfp_com.sv
set_global_assignment -name SYSTEMVERILOG_FILE    $::env(BUILD_ROOT_REL)/ipss/qsfp/rtl/qsfp_top.sv

