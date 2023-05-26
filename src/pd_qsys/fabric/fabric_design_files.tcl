# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# design  files
#--------------------

#--------------------
# APF
#--------------------
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_achk_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_default_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_bpf_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_bpf_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_clock_bridge.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_mctp_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_pr_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_reset_bridge.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_st2mm_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_st2mm_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_uart_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/apf/apf_uart_slv.ip
set_global_assignment -name QSYS_FILE ../ip_lib/src/pd_qsys/fabric/apf.qsys

#--------------------
# BPF
#--------------------
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_default_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_apf_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_apf_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_clock_bridge.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_emif_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_fme_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_fme_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_hssi_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_pcie_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_pmci_lpbk_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_pmci_lpbk_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_pmci_mst.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_pmci_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_qsfp0_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_qsfp1_slv.ip
set_global_assignment -name IP_FILE   ../ip_lib/src/pd_qsys/fabric/ip/bpf/bpf_reset_bridge.ip
set_global_assignment -name QSYS_FILE ../ip_lib/src/pd_qsys/fabric/bpf.qsys

#--------------------
# SDC
#--------------------

