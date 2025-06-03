# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="  +define+SIM_MODE \
 +define+VCD_ON \
+define+INCLUDE_PCIE_BFM \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES=\"26'd12500000\" \
 +define+BASE_AFU=\"dummy_afu\" \
 +define+RP_MAX_TAGS=64 \
 +define+SIM_MODE_NO_MSS_RST"

if [ $MSIM -eq 1 ] ; then
    DEFINES="$DEFINES +define+SIM_TIMEOUT=\"64'd10000000000\""
else
    DEFINES="$DEFINES +define+SIM_TIMEOUT=10000000000"
fi

if grep -q "INCLUDE_LOCAL_MEM" "${OFS_ROOTDIR}/sim/scripts/generated_rtl_flist_macros.f"; then
    DEFINES="$DEFINES +define+INCLUDE_LOCAL_MEM"

fi

if grep -q "INCLUDE_HBM" "${OFS_ROOTDIR}/sim/scripts/generated_rtl_flist_macros.f"; then
    DEFINES="$DEFINES +define+INCLUDE_HBM"
    # TODO: replace with generic way to qip_gen_* path
    MEM_MAP_PATH="${OFS_ROOTDIR}/sim/scripts/qip_gen_mseries-dk/ipss/mem/qip/hbm_ss/hbm_ss/sim/hbm_ss_noc_sim.inc"
    echo ${MEM_MAP_PATH}
    sed -i '/`define HBM_SS_SYSTEM_PATH hbm_ss/ s#`define HBM_SS_SYSTEM_PATH hbm_ss#`define HBM_SS_SYSTEM_PATH top_tb.DUT.local_mem_wrapper.hbm_ss_top.hbm_ss_sv.hbm_ss#' ${MEM_MAP_PATH}
fi

if grep -q "INCLUDE_DDR" "${OFS_ROOTDIR}/sim/scripts/generated_rtl_flist_macros.f"; then
    DEFINES="$DEFINES +define+INCLUDE_DDR"
fi

# If the design is F-tile devkit then disable the top row IOSSM model
if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    if [ $MSIM -eq 1 ]; then
        MSIM_OPTS=(-c top_tb -suppress 2732,7033,12023,3053 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f" -Gio_ssm/iossm_use_model=0)
        #MSIM_OPTS=(-c top_tb -suppress 7033,12023,3053,2244,2388 -do "run -all; quit -f" -Gio_ssm/iossm_use_model=0)
    else
        USER_DEFINED_ELAB_OPTIONS="$USER_DEFINED_ELAB_OPTIONS -pvalue+top_tb.DUT.local_mem_wrapper.mem_ss_top.mem_ss_sv.mem_ss.mem_ss.emif_cal_top.emif_cal_top.emif_cal.arch_inst.IOSSM_USE_MODEL=0"
    fi
fi

VLOG_SUPPRESS="8386,7033,7061,2388,2732,12003,2244"
