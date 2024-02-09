// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

task qsfp_axi_master_read (input [17:0] address,input [63:0] ex_rdata);
    
   qsfp_axi_derived_read_sequence rd_trans;
   `uvm_do_on_with(rd_trans,p_sequencer.axi4_lt_mst_seqr, { 

      rd_trans.addr                  == address;
      rd_trans.exp_data                  == ex_rdata;
      })
      `uvm_info(get_name(), $psprintf(" data from vip_task Addr = %0h, Exp = %0h ", address, ex_rdata), UVM_LOW)
endtask : qsfp_axi_master_read

task qsfp_axi_master_read_rand (input [17:0] address,input [63:0] ex_rdata);
  qsfp_axi_derived_read_rand_sequence rd_trans;

  `uvm_do_on_with(rd_trans,p_sequencer.axi4_lt_mst_seqr, { 

      rd_trans.addr                  == address;
      rd_trans.exp_data              == ex_rdata;
      })

endtask : qsfp_axi_master_read_rand

task qsfp_axi_master_write (input [17:0] address,input [63:0] wdata,input [7:0] wstrobe);
  qsfp_axi_derived_write_sequence wr_trans;

  `uvm_do_on_with(wr_trans,p_sequencer.axi4_lt_mst_seqr, { 

      wr_trans.addr                  == address;
      wr_trans.data                  == wdata;
      wr_trans.wstrb                 == wstrobe;
      })

endtask : qsfp_axi_master_write
 

