// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

function [31:0] changeEndian;   //transform data from the memory to big-endian form
     input [31:0] value;
     changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
endfunction

task mmio_pcie_read32(input bit [63:0] addr_, output bit [31:0] data_);
     pcie_rd_mmio_seq mmio_rd;
         `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
            rd_addr == addr_;
            rlen    == 1;
            l_dw_be == 4'b0000;
            block   == 0;
         })
     data_ = changeEndian(mmio_rd.read_tran.payload[0]);
 endtask : mmio_pcie_read32

task mmio_pcie_read64(input  bit [63:0] addr_, output bit [63:0] data_);
    pcie_rd_mmio_seq mmio_rd;
      `uvm_do_on_with(mmio_rd, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], {
          rd_addr == addr_;
          rlen    == 2;
          l_dw_be == 4'b1111;
          block   == 0;
      })
    data_ = {changeEndian(mmio_rd.read_tran.payload[1]), changeEndian(mmio_rd.read_tran.payload[0])};
endtask : mmio_pcie_read64


 task mmio_pcie_write32(input bit [63:0] addr_, input bit [31:0] data_);
     pcie_wr_mmio_seq mmio_wr;
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h1;
           l_dw_be       == 4'b0000;
           wr_payload[0] == changeEndian(data_);
       })
 endtask : mmio_pcie_write32 

 task mmio_pcie_write64(input bit [63:0] addr_, input bit [63:0] data_ );
     pcie_wr_mmio_seq mmio_wr;
       `uvm_do_on_with(mmio_wr, p_sequencer.root_virt_seqr.driver_transaction_seqr[0], { 
           wr_addr       == addr_;
           wrlen         == 'h2;
           l_dw_be       == 4'b1111;
           wr_payload[0] == changeEndian(data_[31:0]);
           wr_payload[1] == changeEndian(data_[63:32]);
       })
 endtask : mmio_pcie_write64

task hps2ce_axi_master_read (input [20:0] address,input [31:0] ex_rdata);
    
   hps2ce_axi_derived_read_sequence rd_trans;
   `uvm_do_on_with(rd_trans,p_sequencer.hps2ce_axi4_lt_mst_seqr, { 

      rd_trans.addr                  == address;
      rd_trans.exp_data                  == ex_rdata;
      })

endtask : hps2ce_axi_master_read

task hps2ce_axi_master_write (input [63:0] address,input [1023:0] wdata,input [127:0] wstrobe);
  hps2ce_axi_derived_write_sequence wr_trans;

  `uvm_do_on_with(wr_trans,p_sequencer.hps2ce_axi4_lt_mst_seqr, { 

      wr_trans.addr                  == address;
      wr_trans.data                  == wdata;
      wr_trans.wstrb                 == wstrobe;
      })

endtask : hps2ce_axi_master_write
 

