# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="+define+SIM_MODE \
 +define+VCD_ON"

TB_SRC="$TEST_BASE_DIR/test_csr_defs.sv \
$TEST_BASE_DIR/test.sv \
$TEST_BASE_DIR/top_tb.sv"

MSIM_OPTS=(-c top_tb -suppress 7033,12023 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f")

VLOG_PARAMS="+initreg+0 +libext+.v+.sv"

VLOGAN_PARAMS="+initreg+0"
