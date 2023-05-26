# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

TEST_SRC_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

# initialize variables
OFS_ROOTDIR=""
QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

TOP_LEVEL_NAME="top_tb"
# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

SIM_ROOTDIR="$TEST_SRC_DIR/../.."
COMMON_TESTUTIL_DIR="$TEST_SRC_DIR/../scripts"
SIM_DIR="${TEST_DIR}/sim_vcs"

echo "vcs_setup.sh: SIM_ROOTDIR=        $SIM_ROOTDIR"
echo "vcs_setup.sh: COMMON_TESTUTIL_DIR=$COMMON_TESTUTIL_DIR"
echo "vcs_setup.sh: SIM_DIR=            $SIM_DIR"

#-----------------------------------------
# Test will be picked up from base fim by default
# Point this to TEST_SRC_DIR if test path is local fim, and not base fim
TEST_BASE_DIR=${TEST_SRC_DIR}

echo "vcs_setup.sh: TEST_BASE_DIR=$TEST_BASE_DIR"

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

###################################
# Source the BBS filelist for vcs #
###################################
. ${SIM_DIR}/vcs_filelist.sh

echo "vcs_setup.sh: executed BBS filelist ${SIM_DIR}/vcs_filelist.sh"

##################################
### BFM related verilog source ###
##################################
. $COMMON_TESTUTIL_DIR/vcs_filelist.sh

echo "vcs_setup.sh: executed BFM related verilog source $COMMON_TESTUTIL_DIR/vcs_filelist.sh"

TB_SRC="$TEST_BASE_DIR/test_csr_defs.sv \
$BFM_SRC"

##################################
### AFU related verilog source ###
##################################
echo "vcs_setup.sh: executing the vcs !!! TB_SRC $TB_SRC : TOP_LEVEL_NAME $TOP_LEVEL_NAME"
vcs -lca -timescale=1ps/1ps -full64 -sverilog +vcs+lic+wait +systemverilogext+.sv+.v -ntb_opts dtm \
 +lint=TFIPC-L \
 -ignore initializer_driver_checks \
 +define+SIM_MODE \
 +define+VCD_ON \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES="26'd12500000" \
 +define+BASE_AFU="dummy_afu" \
 +define+RP_MAX_TAGS=64 \
 $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
 +incdir+./ \
 +incdir+$TEST_BASE_DIR/ \
 $VCS_FILELIST \
 $BASE_AFU_SRC \
 $TB_SRC -top $TOP_LEVEL_NAME +error+1 -l vcs.log 

   
# ----------------------------------------
# simulate
# parse transcript to remove redundant comment block (fb:435978)
if [ $SKIP_SIM -eq 0 ]; then
    echo "vcs_setup.sh: parse transcript to remove redundant comment block"
    ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -l transcript
fi

echo "vcs_setup.sh: vcs setup done!!"
