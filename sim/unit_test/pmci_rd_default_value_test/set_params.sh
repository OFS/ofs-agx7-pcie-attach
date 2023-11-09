# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="+define+SIM_MODE \
 +define+SIM_MODE \
 +define+INCLUDE_PMCI \
 +define+SPI_LB \
 +define+VCD_ON \
+define+INCLUDE_PCIE_BFM \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
 +define+BASE_AFU=\"dummy_afu\" \
 +define+RP_MAX_TAGS=64 \
 +define+SIM_USE_PCIE_DUMMY_CSR"

NTB_OPTS="+define+VCS_ \
 +nbaopt \
 +delay_mode_zero"

VCS_SIMV_PARAMS="-cm line+cond+fsm+tgl+branch -cm_name $TEST_NAME -cm_test pmci -cm_dir ../../../regression.vdb $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -l transcript"