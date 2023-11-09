// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef IOFS_AC_CE_ADVANCE_DMA_SEQ_SVH
`define IOFS_AC_CE_ADVANCE_DMA_SEQ_SVH

class ce_advance_dma_seq extends base_seq;
   `uvm_object_utils(ce_advance_dma_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)
   
   //rand bit [63:0] size;

    /*constraint size_range{
      size inside {[64'h0000_0000:64'h0000_1000]}; //maximum: 1MB
   }*/


   function new(string name = "ce_advance_dma_seq");
      super.new(name);
   endfunction : new
   rand bit [1:0] drl;
   int unsigned drl1;
   rand bit [31:0] size, size1;
   rand bit [63:0] src_addr, src_addr1 ;
   rand bit [31:0] dst_addr, dst_addr1 ;

   constraint drlimit {drl dist {2'b01:=33, 2'b10:=33, 2'b11:=33};
                     
}

   /*constraint srcaddrr {(drl==2'b11) -> src_addr inside {[53'h0000_0000_0000:53'h1F_FFFF_FFFF_FFFF]};
                        (drl==2'b10) -> src_addr inside {[54'h0000_0000_0000:53'h3F_FFFF_FFFF_FFFF]};
                        (drl==2'b01) -> src_addr inside {[56'h0000_0000_0000:56'hFF_FFFF_FFFF_FFFF]};
                        (drl==2'b00) -> src_addr inside {[53'h0000_0000_0000:53'h1F_FFFF_FFFF_FFFF]};
                     //src_addr[63:32] != 32'h0;
   }

   constraint abc {solve src_addr before dst_addr;
}

   constraint daddr { (drl==2'b11) -> dst_addr inside {[18'h0000:18'h3_FFFF]};
                      (drl==2'b10) -> dst_addr inside {[19'h0000:19'h7_FFFF]};
                      (drl==2'b01) -> dst_addr inside {[21'h0000:21'h1F_FFFF]};
                      (drl==2'b00) -> dst_addr inside {[18'h0000:18'h3_FFFF]};
   }*/

   constraint pkt_size { size inside {[26'h8:26'h4000]};
  }


   task body();
      bit [63:0] wdata, rdata;
      //bit [63:0] mask = 64'h0000_0000_0000_0001;
      
      //polling for HPS_RDY bit
      super.body();
      `uvm_info(get_name(), "Entering ce_advance_dma_seq...", UVM_LOW)

      //temporary forces
//force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;


      do begin
      `uvm_info(get_name(), "Polling for HPS_RDY", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0140), .data_(rdata));                        //not sure how to use address
      end while (rdata[4] !== 1);      
      
      if(drl==2'b01) 
      begin
      drl1='d128;
      src_addr[63:57]='h0;
      dst_addr[31:22]='h0;
      end else if(drl==2'b10)
      begin
      drl1='d512;
      src_addr[63:55]='h0;
      dst_addr[31:20]='h0;
      end else 
      begin
      drl1='d1024;
      src_addr[63:54]='h0;
      dst_addr[31:19]='h0;
      end

      `uvm_info(get_name(), $psprintf("value of drl is %0h",drl), UVM_LOW)
      wdata=drl;
      mmio_write64(.addr_(`PF4_BAR0+'h108), .data_(wdata));
      //wdata=64'h1;
      //mmio_write64(.addr_(`PF4_BAR0+'h108), .data_(wdata));
   //randomize(src_addr);
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr), UVM_LOW)
 
   src_addr1=src_addr*drl1; 
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr1), UVM_LOW)

  //programming the descriptors
      wdata = src_addr1;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
//randomize(dst_addr);
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr), UVM_LOW)

   dst_addr1=dst_addr*drl1;  
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr1), UVM_LOW)

      wdata = dst_addr1;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
//randomize(size);
   `uvm_info(get_name(), $psprintf("value of size is %0h", size), UVM_LOW)
  size1=size*'d64;
`uvm_info(get_name(), $psprintf("value of size is %0h", size1), UVM_LOW)

      wdata ='h2000;
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

      `uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr), UVM_LOW)
 
   src_addr1=src_addr*drl1; 
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr1), UVM_LOW)

  //programming the descriptors
      wdata = src_addr1;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
//randomize(dst_addr);
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr), UVM_LOW)

   dst_addr1=dst_addr*drl1;  
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr1), UVM_LOW)

      wdata = dst_addr1;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
//randomize(size);
   `uvm_info(get_name(), $psprintf("value of size is %0h", size), UVM_LOW)
  size1=size*'d64;
`uvm_info(get_name(), $psprintf("value of size is %0h", size1), UVM_LOW)

      wdata ='h2000;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));  
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

   endclass : ce_advance_dma_seq

`endif



      






