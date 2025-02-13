# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

VCSMX=0
MSIM=0
TEST_DIR=""

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh run_sim.sh SKIP_IP_CMP=1
# ----------------------------------------
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

if [ $VCSMX -eq 1 ]; then
   SIM_DIR=${TEST_DIR}/sim_vcsmx
elif [ $MSIM -eq 1 ]; then
   SIM_DIR=${TEST_DIR}/sim_msim
else
   SIM_DIR=${TEST_DIR}/sim_vcs
fi
echo "entering sim_setup_common.sh: SIM_DIR: $SIM_DIR"

IP_SIM_SCRIPT_DIR="$OFS_ROOTDIR/sim/scripts/qip_sim_script"

# ----------------------------------------
# Clean up
# ----------------------------------------
rm -rf $SIM_DIR 

# ----------------------------------------
# Simulation setup
# ----------------------------------------
mkdir $SIM_DIR

if [ $MSIM -eq 1 ]; then
   cp ${IP_SIM_SCRIPT_DIR}/../msim_filelist.sh $SIM_DIR 
else
   # Pre-compiled Quartus libraries
   if [ ! -f "${IP_SIM_SCRIPT_DIR}"/quartus_libs/vcsmx/synopsys_sim.setup ]; then
      echo ""
      echo "Quartus simulation library not found in "${IP_SIM_SCRIPT_DIR}"/quartus_libs/vcsmx/synopsys_sim.setup"
      echo "This library is supposed to be pre-compiled by gen_sim_files.sh."
      echo "Aborting..."
      exit 1
   fi
   rsync -a "${IP_SIM_SCRIPT_DIR}"/quartus_libs/vcsmx/ "${SIM_DIR}"/

   cp ${IP_SIM_SCRIPT_DIR}/../vcs_filelist.sh $SIM_DIR 
fi

cp ${IP_SIM_SCRIPT_DIR}/../rtl_pcie.f $SIM_DIR

if [ $MSIM -eq 1 ]; then
   sed -i 's/PCIE_RTL_FILELIST=.*/PCIE_RTL_FILELIST="-f .\/rtl_pcie.f"/' ${SIM_DIR}/msim_filelist.sh
else
   sed -i 's/PCIE_RTL_FILELIST=.*/PCIE_RTL_FILELIST="-f .\/rtl_pcie.f"/' ${SIM_DIR}/vcs_filelist.sh
fi
# Switch in the BFM .
sed -i 's,'.*\/pcie_wrapper.sv',$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pcie_wrapper.sv,' ${SIM_DIR}/rtl_pcie.f
sed -i 's,'.*\/pcie_top.sv',$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pcie_top.sv,' ${SIM_DIR}/rtl_pcie.f
sed -i 's,'.*\/axi_s_adapter.sv',$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/axi_s_adapter.sv,' ${SIM_DIR}/rtl_pcie.f
sed -i 's,'.*\/pcie_csr.sv',$OFS_ROOTDIR/ofs-common/sim/bfm/ofs_axis_bfm/pcie_csr.sv,' ${SIM_DIR}/rtl_pcie.f

echo "sim_setup_common: done!"
