// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_ERROR_SEQ_SVH
`define CE_ERROR_SEQ_SVH
class ce_error_seq extends base_seq;
   `uvm_object_utils(ce_error_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   function new(string name = "ce_error_seq");
      super.new(name);
   endfunction : new

	
   task body();
      bit [63:0] wdata, rdata;
     // bit [63:0] mask = 64'h0000_0000_0000_0001;
      
      //polling for HPS_RDY bit
      super.body();
      `uvm_info(get_name(), "Entering ce_error_test...", UVM_LOW)

      //force tb_top.DUT.afu_top.ce_wrapper.ce_top_inst.ce_csr_inst.csr_hps2host_sts[4] = 1'b1;
      //force tb_top.DUT.ce_top_inst.ce_csr_inst.csr_hps2host_rsp[4] = 1'b1;

      do begin
      `uvm_info(get_name(), "Polling for CSR_HPS2HOST_RDY_STATUS", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0140), .data_(rdata));                        //not sure how to use address
      end while (rdata[4] !== 1'b1);
   

      //programming the descriptors
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0110), .data_(wdata));      //CSR_SRC_ADDR   //mmio_write_cmpl_er need to be confirmed
      wdata = 64'h0000_0000;
      mmio_write64(.addr_(`PF4_BAR0+'h0118), .data_(wdata));      //CSR_DST_ADDR
      wdata = 64'h01000;
      mmio_write64(.addr_(`PF4_BAR0+'h0120), .data_(wdata));      //CSR_DATA_SIZE


      //program CSR_HOST2CE_MRD_START.MRD_START to 1
      wdata=64'h01;
      mmio_write64(.addr_(`PF4_BAR0+'h0128), .data_(wdata));             //mmio_write_cmpl_er need to be confirmed

      `uvm_info(get_name(), "waiting for mrd operation to complete", UVM_LOW)

      force tb_top.DUT.pcie_wrapper.pcie_ss_top.host_pcie.pcie_ss.pcie_ss.p0_ss_app_st_rx_tdata[47:45] = 3'b001; 


#2000ns; 
	//polling for CE_DMA_STS bit
      release tb_top.DUT.pcie_wrapper.pcie_ss_top.host_pcie.pcie_ss.pcie_ss.p0_ss_app_st_rx_tdata[47:45]; 
   do begin  
      `uvm_info(get_name(), "Polling for CE_DMA_STS ", UVM_LOW)
      mmio_read64(.addr_(`PF4_BAR0+'h0130), .data_(rdata));                        
   end while (rdata[1:0] !== 2'b11);   
	if (rdata[1:0]!=2'b10 || rdata[6:4]!= 3'b000)begin
	 `uvm_info(get_name(), "This is expected.DMA transfer error", UVM_LOW)
	end else begin
    `uvm_error(get_name(), $psprintf("Error: NO error"))
	end

endtask


   

	

	endclass : ce_error_seq

`endif // CE_ERROR_SEQ_SVH

