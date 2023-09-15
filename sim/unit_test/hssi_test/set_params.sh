# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="+define+SIM_MODE \
 +define+VCD_ON \
 +define+INCLUDE_PCIE_BFM \
 +define+TOP_LEVEL_ENTITY_INSTANCE_PATH=top_tb.DUT \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
 +define+BASE_AFU=\"dummy_afu\" \
 +define+RP_MAX_TAGS=64 \
 +define+SIM_USE_PCIE_DUMMY_CSR \
 +define+INCLUDE_HSSI \
 +define+DISABLE_HE_HSSI_CRC \
 +define+TIMESCALE_EN \
 +define+RTLSIM \
 +define+INTC_FUNCTIONAL \
 +define+SSM_SEQUENCE \
 +define+SPEC_FORCE \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SPEC_FORCE \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SIMULATION \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_FAST_SIM \
 +define+IP7581SERDES_UX_SIMSPEED \
 +define+SRC_SPEC_SPEED_UP \
 +define+INCLUDE_PCIE_SS \
 +define+__SRC_TEST__"

if [ $MSIM -ne 1 ] ; then
    DEFINES="$DEFINES +define+define+QUARTUS_ENABLE_DPI_FORCE +define+IP7581SERDES_UX_SIMSPEED -debug_access+all -debug_region+cell+encrypt -debug_region+cell+lib"
fi

if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    DEFINES="${DEFINES} +define+INCLUDE_FTILE -F ${OFS_ROOTDIR}/sim/scripts/generated_ftile_macros.f"
    cp ${TEST_DIR}/*.hex $SIM_DIR 
    cp ${TEST_DIR}/*.mif $SIM_DIR 
fi
