# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

if [ $MSIM -eq 1 ]; then
    DEFINES="+define+SIM_MODE \
    +define+INCLUDE_PMCI \
    +define+INCLUDE_HSSI \
    +define+DISABLE_HE_HSSI_CRC \
    +define+PMCI_QSFP \
    +define+SPI_LB \
    +define+VCD_ON \
    +define+INCLUDE_PCIE_BFM \
    +define+TOP_LEVEL_ENTITY_INSTANCE_PATH=top_tb.DUT \
    +define+SIM_USE_PCIE_GEN3X16_BFM \
    +define+SIM_PCIE_CPL_TIMEOUT \
    +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=26'd12500000 \
    +define+BASE_AFU=dummy_afu \
    +define+RP_MAX_TAGS=64 \
    +define+SIM_USE_PCIE_DUMMY_CSR"
elif [ $VCSMX -eq 1 ] ; then
    DEFINES="+define+SIM_MODE \
    +define+INCLUDE_PMCI \
    +define+INCLUDE_HSSI \
    +define+__ALTERA_STD__METASTABLE_SIM \
    +define+define+QUARTUS_ENABLE_DPI_FORCE \
    +define+IP7581SERDES_UX_SIMSPEED \
    +define+DISABLE_HE_HSSI_CRC \
    +define+PMCI_QSFP \
    +define+SPI_LB \
    +define+VCD_ON \
    +define+INCLUDE_PCIE_BFM \
    +define+TOP_LEVEL_ENTITY_INSTANCE_PATH=top_tb.DUT \
    +define+SIM_USE_PCIE_GEN3X16_BFM \
    +define+SIM_PCIE_CPL_TIMEOUT \
    +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
    +define+BASE_AFU=\"dummy_afu\" \
    +define+RP_MAX_TAGS=64 \
    +define+SIM_USE_PCIE_DUMMY_CSR"
else #VCS
    DEFINES="+define+SIM_MODE \
    +define+INCLUDE_PMCI \
    +define+INCLUDE_HSSI \
    +define+__ALTERA_STD__METASTABLE_SIM \
    +define+define+QUARTUS_ENABLE_DPI_FORCE \
    +define+IP7581SERDES_UX_SIMSPEED \
    +define+DISABLE_HE_HSSI_CRC \
    +define+PMCI_QSFP \
    +define+SPI_LB \
    +define+VCD_ON \
    +define+INCLUDE_PCIE_BFM \
    +define+TOP_LEVEL_ENTITY_INSTANCE_PATH=top_tb.DUT \
    +define+SIM_USE_PCIE_GEN3X16_BFM \
    +define+SIM_PCIE_CPL_TIMEOUT \
    +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
    +define+BASE_AFU=\"dummy_afu\" \
    +define+RP_MAX_TAGS=64 \
    +define+SIM_USE_PCIE_DUMMY_CSR"
fi

if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    DEFINES="${DEFINES} -F ${OFS_ROOTDIR}/sim/scripts/generated_ftile_macros.f"
fi

NTB_OPTS="+define+VCS_ \
+nbaopt \
+delay_mode_zero"

VCS_SIMV_PARAMS="-cm line+cond+fsm+tgl+branch -cm_name $TEST_NAME -cm_test pmci -cm_dir ../../../regression.vdb $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -l transcript"

VCS_CM_PARAMS=(-cm line+cond+fsm+tgl+branch -cm_dir simv.vdb)

VLOG_SUPPRESS="8386,7033,7061,12003,2388,2244"

cp -f $OFS_ROOTDIR/ipss/pmci/pmci_ss_nios_fw.hex ../../../../.. 
