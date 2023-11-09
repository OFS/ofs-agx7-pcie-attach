# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

# Set environment variables
#----------------------------
if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

export OFS_ROOTDIR="${SCRIPT_DIR}/../../.."

QIP_DIR=$OFS_ROOTDIR/sim/scripts/qip_sim_script

mkdir -p ip_libraries
cp -f $QIP_DIR/synopsys/vcsmx/synopsys_sim.setup ip_libraries/
cd ip_libraries && $QIP_DIR/synopsys/vcsmx/vcsmx_setup.sh SKIP_SIM=1 QSYS_SIMDIR=$QIP_DIR QUARTUS_INSTALL_DIR=$QUARTUS_HOME
