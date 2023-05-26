# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

TEST_SRC_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)/"
echo "SCRIPT_NAME.: ${SCRIPT_NAME}"
echo "TEST_SRC_DIR: ${TEST_SRC_DIR}"

VCSMX=0
MSIM=0
SKIP_IP_CMP=0
TEST_DIR=$TEST_SRC_DIR
echo "TEST_DIR0...: ${TEST_DIR}"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh run_sim.sh SKIP_IP_CMP=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

echo "TEST_DIR1...: ${TEST_DIR}"
# Create Simulation directory
if [ $VCSMX -eq 1 ]; then
   SIM_DIR=${TEST_DIR}/sim_vcsmx
elif [ $MSIM -eq 1 ]; then
   SIM_DIR=${TEST_DIR}/sim_msim
else
   SIM_DIR=${TEST_DIR}/sim_vcs
fi

# Clear then create simulation directory.
rm -rf $SIM_DIR
mkdir $SIM_DIR
cp ${TEST_DIR}/*.sv $SIM_DIR

if [ $MSIM -eq 1 ]; then
   cp ${TEST_DIR}/msim_filelist.sh $SIM_DIR 
   cp ${TEST_DIR}/msim_setup.sh $SIM_DIR
else
   cp ${TEST_DIR}/vcs_filelist.sh $SIM_DIR 
   cp ${TEST_DIR}/vcs_setup.sh $SIM_DIR
fi

cp -f $OFS_ROOTDIR/ofs-common/src/common/fme_id_rom/fme_id.mif $SIM_DIR 


# Run simulation
if [ $VCSMX -eq 1 ]; then
   echo "Running VCSMX simulation in $TEST_DIR/sim_vcsmx"
   cd ${TEST_DIR}/sim_vcsmx && sh ${TEST_SRC_DIR}/vcs_setup.sh OFS_ROOTDIR="$OFS_ROOTDIR" USER_DEFINED_SIM_OPTIONS="+vcs\ -l\ ./transcript" USER_DEFINED_ELAB_OPTIONS="-debug_acc+pp+dmptf"
elif [ $MSIM -eq 1 ]; then
   echo "Running Questasim simulation in $TEST_DIR/sim_msim"
   cd ${TEST_DIR}/sim_msim && sh ${TEST_SRC_DIR}/msim_setup.sh OFS_ROOTDIR="$OFS_ROOTDIR" USER_DEFINED_SIM_OPTIONS="-l\ ./transcript" USER_DEFINED_ELAB_OPTIONS=""
else
   echo "Running VCS simulation in $TEST_DIR/sim_vcs"
   cd ${TEST_DIR}/sim_vcs && sh ${TEST_SRC_DIR}/vcs_setup.sh OFS_ROOTDIR="$OFS_ROOTDIR" USER_DEFINED_SIM_OPTIONS="+vcs\ -l\ ./transcript" USER_DEFINED_ELAB_OPTIONS="-debug_acc+pp+dmptf"
fi


