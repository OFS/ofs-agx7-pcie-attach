# Copyright 2023 Intel Corporation
# SPDX-License-Identifier: MIT

DEFINES="+define+SIM_MODE \
 +define+VCD_ON"

TB_SRC="-F $OFS_ROOTDIR/ofs-common/sim/bfm/simple_pcie_ss_stream_bfm/filelist.txt \
 $TEST_BASE_DIR/test_cpl_metering.sv \
 $TEST_BASE_DIR/test_ib2sb.sv \
 $TEST_BASE_DIR/test_rx_dual_stream.sv \
 $TEST_BASE_DIR/test_rx_seg_align.sv \
 $TEST_BASE_DIR/test_sb2ib.sv \
 $TEST_BASE_DIR/test_tx_merge.sv \
 $TEST_BASE_DIR/top_tb.sv"

MSIM_OPTS=(-c top_tb -suppress 7033,12023,3839 -voptargs="-access=rw+/. -designfile design_2.bin -debug" -qwavedb=+signal -do "add log -r /* ; run -all; quit -f")

if [ ! -z "${RANDOM_SEED}" ]; then
    if [ "${RANDOM_SEED}" == "auto" ] || [ "${RANDOM_SEED}" == "random" ]; then
        # Simulator chooses a random seed each time it is run
        SIM_OPTIONS="$SIM_OPTIONS +ntb_random_seed_automatic"
        VCS_SIMV_PARAMS="$VCS_SIMV_PARAMS +ntb_random_seed_automatic"
        MSIM_OPTS=(-sv_seed random ${MSIM_OPTS[@]})
    else
        # Pick a specific random seed
        SEED=$RANDOM
        echo "Random seed: $SEED"

        SIM_OPTIONS="$SIM_OPTIONS +ntb_random_seed=$RANDOM"
        VCS_SIMV_PARAMS="$VCS_SIMV_PARAMS +ntb_random_seed=$RANDOM"
        MSIM_OPTS=(-sv_seed $SEED ${MSIM_OPTS[@]})
    fi
fi

VLOG_PARAMS="+initreg+0 +libext+.v+.sv"
VLOGAN_PARAMS="+initreg+0"
