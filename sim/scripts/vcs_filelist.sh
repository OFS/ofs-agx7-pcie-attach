# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT



. $OFS_ROOTDIR/sim/scripts/ip_flist.sh

# <COPY_ROM_BEGIN>
cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif ./
# <COPY_ROM_END>

LIB_FILELIST="$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/host_bfm_types_pkg.sv \
$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pfvf_def_pkg_host.sv \
$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pfvf_def_pkg_soc.sv \
$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pfvf_class_pkg.sv \
"

# Quartus HSSI libraries for VCS are pre-compiled during gen_sim_files
HSSI_LIB_FILELIST=""

INC_DIR="+incdir+$OFS_ROOTDIR/ofs-common/src/common/includes/ \
+incdir+$OFS_ROOTDIR/src/includes/ \
+incdir+$OFS_ROOTDIR/ipss/hssi/rtl/inc/"

RTL_FILELIST="-F $OFS_ROOTDIR/sim/scripts/generated_rtl_flist.f"
PCIE_RTL_FILELIST="-F $OFS_ROOTDIR/sim/scripts/rtl_pcie.f"

VCS_FILELIST="$INC_DIR \
$LIB_FILELIST \
$RTL_FILELIST \
$QSYS_FILELIST \
$PCIE_RTL_FILELIST"

# Default AFU
BASE_AFU_SRC="-F $OFS_ROOTDIR/sim/scripts/rtl_afu_default.f"
