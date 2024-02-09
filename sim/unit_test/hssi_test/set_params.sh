# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

INCLUDE_HSSI_LIB=1

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
 +define+DISABLE_HE_HSSI_CRC"

HSSI_FTILE_DEFINES="+define+TIMESCALE_EN \
 +define+RTLSIM \
 +define+INTC_FUNCTIONAL \
 +define+SSM_SEQUENCE \
 +define+SPEC_FORCE \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SPEC_FORCE \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_SIMULATION \
 +define+IP7581SERDES_UXS2T1R1PGD_PIPE_FAST_SIM \
 +define+IP7581SERDES_UX_SIMSPEED \
 +define+SRC_SPEC_SPEED_UP \
 +define+__SRC_TEST__"


if [ -f $OFS_ROOTDIR/sim/scripts/generated_ftile_macros.f ]; then
  if [ $MSIM -eq 1 ]; then
    DEFINES="${DEFINES} ${HSSI_FTILE_DEFINES} +define+INCLUDE_FTILE -F ${OFS_ROOTDIR}/sim/scripts/generated_ftile_macros.f "
  else 
    DEFINES="${DEFINES} ${HSSI_FTILE_DEFINES} +define+QUARTUS_ENABLE_DPI_FORCE +define+IP7581SERDES_UX_SIMSPEED +define+INCLUDE_FTILE -F ${OFS_ROOTDIR}/sim/scripts/generated_ftile_macros.f -debug_access+all -debug_region+cell+encrypt -debug_region+cell+lib"
  fi
  cp -f ${QUARTUS_ROOTDIR}/libraries/megafunctions/f_tile_soft_reset_ctlr_ip_v1/nios2_smg_regfile.hex $SIM_DIR
  cp -f ${QUARTUS_ROOTDIR}/libraries/megafunctions/f_tile_soft_reset_ctlr_ip_v1/rst_ctrl_dram.hex $SIM_DIR
  cp -f ${QUARTUS_ROOTDIR}/libraries/megafunctions/f_tile_soft_reset_ctlr_ip_v1/rst_ctrl_iram.hex $SIM_DIR
 

  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/alt_f_hw_pkt_gen_rom_init.400G_SEG.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/eth_f_hw_pkt_gen_rom_init.400G_SEG.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/eth_f_hw_pkt_gen_rom_init.200G_SEG.hex $SIM_DIR

  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_ctrl.200G.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_ctrl.400G.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_ctrl.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_data.200G.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_data.400G.hex $SIM_DIR
  cp -f  ${OFS_ROOTDIR}/ofs-common/src/common/he_hssi/pkt_client_mac_seg/init_file_data.hex $SIM_DIR


if [ -d ${OFS_ROOTDIR}/sim/scripts/qip_gen_fseries-dk ]; then
  cp ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y0_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_fseries-dk/syn/board/fseries-dk/syn_top/support_logic/ofs_top__z1577b_x393_y0_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_fseries-dk/syn/board/fseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y166_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_fseries-dk/syn/board/fseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y166_n0.mif $SIM_DIR
fi
if [ -d ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk ]; then
  cp ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y0_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/support_logic/ofs_top__z1577b_x393_y0_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y166_n0.mif $SIM_DIR
  cp -f ${OFS_ROOTDIR}/sim/scripts/qip_gen_iseries-dk/syn/board/iseries-dk/syn_top/support_logic/ofs_top__z1577b_x5_y166_n0.mif $SIM_DIR
fi

fi

