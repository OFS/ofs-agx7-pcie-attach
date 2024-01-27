# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

SCRIPT_NAME=$BASH_SOURCE
SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

#BFM_DIR="$(readlink -f ${SCRIPT_DIR})/../../bfm/rp_bfm_simple"
BFM_DIR="$(readlink -f ${SCRIPT_DIR})/../../bfm/ofs_axis_bfm"
echo "Setting: BFM DIR = ${BFM_DIR}"

BFM_SRC="+incdir+$BFM_DIR \
$BFM_DIR/host_bfm_types_pkg.sv \
$BFM_DIR/pfvf_def_pkg_host.sv \
$BFM_DIR/pfvf_def_pkg_soc.sv \
$BFM_DIR/pfvf_status_class_pkg.sv \
$BFM_DIR/packet_class_pkg.sv \
$BFM_DIR/packet_delay_class_pkg.sv \
$BFM_DIR/host_memory_class_pkg.sv \
$BFM_DIR/tag_manager_class_pkg.sv \
$BFM_DIR/host_transaction_class_pkg.sv \
$BFM_DIR/host_axis_send_class_pkg.sv \
$BFM_DIR/host_axis_receive_class_pkg.sv \
$BFM_DIR/host_bfm_class_pkg.sv \
$BFM_DIR/host_bfm_top.sv \
$BFM_DIR/host_flr_class_pkg.sv \
$BFM_DIR/host_flr_top.sv \
$BFM_DIR/top_tb.sv"
