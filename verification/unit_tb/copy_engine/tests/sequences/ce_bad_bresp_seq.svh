// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_BAD_BRESP_SEQ_SVH
`define CE_BAD_BRESP_SEQ_SVH

class ce_bad_bresp_seq extends base_seq;
   `uvm_object_utils(ce_bad_bresp_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   function new(string name = "ce_bad_bresp_seq");
      super.new(name);
   endfunction : new

   task body();
      bit [63:0] wdata, rdata;
      //bit [63:0] mask = 64'h0000_0000_0000_0001;
      
      //polling for HPS_RDY bit
      super.body();
      `uvm_info(get_name(), "Entering ce_bad_bresp_seq...", UVM_LOW)


      //temporary forces
//force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;



      do begin
      `uvm_info(get_name(), "Polling for HPS_RDY", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0140), .data_(rdata));                        //not sure how to use address
      end while (rdata[4] !== 1);

      //force tb_top.DUT.ce_inst.ce_acelite_tx_inst.hps2ce_tx_awready = 1'b1;
		//force tb_top.DUT.ce_inst.ce_acelite_tx_inst.hps2ce_tx_wready = 1'b1;
      //force tb_top.DUT.ce_inst.ce_acelite_tx_inst.hps2ce_tx_bresp[1:0] = 2'b00;
      //force tb_top.DUT.ce_inst.ce_acelite_tx_inst.hps2ce_tx_bvalid = 

 
   

      //programming the descriptors
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
      wdata = 64'h4000;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE


      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));


#800ns;

      force tb_top.DUT.ce_top_inst.ce_acelite_tx_inst.hps2ce_tx_bresp[1:0] = 2'h2;

#200ns;

      do begin
      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));
      if(rdata[3:2]==2'b10) begin
         `uvm_info(get_name(), "Error on Bresp", UVM_LOW) 
      end
      end while(rdata[3:2] !== 2'b10);

      do begin
      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));
      if(rdata[1:0]==2'b11) begin
         `uvm_info(get_name(), "Error in transfer", UVM_LOW) 
      end
      end while(rdata[1:0] !== 2'b11);

 endtask : body

   endclass : ce_bad_bresp_seq

`endif





