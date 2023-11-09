// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//===============================================================================================================
/**
 * This class is Virtual Sequencer class, which encapsulates the 
 * agent's sequencers and allows a fine grain control over the user's
 * stimulus application to the selective sequencer.
 * It has the handles of VIP seqeuncers (PCIE VIP /AXI VIP)
 * VIP Sequncer handles are connected in env connect_phase
 */
//===============================================================================================================
`ifndef VIRTUAL_SEQUENCER_SVH
`define VIRTUAL_SEQUENCER_SVH

class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    tb_config tb_cfg0;
    `PCIE_DEV_VIR_SQR root_virt_seqr;
    `AXI_MASTER_SQR          pmci_axi4_lt_mst_seqr;
    `AXI_MASTER_SQR          HSSI_AXIS_mst_seqr;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

endclass : virtual_sequencer

`endif // VIRTUAL_SEQUENCER_SVH
