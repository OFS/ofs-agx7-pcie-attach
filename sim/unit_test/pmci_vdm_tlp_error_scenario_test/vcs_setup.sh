# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

cp -rf $OFS_ROOTDIR/sim/unit_test/pmci_vdm_tlp_error_scenario_test/cm_hier.file $OFS_ROOTDIR/sim/unit_test/pmci_vdm_tlp_error_scenario_test/sim_vcs

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
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100+ntb_random_seed_automatic"

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

##################################
### BFM related verilog source ###
##################################
. $COMMON_TESTUTIL_DIR/vcs_filelist.sh

TB_SRC="$TEST_SRC_DIR/test_csr_defs.sv \
$TEST_SRC_DIR/mctp_pcievdm_buffer.sv \
$TEST_SRC_DIR/bmc_top.sv \
$TEST_SRC_DIR/../pmci_coverage_interface/pmci_interface.sv \
$BFM_SRC"

TEST_NAME="`echo $TEST_SRC_DIR|grep -o '[^/]\+$'`" \

echo $TEST_NAME
##################################
### AFU related verilog source ###
##################################

vcs -lca -cm tgl+line+cond+fsm+branch -cm_dir simv.vdb -cm_hier cm_hier.file -timescale=1ps/1ps -full64 -sverilog +vcs+lic+wait +systemverilogext+.sv+.v -ntb_opts dtm \
 +define+VCS_ \
 +nbaopt \
 +delay_mode_zero \
 +lint=TFIPC-L \
 -ignore initializer_driver_checks \
 +define+SIM_MODE \
 +define+INCLUDE_PMCI \
 +define+BMC_EN \
 +define+VCD_ON \
 +define+SIM_USE_PCIE_GEN3X16_BFM \
 +define+SIM_PCIE_CPL_TIMEOUT \
 +define+SIM_PCIE_CPL_TIMEOUT_CYCLES="26'd12500000" \
 +define+BASE_AFU="dummy_afu" \
 +define+RP_MAX_TAGS=64 \
 +define+SIM_USE_PCIE_DUMMY_CSR \
 $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
 +incdir+./ \
 +incdir+$TEST_SRC_DIR/ \
 $VCS_FILELIST \
 $BASE_AFU_SRC \
 $TB_SRC -top $TOP_LEVEL_NAME +error+10 -l vcs.log 

   
# ----------------------------------------
# simulate
# parse transcript to remove redundant comment block (fb:435978)
if [ $SKIP_SIM -eq 0 ]; then
  ./simv  $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -cm tgl+line+cond+fsm+branch -cm_name $TEST_NAME -cm_hier cm_hier.file -cm_test pmci -cm_dir ../../../regression.vdb -l transcript
fi


