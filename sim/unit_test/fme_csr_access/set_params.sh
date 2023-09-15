# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="+define+SIM_MODE \
 +define+VCD_ON"

TOP_LEVEL_NAME="testbench_top"

cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif $SIM_DIR 

if [ $MSIM -eq 0 ] ; then
    USER_DEFINED_ELAB_OPTIONS="-debug_acc+pp+dmptf"
fi