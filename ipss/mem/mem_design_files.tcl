# Copyright (C) 2023 Intel Corporation.
# SPDX-License-Identifier: MIT

# MemSS IP
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/mem_ss/mem_ss_fm.ip
# Used only in simulation. Loading it here adds ed_sim_mem to the simulation environment.
# It is not instantiated on HW.
set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/ed_sim/ed_sim_mem.ip

# Add the Memory Subsystem to the dictionary of IP files that will be parsed by OFS
# into the project's ofs_ip_cfg_db directory. Parameters from the configured
# IP will be turned into Verilog macros.
dict set ::ofs_ip_cfg_db::ip_db $::env(BUILD_ROOT_REL)/ipss/mem/qip/mem_ss/mem_ss_fm.ip [list mem_ss mem_ss_get_cfg.tcl]
