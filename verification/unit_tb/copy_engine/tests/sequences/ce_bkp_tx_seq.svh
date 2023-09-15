// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_BKP_TX_SEQ_SVH
`define CE_BKP_TX_SEQ_SVH

class ce_bkp_tx_seq extends base_seq;
   `uvm_object_utils(ce_bkp_tx_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   function new(string name = "ce_bkp_tx_seq");
      super.new(name);
   endfunction : new

   task body();

      bit [63:0] wdata, rdata;
      
      super.body();

      `uvm_info(get_name(), "Entering BKP TX sequence", UVM_LOW)

   // force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;

      //programming the descriptors
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
      wdata = 64'h400;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE


      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));
    wait(tb_top.DUT.ce_top_inst.ce_acelite_tx_inst.ce2hps_tx_wvalid==1)begin

#5ns;

   // force {tb_top.DUT.ce_top_inst.axis_tx_if.tready} = 1'b0;
      force {tb_top.DUT.ce_top_inst.ce_axist_tx_inst.mux2ce_tx_tready}=1'b0;
    //force {tb_top.axi_if.master_if[1].wready} = 1'b0;

/*#40ns;
 
    force {tb_top.ace_if.slave_if[0].wready} = 1'b1;
    force {tb_top.ace_if.slave_if[0].awready} = 1'b1;

#50ns;

    force {tb_top.ace_if.slave_if[0].wready} = 1'b0;
    force {tb_top.ace_if.slave_if[0].awready} = 1'b0;

#250ns;
   
   force {tb_top.ace_if.slave_if[0].wready} = 1'b1;
    force {tb_top.ace_if.slave_if[0].awready} = 1'b1;
#300ns;*/
    end

 
    repeat (30) begin
      `uvm_info(get_name(), "waiting for MRD_START to go 0", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0128), .data_(rdata));
   end
      


      // programming HOST2HPS_GPIO
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0138), .data_(wdata));
#200ns;

    `uvm_info(get_name(), "Backpressure from CE is acheived", UVM_LOW)
   endtask : body

endclass : ce_bkp_tx_seq

`endif

