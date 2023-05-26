# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

# Common files
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/rst_hs.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/mem_ss_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/ofs_fim_emif_axi_mm_if.sv

# Platform specific files
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/mem_ss_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/ofs_fim_emif_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/mem_ss_top.sv

# MemSS CSR fabric
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/axilite_ic/ip/emif_csr_ic/emif_csr_ic_clock_in.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/axilite_ic/ip/emif_csr_ic/emif_csr_ic_reset_in.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/axilite_ic/ip/emif_csr_ic/emif_csr_slv.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/axilite_ic/ip/emif_csr_ic/mem_ss_csr_mst.ip
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/axilite_ic/ip/emif_csr_ic/emif_dfh_mst.ip
set_global_assignment -name QSYS_FILE ../ip_lib/ipss/mem/qip/axilite_ic/emif_csr_ic.qsys

# MemSS IP
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/mem_ss/mem_ss_fm.ip
# Used only in simulation. Loading it here adds ed_sim_mem to the simulation environment.
# It is not instantiated on HW.
set_global_assignment -name IP_FILE ../ip_lib/ipss/mem/qip/ed_sim/ed_sim_mem.ip
