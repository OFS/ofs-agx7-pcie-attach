# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# initialize variables

#SIM_BASE=../sim 
#THE_PLATFORM=$SIM_BASE/../../../../../iofs-sandbox/bbs
#OLD_SIM=$SIM_BASE/../../../../../iofs-sandbox/bbs/simulation/stratix10/pac_d5005/common/sim
#RP_BFM=../verification/rp_bfm
#TOP_LEVEL_NAME="top_tb"
#QSYS_SIMDIR="./../../"
#QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
#SKIP_FILE_COPY=0
#SKIP_ELAB=0
#SKIP_SIM=0
#USER_DEFINED_ELAB_OPTIONS=""
#USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"
#rtl_files="rtl_files.f"

if [[ ! -e $SIM_BASE ]]; then
    mkdir $SIM_BASE
elif [[ ! -d $SIM_BASE ]]; then
    echo "$SIM_BASE already exists but is not a directory" 
fi


###################################
# Source the BBS filelist for vcs #
###################################

#. $SIM_BASE/../../../../../iofs-sandbox/bbs/simulation/stratix10/pac_d5005/common/vcs_filelist.sh

 

if [ ! -f $SIM_BASE/$rtl_files ]
then
    touch $SIM_BASE/$rtl_files
fi

if [ -f "$SIM_BASE/$rtl_files" ]
then 
    echo "$VCS_FILELIST" > "$SIM_BASE/$rtl_files"
    echo "$BASE_AFU_SRC" >> "$SIM_BASE/$rtl_files"
fi



