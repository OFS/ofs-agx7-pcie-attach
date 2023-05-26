//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 *
 * class mmio_pcie_max_seq is executed by below tests based on max_payload_size,max_rd_req which is defined in respective below tests.
 *
 * class mmio_pcie_max_seq is executed by  mmio_pcie_mrrs_128B_mps_128B_test
 * class mmio_pcie_max_seq is executed by  mmio_pcie_mrrs_128B_mps_256B_test
 * class mmio_pcie_max_seq is executed by  mmio_pcie_mrrs_256B_mps_128B_test
 * class mmio_pcie_max_seq is executed by  mmio_pcie_mrrs_256B_mps_256B_test 
 *                                     
 **/
//===============================================================================================================

`ifndef MMIO_PCIE_MAX_SEQ_SVH
`define MMIO_PCIE_MAX_SEQ_SVH

class mmio_pcie_max_seq extends he_lpbk_seq;
    `uvm_object_utils(mmio_pcie_max_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    constraint req_len_c   { req_len == 2'b10; }
    constraint num_lines_c { num_lines == 1024; }

    function new(string name = "mmio_pcie_max_seq");
        super.new(name);
    endfunction : new

endclass : mmio_pcie_max_seq

`endif // MMIO_PCIE_MAX_SEQ_SVH
