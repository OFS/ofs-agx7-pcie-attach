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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 32'h0) begin
       $display("\nERROR: Expected 32'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR write and read mismatch! write=0x%x read=0x%x\n", data, scratch);
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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== data) begin
       $display("\nERROR: CSR read mismatch! expected=0x%x actual=0x%x\n", data, scratch);
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
       $display("\nERROR: Completion is returned with unsuccessful status.\n");
       test_utils::incr_err_count();
       result = 1'b0;
   end else if (scratch !== 64'h0) begin
       $display("\nERROR: Expected 64'h0 to be returned for unused CSR region, actual:0x%x\n",scratch);      
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
      test_csr_read_64(result,addr_mode, PMCI_DFH, 0, 1'b0, 0, 0, 'h3000000010001012);
      test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h0111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_SEU_ERR, 0, 1'b0, 0, 0, 'h1111_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_PCIE_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_HSSI_SS_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
     // test_csr_access_32(result, addr_mode, PMCI_QSFP_BA, 0, 1'b0, 0, 0, 'h0001_2222);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0002);   
      test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 0, 1'b0, 0, 0, 'h0000_2222);   
      test_csr_read_32(result, addr_mode, PMCI_SPI_RD_DR, 0, 1'b0, 0, 0, 'h0);
      test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_32(result, addr_mode, PMCI_FBM_FIFO, 0, 1'b0, 0, 0, 'h1111_2222);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_FCR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   
      //test_csr_access_64(result, addr_mode, PMCI_VDM_PDR, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   

   post_test_util(old_test_err_count);
end
endtask

/*
// Test MMIO access with 64-bit address 
task test_vdm_tx_rx_lpbk;
   output logic result;
begin
   print_test_header("test_vdm_tx_rx_lpbk");
   test_vdm_tx_rx_lpbk_test(result, ADDR64);
end
endtask
*/

