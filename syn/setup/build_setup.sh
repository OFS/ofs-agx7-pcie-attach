#!/bin/sh
# Copyright (C) 2022 Intel Corporation
# SPDX-License-Identifier: MIT

# Copy fme_id.mif to build folder
cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif ./
cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif ./fme_id_orig.mif
cp -f $OFS_ROOTDIR/ipss/pmci/pmci_ss_nios_fw.hex ./

