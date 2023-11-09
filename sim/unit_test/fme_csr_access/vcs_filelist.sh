# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# <QSYS_FILELIST_BEGIN>
# <QSYS_FILELIST_END>

VCS_FILELIST="-v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v \
-v $QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v \
-v $QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v \
-v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v \
$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/tennm_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/synopsys/tennm_atoms_ncrypt.sv \
$THE_PLATFORM/sim/scripts/qip_gen/ofs-common/src/common/fme_id_rom/fme_id_rom/rom_1port_2021/sim/fme_id_rom_rom_1port_2021_dhuwnui.v
$THE_PLATFORM/sim/scripts/qip_gen/ofs-common/src/common/fme_id_rom/fme_id_rom/sim/fme_id_rom.v \
$OFS_ROOTDIR/ofs-common/src/common/includes/ofs_csr_pkg.sv \
$OFS_ROOTDIR/ofs-common/src/fpga_family/agilex/pcie_ss/ofs_fim_pcie_hdr_def.sv \
$THE_PLATFORM/src/includes/ofs_fim_cfg_pkg.sv \
$OFS_ROOTDIR/ofs-common/src/common/lib/mux/pf_vf_mux_pkg.sv \
$OFS_ROOTDIR/src/afu_top/mux/top_cfg_pkg.sv \
$OFS_ROOTDIR/ipss/pcie/rtl/ofs_fim_pcie_pkg.sv \
$OFS_ROOTDIR/ofs-common/src/common/fme/fme_csr_pkg.sv \
$OFS_ROOTDIR/ofs-common/src/common/includes/ofs_fim_if_pkg.sv \
$OFS_ROOTDIR/ofs-common/src/common/includes/ofs_fim_pwrgoodn_if.sv \
$OFS_ROOTDIR/ofs-common/src/common/includes/ofs_fim_axi_mmio_if.sv \
$OFS_ROOTDIR/ofs-common/src/common/fme/fme_csr_io_if.sv \
$OFS_ROOTDIR/ofs-common/src/common/fme/fme_csr.sv \
-F $OFS_ROOTDIR/sim/scripts/generated_rtl_flist_incdirs.f"
