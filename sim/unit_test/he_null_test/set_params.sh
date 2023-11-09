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
 +define+INCLUDE_DDR4 \
 +define+SIM_MODE_NO_MSS_RST \
 +define+SIM_USE_PCIE_DUMMY_CSR \
 +define+INCLUDE_HSSI \
 +define+DISABLE_HE_HSSI_CRC \
 +define+USE_NULL_HE_LB \
 +define+USE_NULL_HE_HSSI \
 +define+USE_NULL_HE_MEM \
 +define+USE_NULL_HE_MEM_TG"

if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    DEFINES="${DEFINES} -F ${OFS_ROOTDIR}/sim/scripts/generated_ftile_macros.f"
   
   if [ $MSIM -ne 1 ] ; then
    DEFINES="$DEFINES +define+QUARTUS_ENABLE_DPI_FORCE +define+IP7581SERDES_UX_SIMSPEED -debug_access+all -debug_region+cell+encrypt -debug_region+cell+lib"
   fi

fi

if [ $MSIM -eq 1 ] ; then
    DEFINES="$DEFINES +define+SIM_TIMEOUT=\"64'd10000000000\""
else 
    DEFINES="$DEFINES +define+SIM_TIMEOUT=10000000000"
fi

# If the design is F-tile devkit then disable the top row IOSSM model
if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
    if [ $MSIM -eq 1 ]; then
        MSIM_OPTS=(-c top_tb -suppress 7033,12023,3053 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f" -Gio_ssm/iossm_use_model=0) 
    else
        USER_DEFINED_ELAB_OPTIONS="$USER_DEFINED_ELAB_OPTIONS -pvalue+top_tb.DUT.mem_ss_top.mem_ss_inst.mem_ss.emif_cal_top.emif_cal_top.emif_cal.arch_inst.IOSSM_USE_MODEL=0"
    fi
fi

VOPT_SUPPRESS=(-suppress 2732)
