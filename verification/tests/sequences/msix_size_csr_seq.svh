// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef MSIX_SIZE_CSR_SEQ_SVH
`define MSIX_SIZE_CSR_SEQ_SVH

class msix_size_csr_seq extends base_seq;
    `uvm_object_utils(msix_size_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mmio_seq");
        super.new(name);
    endfunction : new

    task body();
        logic [63:0] cur_pf_table;
        bit [63:0] wdata, rdata, addr,rw_bits,default_value;
        bit [63:0] afu_id_l, afu_id_h;
        uvm_status_e       status;


        super.body();
        `uvm_info(get_name(), "Entering msix_size_csr_seq...", UVM_LOW)

         ///////////////////////////////////////////////// 
        `uvm_info(get_name(), $psprintf("TEST: WRITE PF0 MSIX_SIZE REG"), UVM_LOW)
         wdata='h00000000_00000007 ;
         write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20000,wdata);                      // PF0 MSIX Size register
         `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)

        `uvm_info(get_name(), $psprintf("TEST: READ PF0 MSIX_SIZE REG"), UVM_LOW)
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20000,rdata);      
         //Compare data        
         if(rdata[63:32] !== wdata[31:0])
           `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata[63:32]))
         else
           `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata[63:32]), UVM_LOW)

         #200ns;
         ///////////////////////////////////////////////// 
        `uvm_info(get_name(), $psprintf("TEST: WRITE PF2 MSIX_SIZE REG"), UVM_LOW)
         wdata='h00000000_00000009 ;
         write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20008,wdata);                      // PF2 MSIX Size register
         `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)

        `uvm_info(get_name(), $psprintf("TEST: READ PF2 MSIX_SIZE REG"), UVM_LOW)
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20008,rdata);      
         //Compare data        
         if(rdata[63:32] !== wdata[31:0])
           `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata[63:32]))
         else
           `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata[63:32]), UVM_LOW)

         #200ns;
         ///////////////////////////////////////////////// 
        `uvm_info(get_name(), $psprintf("TEST: WRITE PF0VF0 MSIX_SIZE REG"), UVM_LOW)
         wdata='h00000000_0000000B ;
         write_mailbox(tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20100,wdata);                      // PF0VF0 MSIX Size register
         `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h","PCIE_SS_DATA_CSR" ,wdata), UVM_LOW)

        `uvm_info(get_name(), $psprintf("TEST: READ PF0VF0 MSIX_SIZE REG"), UVM_LOW)
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_BAR0+PCIE_SS_CMD_CSR,18'h20100,rdata);      
         //Compare data        
         if(rdata[63:32] !== wdata[31:0])
           `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE_SS_DATA_CSR",wdata, rdata[63:32]))
         else
           `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","PCIE_SS_DATA_CSR",wdata, rdata[63:32]), UVM_LOW)

        `uvm_info(get_name(), "Exiting msix_size_csr_seq...", UVM_LOW)

    endtask : body

endclass : msix_size_csr_seq

`endif // MSIX_SIZE_CSR_SEQ_SVH
