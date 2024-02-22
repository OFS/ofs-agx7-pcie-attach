# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT



. $OFS_ROOTDIR/sim/scripts/msim_ip_flist.sh

# <COPY_ROM_BEGIN>
cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif ./
# <COPY_ROM_END>

LIB_FILELIST="$QUARTUS_ROOTDIR/eda/sim_lib/altera_primitives.v \
$QUARTUS_ROOTDIR/eda/sim_lib/220model.v \
$QUARTUS_ROOTDIR/eda/sim_lib/sgate.v \
$QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v \
$QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/tennm_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/mentor/tennm_atoms_ncrypt.sv \
$OFS_ROOTDIR/sim/bfm/ofs_axis_bfm/host_bfm_types_pkg.sv \
$OFS_ROOTDIR/sim/bfm/ofs_axis_bfm/pfvf_def_pkg_host.sv \
$OFS_ROOTDIR/sim/bfm/ofs_axis_bfm/pfvf_def_pkg_soc.sv \
$OFS_ROOTDIR/sim/bfm/ofs_axis_bfm/pfvf_class_pkg.sv \
"

HSSI_LIB_FILELIST="$QUARTUS_ROOTDIR/eda/sim_lib/tennm_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/tennm_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/mentor/cr3v0_serdes_models_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctp_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctp_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/cta_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/cta_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctr_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctr_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctfb_hssi_atoms.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctfb_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctfb_hssi_atoms2_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctr_hssi_atoms_ncrypt.sv \
$QUARTUS_ROOTDIR/eda/sim_lib/ctrb_hssi_atoms_ncrypt.sv \
"

INC_DIR="+incdir+$OFS_ROOTDIR/ofs-common/src/common/includes/ \
+incdir+$OFS_ROOTDIR/src/includes/ \
+incdir+$OFS_ROOTDIR/ipss/hssi/rtl/inc/"

RTL_FILELIST="-F $OFS_ROOTDIR/sim/scripts/generated_rtl_flist.f"
PCIE_RTL_FILELIST="-f $OFS_ROOTDIR/sim/scripts/rtl_pcie.f"

MSIM_FILELIST="$INC_DIR \
$LIB_FILELIST \
$RTL_FILELIST \
$QSYS_FILELIST \
$PCIE_RTL_FILELIST"

# Default AFU
BASE_AFU_SRC="-f $OFS_ROOTDIR/sim/scripts/rtl_afu_default.f"
