# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES=" +define+SIM_MODE \
 +define+VCD_ON \
+define+INCLUDE_PCIE_BFM \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=26'd12500000 \
 +define+BASE_AFU=dummy_afu \
 +define+RP_MAX_TAGS=64"

if [ $MSIM -eq 1 ] ; then
    DEFINES="$DEFINES +define+SIM_TIMEOUT=\"64'd10000000000\""
else 
    DEFINES="$DEFINES +define+SIM_TIMEOUT=10000000000"
fi

if [ ! -d $OFS_ROOTDIR/sim/scripts/qip_gen_n6000 ] ; then
    DEFINES="$DEFINES +define+INCLUDE_DDR4"
fi

# If the design is F-tile devkit then disable the top row IOSSM model
if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    if [ $MSIM -eq 1 ]; then
        MSIM_OPTS=(-c top_tb -suppress 2732,7033,12023,3053 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f" -Gio_ssm/iossm_use_model=0) 
    else
        USER_DEFINED_ELAB_OPTIONS="$USER_DEFINED_ELAB_OPTIONS -pvalue+top_tb.DUT.mem_ss_top.mem_ss_inst.mem_ss.emif_cal_top.emif_cal_top.emif_cal.arch_inst.IOSSM_USE_MODEL=0"
    fi
fi

VLOG_SUPPRESS="8386,7033,7061,2388,2732,12003,2244"
