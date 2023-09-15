// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef QSFP_VIRTUAL_SEQUENCER_SVH
`define QSFP_VIRTUAL_SEQUENCER_SVH

class qsfp_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(qsfp_virtual_sequencer)

    qsfp_tb_config tb_cfg0;

    `AXI_MASTER_SQR axi4_lt_mst_seqr;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass : qsfp_virtual_sequencer

`endif // QSFP_VIRTUAL_SEQUENCER_SVH
