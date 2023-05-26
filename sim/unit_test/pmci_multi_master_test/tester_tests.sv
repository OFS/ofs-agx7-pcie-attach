// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   This file defines all the test cases for current test.
//
//   main_test() is the main entry function which the tester calls 
//   to execute the unit tests.
//
//-----------------------------------------------------------------------------

import test_csr_defs::*;

//-------------------
// Test utilities
//-------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   logic result;
begin
   if (test_utils::get_err_count() > old_test_err_count) begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

   repeat (10)
      @(posedge avl_clk);

   @(posedge avl_clk);
      reset_test = 1'b1;
   repeat (5)
      @(posedge avl_clk);
   reset_test = 1'b0;

   f_reset_tag();

   if (result) begin
      $display("\nTest status: OK");
      test_summary[test_id].result = 1'b1;
   end else begin
      $display("\nTest status: FAILED");
      test_summary[test_id].result = 1'b0;
   end
   incr_test_id(); 
end
endtask

task print_test_header;
   input [1024*8-1:0] test_name;
begin
   $display("\n********************************************");
   $display(" Running TEST(%0d) : %0s", test_id, test_name);
   $display("********************************************");   
   test_summary[test_id].name = test_name;
end
endtask

//-------------------
// Test cases 
//-------------------
// Test 32-bit CSR access
task test_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR access to unused CSR region
task test_unused_csr_access_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE32(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nPMCI_ERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access
task test_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 32-bit CSR read access
task test_csr_read_32;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [31:0] data;
   logic [31:0] scratch;
   logic error;
begin
   result = 1'b1;
   READ32(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR read access
task test_csr_read_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nPMCI_ERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test 64-bit CSR access to unused CSR region
task test_unused_csr_access_64;
   output logic       result;
   input e_addr_mode  addr_mode;
   input logic [31:0] addr;
   input logic [2:0]  bar;
   input logic vf_active;
   input logic [PF_WIDTH-1:0] pfn;
   input logic [VF_WIDTH-1:0] vfn;
   input logic [63:0] data;
   logic [63:0] scratch;
   logic error;
begin
   result = 1'b1;

   WRITE64(addr_mode, addr, bar, vf_active, pfn, vfn, data);	
   READ64(addr_mode, addr, bar, vf_active, pfn, vfn, scratch, error);	

   if (error) begin
       $display("\nPMCI_ERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nPMCI_ERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
       test_utils::incr_err_count();
       result = 1'b0;
   end
end
endtask

// Test MMIO access with 32-bit address 
task test_mmio_addr32;
   output logic result;
begin
   print_test_header("test_mmio_addr32");
   test_mmio(result, ADDR32);
end
endtask

// Test MMIO access with 64-bit address 
task test_mmio_addr64;
   output logic result;
begin
   print_test_header("test_mmio_addr64");
   test_mmio(result, ADDR64);
end
endtask

// Test memory write 32-bit address 
task test_mmio;
   output logic result;
   input e_addr_mode addr_mode;
   logic [63:0] base_addr;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;
   
   //-----------
   // Test MMIO write stall issue
   //-----------
   WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h1}});	
   WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h2}});	 
   @(posedge fim_clk);
   WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h3}});	
   test_csr_read_32(result, ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h03333333); // PMCI_FBM_AR RW range is 27:0

   //$display("Print PMCI DFH register value");
   //   test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000010001012);
 
   $display("Test CSR access");
      test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000200001012);
      test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h0111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_SEU_ERR, 0, 1'b0, 0, 0, 'h1111_2222);   
      test_csr_access_32(result, addr_mode, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_PCIE_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_HSSI_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_QSFP_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0002);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 0, 1'b0, 0, 0, 'h0000_2222);   
      test_csr_read_32(result, addr_mode, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, 'h0);
      test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_32(result, addr_mode, PMCI_FBM_FIFO, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_FCR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   
      test_csr_access_64(result, addr_mode, PMCI_VDM_PDR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   

   post_test_util(old_test_err_count);
end
endtask


// Test MMIO access with 64-bit address 
task test_pmci_multi_master_read;
   output logic result;
begin
   print_test_header("test_pmci_multi_master_read");
   test_pmci_mctp_multi_master_test(result, ADDR64);
end
endtask

task test_pmci_mctp_multi_master_test;

   output logic result;
   input e_addr_mode addr_mode;
   logic [31:0] scratch,ack;
   logic [31:0] cnt, rdcnt;
   logic        error;
   logic [31:0] old_test_err_count;
   logic [62:0] rdata,wdata,exp_data;
   bit  [2:0]  hb_ctr;

begin
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;
   $display("Test NIOS polling QSFP telemetry and MCTP triggering read-request to QSFP-B continously ");
   @(posedge avl_clk);
   @(posedge avl_clk);
   @(posedge avl_clk);
     
   
   
      WRITE32(ADDR32, PMCI_QSFP_BA, 0, 1'b0, 0, 0, 'h0001_2000);	
      WRITE32(ADDR32, PMCI_QSFP2_BA, 0, 1'b0, 0, 0, 'h0001_3000);	
        fork
        begin
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h3333_2222_0000_440d; // shadow_csr[100]->'h0d
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h2;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h002d_0000_0000_0000; // shadow_csr[116]->'h2d,shadow_csr[117]-> 'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h114 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h3;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_feff_2211; // shadow_csr[11A]->'hff,shadow_csr[11b]->'hff
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h118 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_0000_000d; // shadow_csr[102]->'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'd48;
          force top_tb.DUT.qsfp_0.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_005a_0000_005f; // shadow_csr[280]->'h5f ,shadow_csr[281]->'h0, shadow_csr[284]-> 'h5a,shadow_csr[285]->'h0
          while(!(top_tb.DUT.qsfp_0.csr_lite_if.araddr=='h284 && top_tb.DUT.qsfp_0.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_0.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_0.clk);
          end 
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
              @(posedge top_tb.DUT.qsfp_0.clk);
        #10ms;
        end
        begin
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h3333_2222_0000_440d; // shadow_csr[100]->'h0d
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h2;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h002d_0000_0000_0000; // shadow_csr[116]->'h2d,shadow_csr[117]-> 'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h114 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h3;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_feff_1122; // shadow_csr[11A]->'hff,shadow_csr[11b]->'hff
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h118 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'h0;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_0000_0000_000d; // shadow_csr[102]->'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h100 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.address[7:0] = 8'd48;
          force top_tb.DUT.qsfp_1.qsfp_ctrl_inst.onchip_memory2_0.readdata[63:0] = 64'h0000_005a_0000_005f; // shadow_csr[280]->'h5f ,shadow_csr[281]->'h0, shadow_csr[284]-> 'h5a,shadow_csr[285]->'h0
          while(!(top_tb.DUT.qsfp_1.csr_lite_if.araddr=='h284 && top_tb.DUT.qsfp_1.csr_lite_if.arvalid == 'h1 && top_tb.DUT.qsfp_1.csr_lite_if.arready==1)) begin
              @(posedge top_tb.DUT.qsfp_1.clk);
          end 
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);
              @(posedge top_tb.DUT.qsfp_1.clk);

        #10ms;
        end
        begin
          forever
          begin @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.in_clk_clk);  
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h2)?'h20 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h8)?'h01 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;    
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h6)?'h19 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
            force top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata = (top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_address == 'h5)?'h0 : top_tb.DUT.pmci_wrapper.pmci_ss.sdm_mailbox_client.avmm_readdata;
          end
        end
	begin
	forever
	begin @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.clk) ;
          @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.axi_m_bridge.aresetn);
          #200us;
         if( top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_waitreq==1 ) begin
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_addr[19:0] = 'h13028;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_read = 'h1;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_byteen[7:0] = 'hf;
         end
         else begin 
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_addr[19:0] = 'h13028;
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_read = 'h0; //change read to 0 when waitreq is low
  	   force top_tb.DUT.pmci_wrapper.pmci_ss.mctp_pcievdm.avmm_egrs_mstr_byteen[7:0] = 'hf;
         end  
	end
	end
        begin
          //#4.2ms;
          //check whether pmci_nios_hb signal is rising.if it's rising twice read the telemetry register values from mailbox
          while(hb_ctr!='h2) begin
            @(posedge top_tb.DUT.pmci_wrapper.pmci_ss.pmci_csr.pmci_csr_0.pmci_nios_hb) begin
              hb_ctr=hb_ctr+1;
            end
          end
        end
        join_any


        //READ MAILBOX VALUES FROM THE HOST//
 
         for (int i=0;i<4;i++) begin

           wdata = 'h8000_1048 + 'h4*i;
           WRITE32(ADDR32, PMCI_SPI_AR, 0, 1'b0, 0, 0, wdata);	
           WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0001);	

           do begin
             READ32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, ack, error);	
           end while(ack[2] != 1'b1);

           READ32(ADDR32, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, rdata, error);	
           if(i==0||i==2) begin
              exp_data ='d180;
           end
           else if (i==1||i==3) begin
              exp_data ='d190;
           end
         
           if(rdata[31:0] == exp_data) begin
              $display("DATA MATCH:Value written to %h is %d",wdata,exp_data);
           end else begin
              $display("PMCI_ERROR:Value written to %h is %d",wdata,rdata);
              test_utils::incr_err_count();
              result = 1'b0;
           end

           WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0000);	
           
         end

         for (int i=0;i<4;i++) begin

           wdata = 'h8000_10b0 + 'h4*i;
           WRITE32(ADDR32, PMCI_SPI_AR, 0, 1'b0, 0, 0, wdata);	
           WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0001);	

           do begin
             READ32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, ack, error);	
           end while(ack[2] != 1'b1);

           READ32(ADDR32, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, rdata, error);	
           if(i==0||i==2) begin
              exp_data ='d90;
           end
           else if (i==1||i==3) begin
              exp_data ='d6553;
           end
         
           if(rdata[31:0] == exp_data) begin
              $display("DATA MATCH:Value written to %h is %d",wdata,exp_data);
           end else begin
              $display("PMCI_ERROR:Value written to %h is %d",wdata,rdata);
              test_utils::incr_err_count();
              result = 1'b0;
           end

           WRITE32(ADDR32, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0000);
	
        end 
 

    #100us;
    post_test_util(old_test_err_count);
    $system("rm -rf ../../../../../pmci_ss_nios_fw.hex");
    $system("rm -rf ../../../../../pmci_ss_nios_fw.ver");
		
end
endtask


//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   test_pmci_multi_master_read    (test_result);
end
endtask



