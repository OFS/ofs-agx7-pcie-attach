# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES=" +define+SIM_MODE \
 +define+VCD_ON \
+define+INCLUDE_PCIE_BFM \
 +define+INCLUDE_DDR4 \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=26'd12500000 \
 +define+BASE_AFU=dummy_afu \
 +define+RP_MAX_TAGS=64"

if [ $MSIM -eq 1 ] ; then
    DEFINES="$DEFINES +define+SIM_TIMEOUT=\"64'd10000000000\""
else 
    DEFINES="$DEFINES +define+SIM_TIMEOUT=100000000000"
fi

if [ $VCSMX -eq 1 ] ; then
    USER_DEFINED_VLOG_OPTIONS="+define+ADP_MEM"
else 
    USER_DEFINED_ELAB_OPTIONS="$USER_DEFINED_ELAB_OPTIONS +define+ADP_MEM"
fi


VLOG_SUPPRESS="8386,7033,7061,2388,2732,12003,2244"
