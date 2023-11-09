// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_ILLEGAL_DESC_SEQ_SVH
`define CE_ILLEGAL_DESC_SEQ_SVH

class ce_illegal_desc_seq extends base_seq;
   `uvm_object_utils(ce_illegal_desc_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   function new(string name = "ce_illegal_desc_seq");
      super.new(name);
   endfunction : new
   rand bit [1:0] drl;
   int unsigned drl1;
   rand bit [31:0] size, size1;
   rand bit [63:0] src_addr, src_addr1 ;
   rand bit [63:0] dst_addr, dst_addr1 ;
   rand bit select;
   constraint drlimit {drl dist {2'b01:=33, 2'b10:=33, 2'b11:=33};
                     
}

    constraint pkt_size { size inside {[26'h8:26'h40]};
                         size1 inside {[26'h8:26'h40]};
  }

  constraint select_value {select inside {0,1};}


   task body();
      bit [63:0] wdata, rdata;
      bit [63:0] tmp_src_addr, tmp_dst_addr;
      bit [31:0] tmp_size;
      //bit [63:0] mask = 64'h0000_0000_0000_0001;
      
      //polling for HPS_RDY bit
      super.body();
      `uvm_info(get_name(), "Entering ce_basic_dma_seq...", UVM_LOW)

      //temporary forces
//force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;


      do begin
      `uvm_info(get_name(), "Polling for HPS_RDY", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0140), .data_(rdata));                        //not sure how to use address
      end while (rdata[4] !== 1);      
      
      if(drl==2'b01) 
      begin
      drl1='d128;
    //  src_addr[63:57]='h0;
    //  src_addr1[63:57]='h0;
    //  dst_addr[31:22]='h0;
    //  dst_addr1[31:22]='h0;
      end else if(drl==2'b10)
      begin
      drl1='d512;
    //  src_addr[63:55]='h0;
    //  src_addr1[63:55]='h0;
    //  dst_addr[31:20]='h0;
    //  dst_addr1[31:20]='h0;
      end else 
      begin
      drl1='d1024;
    //  src_addr[63:54]='h0;
    //  src_addr1[63:54]='h0;
    //  dst_addr[31:19]='h0;
    //  dst_addr1[31:19]='h0;
      end

      `uvm_info(get_name(), $psprintf("value of drl is %0h",drl), UVM_LOW)
      wdata=drl;
      mmio_write64(.addr_(`PF4_BAR0+'h108), .data_(wdata));
      //wdata=64'h1;
      //mmio_write64(.addr_(`PF4_BAR0+'h108), .data_(wdata));
   //randomize(src_addr);
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr), UVM_LOW)

    if(select == 0)begin 
   tmp_src_addr=src_addr; 
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", tmp_src_addr), UVM_LOW)
    end
    else 
    tmp_src_addr=src_addr*drl1; 

  //programming the descriptors
      wdata = tmp_src_addr;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
//randomize(dst_addr);
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr), UVM_LOW)

    if(select == 1) begin
   tmp_dst_addr=dst_addr;  
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", tmp_dst_addr), UVM_LOW)
    end
    else
        tmp_dst_addr=dst_addr*drl1;
 

      wdata = tmp_dst_addr;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
//randomize(size);
   `uvm_info(get_name(), $psprintf("value of size is %0h", size), UVM_LOW)
  tmp_size=size*'d64;
`uvm_info(get_name(), $psprintf("value of size is %0h", tmp_size), UVM_LOW)

      wdata =tmp_size;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE


      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));


      do begin
      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));
      //if(rdata[12:11] == 00) begin
      //   `uvm_info(get_name(), "status is idle", UVM_LOW)
      //end else if(rdata[12:11] == 2'b01) begin
      //   `uvm_info(get_name(), "Legal descriptor", UVM_LOW)
      //end else if(rdata[12:11] == 2'b10) begin
      //   `uvm_info(get_name(), "Illegal descriptor", UVM_LOW)
      //end else if(rdata[12:11] == 2'b11) begin
      //   `uvm_error("ce_block", "Reserved")
      //   break;
      //end else begin
      //   `uvm_info(get_name(), $psprintf("value for rdata is %0h",rdata), UVM_LOW)
      //end
      end while(rdata[12:11] !== 2'b10);

     // do begin
      `uvm_info(get_name(), "Expecting MRD_START to go 0 as illegal descriptor is generated", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0128), .data_(rdata));
      `uvm_info(get_name(), $psprintf("MRD_START=%0h",rdata), UVM_LOW)
     // end while(rdata[0] !== 0);

  /*  if(drl==2'b01) 
      begin
      drl1='d128;
      src_addr[63:57]='h0;
      src_addr1[63:57]='h0;
      dst_addr[31:22]='h0;
      dst_addr1[31:22]='h0;
      end else if(drl==2'b10)
      begin
      drl1='d512;
      src_addr[63:55]='h0;
      src_addr1[63:55]='h0;
      dst_addr[31:20]='h0;
      dst_addr1[31:20]='h0;
      end else 
      begin
      drl1='d1024;
      src_addr[63:54]='h0;
      src_addr1[63:54]='h0;
      dst_addr[31:19]='h0;
      dst_addr1[31:19]='h0;
      end

      `uvm_info(get_name(), $psprintf("value of src_addr is %0h", src_addr1), UVM_LOW)
 
   tmp_src_addr=src_addr1*drl1; 
`uvm_info(get_name(), $psprintf("value of src_addr is %0h", tmp_src_addr), UVM_LOW)

  //programming the descriptors
      wdata = tmp_src_addr;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR
//randomize(dst_addr);
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", dst_addr1), UVM_LOW)

   tmp_dst_addr=dst_addr1*drl1;  
`uvm_info(get_name(), $psprintf("value of dst_addr is %0h", tmp_dst_addr), UVM_LOW)

      wdata = tmp_dst_addr;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
//randomize(size);
   `uvm_info(get_name(), $psprintf("value of size is %0h", size1), UVM_LOW)
  tmp_size=size1*'d64;
`uvm_info(get_name(), $psprintf("value of size is %0h", tmp_size), UVM_LOW)

      wdata =tmp_size;
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
      end while(rdata[0] !== 0); */






      // programming HOST2HPS_GPIO
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0138), .data_(wdata));
#200ns;
      mmio_read64(.addr_(`PF4_BAR0+'h0154), .data_(wdata));
#50ns;
      `uvm_info(get_name(), "exiting", UVM_LOW)


   endtask : body

   endclass : ce_illegal_desc_seq

`endif



      















      



