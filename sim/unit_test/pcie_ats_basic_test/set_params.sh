# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

AFU_WITH_PIM="$TEST_SRC_DIR"/test_afu/hw/rtl/filelist.txt

DEFINES="+define+SIM_MODE \
 +define+VCD_ON \
 +define+INCLUDE_PCIE_BFM \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
 +define+RP_MAX_TAGS=64"

VLOG_SUPPRESS="2388,2244,2892,13276,12003,7041"

MSIM_OPTS=(-c top_tb -suppress 7033,12023 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f")
