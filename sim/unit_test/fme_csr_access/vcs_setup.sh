# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# initialize variables
OFS_ROOTDIR=""
QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

TOP_LEVEL_NAME="testbench_top"
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

# This assignment has to be placed after the variable overwriting block above
THE_PLATFORM=$OFS_ROOTDIR

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
. ./vcs_filelist.sh

##################################
### BFM related verilog source ###
##################################
TB_SRC="./csr_transaction_class_pkg.sv \
  ./test_csr_directed.sv\
  ./testbench_top.sv"

##################################


vcs -lca -timescale=1ps/1ps -full64 -sverilog +vcs+lic+wait +systemverilogext+.sv+.v -ntb_opts dtm \
 -ignore initializer_driver_checks \
 +define+SIM_MODE \
 +define+VCD_ON \
 $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
 +incdir+./ \
 $VCS_FILELIST $TB_SRC -top $TOP_LEVEL_NAME +error+1 -l vcs.log

   
# ----------------------------------------
# simulate
# parse transcript to remove redundant comment block (fb:435978)
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS -l transcript
fi