//task test_vdm_tx_rx_lpbk_test;
//
//   output logic result;
//   input e_addr_mode addr_mode;
//   logic [31:0] scratch,ack;
//   logic [31:0] cnt, rdcnt;
//   logic        error;
//   logic [31:0] old_test_err_count;
//   logic [62:0] rdata,wdata,exp_data;
//   logic [31:0] vdm_wdata,mctp_header,vdm_pkt_length;
//   static logic [7:0] i_temp;
//   static logic [7:0] j_temp;
//   bit [7:0] cnt;
//   bit [7:0] valid_cnt;
//   logic [31:0] vdm_ref_pld[$];
//   logic [31:0] rx_vdm_pld[$];
//   logic [1:0][255:0] act_data;
//   logic [15:0][31:0] tx_data;
//   logic [15:0][31:0] rx_data;
//   logic [255:0] ref_data_temp;
//   logic [511:0] lpbk_vdm_msg;
//   logic [15:0][31:0] vdm_pkt;
//   logic  [7:0] lpbk_fmt_type;
//   logic  [9:0] lpbk_len;
//   logic  [15:0] lpbk_vendor_id;
//   logic  [31:0] lpbk_mctp_hdr;
//   logic  [7:0]  lpbk_msg_code;
//   
//   bit act_vdm_valid; 
//begin
//   old_test_err_count = test_utils::get_err_count();
//   result = 1'b1;
//   $display("Test MCTP VDM TX-RX Loopback ");
//   @(posedge avl_clk);
//   @(posedge avl_clk);
//   @(posedge avl_clk);
//   @(posedge avl_clk);
//   @(posedge avl_clk);
//   @(posedge avl_clk);
//     
//   
//   
//   WRITE32(ADDR32, PMCI_VDM_BA, 0, 1'b0, 0, 0, 'h0004_2000);
//    
//    #200us;
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//    force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr ='h4;
//    force top_tb.bmc_m10.avmm_nios_read ='h1;
//
//    while(!( top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata[1]==0 && top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld ==1));
//        @(posedge top_tb.bmc_m10.m10_clk);
//  
//    for ( int i=0;i<16;i++) 
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//       i_temp=i; 
//       force top_tb.bmc_m10.avmm_nios_read ='h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h300+i_temp;
//       force top_tb.bmc_m10.avmm_nios_write ='h1;
//       assert(std::randomize(vdm_wdata));
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata =vdm_wdata;
//       vdm_ref_pld.push_back(vdm_wdata);
//    end 
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h5;
//       force top_tb.bmc_m10.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,1'h0,1'h0,3'h0,8'h0,16'h0};
//    end
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h4;
//       force top_tb.bmc_m10.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={12'h10,2'h0,3'h0,1'h1};
//    end
//    end
//    @(posedge top_tb.bmc_m10.m10_clk); 
//    @(posedge top_tb.bmc_m10.m10_clk); 
//    force top_tb.bmc_m10.avmm_nios_write ='h0;
//    
//    //Get the actual values from PCIe BFM//
//
//    f_shmem_vdm_pyld_display(act_data,lpbk_fmt_type,lpbk_len,lpbk_vendor_id,lpbk_mctp_hdr,lpbk_msg_code);
//    if(lpbk_fmt_type !=='h70) begin
//      $display("Error in tx format ype");
//      test_utils::incr_err_count();
//      result = 1'b0;
//    end
//    if(lpbk_len !=='d16) begin
//      $display("Error in tx length");
//      test_utils::incr_err_count();
//      result = 1'b0;
//    end
//    if(lpbk_vendor_id !=='h1ab4) begin
//      $display("Error in tx vendor ID");
//      test_utils::incr_err_count();
//      result = 1'b0;
//    end
//    if(lpbk_mctp_hdr !=='h010000c0) begin
//      $display("Error in tx mctp header");
//      test_utils::incr_err_count();
//      result = 1'b0;
//    end
//    if(lpbk_msg_code !== 'h7f) begin
//      $display("Error in tx message code");
//      test_utils::incr_err_count();
//      result = 1'b0;
//    end
//    #200us;
//    for ( int i=0;i<16;i++) begin
//     tx_data[i] =vdm_ref_pld.pop_front();
//    end
//
//    lpbk_vdm_msg={act_data[1],act_data[0]};
//    //Loopback at RX side begins
//    test_vdm_msg_rx_path (result,lpbk_fmt_type,lpbk_len,lpbk_vendor_id,lpbk_mctp_hdr,lpbk_msg_code,lpbk_vdm_msg);  // 64B   VDM packet
//
//    //BMC txns for RX path
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,2'h0,1'h1,1'h0};
//    end
//    @(posedge top_tb.bmc_m10.m10_clk);
//    @(posedge top_tb.bmc_m10.m10_clk);
//    @(posedge top_tb.bmc_m10.m10_clk);
//
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h1,3'h0,1'h1};
//    end/*
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h1,3'h0,1'h1};
//    end*/
//    @(posedge top_tb.bmc_m10.m10_clk);
//    @(posedge top_tb.bmc_m10.m10_clk);
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h0;
//    #200us;
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
//       vdm_pkt_length=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
//    end 
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
//       mctp_header=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata;
//    end 
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h200;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
//       vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
//    end 
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h0;
//    end
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h0;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h1;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata ={1'h0,2'h0,1'h0,1'h0};
//    end
//    begin @(posedge top_tb.bmc_m10.m10_clk); 
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_write ='h0;
//    end
//    #1ms;
//    fork begin
//    for ( int j=0;j<16;j++) begin
//    begin @(posedge top_tb.bmc_m10.m10_clk);
//      if(!top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_waitreq) begin
//       j_temp=j;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_addr = 'h200+j_temp;
//       force top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_read ='h1;
//       //vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
//      end
//      else begin
//          j=j-1;
//      end 
//    end
//    end
//    end
//    begin
//      while (!top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld) begin
//        @(posedge top_tb.bmc_m10.m10_clk);
//      end
//      while(valid_cnt<16) begin
//      if(top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld==1) begin
//        vdm_pkt=top_tb.bmc_m10.m10_pcie_vdm.avmm_nios_rddata ;
//        rx_vdm_pld.push_back(vdm_pkt);
//        valid_cnt=valid_cnt+1;
//      end
//        @(posedge top_tb.bmc_m10.m10_clk);
//      end
//    end
//    join
//
//    for (int i=0;i<16;i++) begin
//      rx_data[i]=rx_vdm_pld.pop_front();
//    end
//    pyld_compare(tx_data,rx_data,result);
//
//    #100us; 
//    post_test_util(old_test_err_count);
//		
//end
//endtask
//
//
////Compare the payload (VDM Message) in BMC with Shared memory in PCIe BFM.
//task pyld_compare(input [15:0][31:0]tx_vdm_data,input [15:0][31:0] rx_vdm_data,output bit result);
//
//for(int i=0;i<16;i++) begin
//  if(rx_vdm_data[i]==tx_vdm_data[i])
//    $display("VDM payloads are matching on BMC and PCIe BFM side");
//  else begin
//    $display("VDM payloads are not matching ,BMC side VDM value is %h,PCIe BFM side VDM value is %h",tx_vdm_data[i],rx_vdm_data[i]);
//    test_utils::incr_err_count();
//    result = 1'b0;
//  end
//end
//endtask

