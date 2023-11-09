// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef VIRTUAL_SEQUENCER_SVH
`define VIRTUAL_SEQUENCER_SVH

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    tb_config tb_cfg0;
    `PCIE_DEV_VIR_SQR root_virt_seqr;
    `AXI_SLAVE_SQR acelite_slv_seqr;
    `AXI_MASTER_SQR hps2ce_axi4_lt_mst_seqr;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass : virtual_sequencer

`endif // VIRTUAL_SEQUENCER_SVH
