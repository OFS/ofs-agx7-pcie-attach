// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_128DRL_SEQ_SVH
`define CE_128DRL_SEQ_SVH

class ce_128drl_seq extends base_seq;
   `uvm_object_utils(ce_128drl_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   function new(string name = "ce_128drl_seq");
      super.new(name);
   endfunction : new
//   logic [31:0] size;
   logic [31:0] dst_addr;

//   constraint pkt_size { size inside {[32'h200:32'h1000]};
//   }

   constraint daddr { dst_addr inside {[32'h0000:32'hFE00F000]};
   }

   task body();
      bit [63:0] wdata, rdata,  mrdata;
      //bit [63:0] mask = 64'h0000_0000_0000_0001;
      
      //polling for HPS_RDY bit
      super.body();
      `uvm_info(get_name(), "Entering ce_128drl_seq...", UVM_LOW)

      //temporary forces
      //force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;


      do begin
      `uvm_info(get_name(), "Polling for HPS_RDY", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0140), .data_(rdata));                        //not sure how to use address
      end while (rdata[4] !== 1);

      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h108), .data_(wdata));
      mmio_read64(.addr_(`PF4_BAR0+'h108), .data_(mrdata));   

      //programming the descriptors
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
      wdata = 'h800;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE

       mmio_read64(.addr_(`PF4_BAR0+'h0120), .data_(mrdata));   

      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));


      do begin
      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));
      if(rdata[1:0] == 00) begin
         `uvm_info(get_name(), "status is idle", UVM_LOW)
      end else if(rdata[1:0] == 2'b01) begin
         `uvm_info(get_name(), "DMA is in progress", UVM_LOW)
      end else if(rdata[1:0] == 2'b10) begin
         `uvm_info(get_name(), "DMA is done successfully", UVM_LOW)
      end else if(rdata[1:0] == 2'b11) begin
         `uvm_error("ce_block", "ERROR:: error in DMA")
         break;
      end else begin
         `uvm_info(get_name(), $psprintf("value for rdata is %0h",rdata), UVM_LOW)
      end
      end while(rdata[1:0] !== 2'b10);

      do begin
      `uvm_info(get_name(), "waiting for MRD_START to go 0", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0128), .data_(rdata));
      end while(rdata[0] !== 0);

      //re-programming the descriptors
      wdata = 64'h0000_1000;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
      wdata = 64'h0000_1000;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
      wdata = 'h800;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE

      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));

      do begin
      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));
      if(rdata[1:0] == 00) begin
         `uvm_info(get_name(), "status is idle", UVM_LOW)
      end else if(rdata[1:0] == 2'b01) begin
         `uvm_info(get_name(), "DMA is in progress", UVM_LOW)
      end else if(rdata[1:0] == 2'b10) begin
         `uvm_info(get_name(), "DMA is done successfully", UVM_LOW)
      end else if(rdata[1:0] == 2'b11) begin
         `uvm_error("ce_block", "ERROR:: error in DMA")
         break;
      end else begin
         `uvm_info(get_name(), $psprintf("value for rdata is %0h",rdata), UVM_LOW)
      end
      end while(rdata[1:0] !== 2'b10);

      do begin
      `uvm_info(get_name(), "waiting for MRD_START to go 0", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0128), .data_(rdata));
      end while(rdata[0] !== 0);






      // programming HOST2HPS_GPIO
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0138), .data_(wdata));
#200ns;
      `uvm_info(get_name(), "exiting", UVM_LOW)

   endtask : body

   endclass : ce_128drl_seq

`endif