task test_vdm_msg;
   output logic result;
   input e_addr_mode addr_mode;
   logic [63:0] addr;
   logic [63:0] scratch;
   logic        error;
   logic [31:0] old_test_err_count;
begin
   old_test_err_count = test_utils::get_err_count();
   result = 1'b1;
 
   $display("Test VDM RX path starts");
      WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h1}});	
      WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h2}});	 
      @(posedge fim_clk);
      WRITE32(ADDR32, PMCI_FBM_AR, 0, 1'b0, 0, 0, {8{4'h3}});	
      test_csr_read_64(result,addr_mode, ST2MM_DFH, 0, 1'b0, 0, 0, 'h3000000200000014);
      create_vdm_msg_packet('h1,'d16,'h7f,'h1ab4);
      test_csr_access_64(result, addr_mode, ST2MM_SRATCHPAD, 0, 1'b0, 0, 0, 'h1111_2222_3333_4444);   
      create_vdm_msg_packet('h1,'d13,'h7f,'h1ab4);
      test_csr_access_64(result, addr_mode, ST2MM_SRATCHPAD, 0, 1'b0, 0, 0, 'hAAAA_BBBB_CCCC_DDDD);   
      create_vdm_msg_packet('h1,'d1,'h7f,'h1ab4);
      test_csr_access_32(result, addr_mode, PMCI_FBM_AR, 0, 1'b0, 0, 0, 'h0111_2222);   
      create_vdm_msg_packet('h1,'d5,'h7f,'h1ab4);
      test_csr_access_32(result, addr_mode, PMCI_SPI_CSR, 0, 1'b0, 0, 0, 'h0000_0002);   
      create_vdm_msg_packet('h1,'d10,'h7f,'h1ab4);
      test_csr_access_32(result, addr_mode, PMCI_SPI_AR, 0, 1'b0, 0, 0, 'h0000_2222);   
      create_vdm_msg_packet('h1,'d2,'h7f,'h1ab4);
      test_csr_access_32(result, addr_mode, PMCI_SPI_WR_DR, 0, 1'b0, 0, 0, 'h1111_2222);   
      create_vdm_msg_packet('h1,'d4,'h7f,'h1ab4);
   $display("Test VDM RX path ends");
    #50us;

   post_test_util(old_test_err_count);
end
endtask

//-------------------
// Test main entry 
//-------------------
task main_test;
   output logic test_result;
   logic valid_csr_region;
begin
   test_vdm_msg    (test_result,ADDR64);
end
endtask



