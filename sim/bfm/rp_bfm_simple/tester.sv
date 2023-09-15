// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Tester module
//
//-----------------------------------------------------------------------------
`timescale 1ps / 1ps

`include "fpga_defines.vh"
`include "test_utils.sv"


module tester #(
   parameter MAX_TEST = 100,
   parameter MEM_ADDR_SIZE = 20, // DW size
   parameter TLP_BUF_SIZE = 512
)(
   input  logic                            avl_clk,
   input  logic                            avl_rst_n,   
   input  logic                            fim_clk,
   input  logic                            fim_rst_n,

   // Input RX TLP from upstream
   output  t_avst_rxs                      o_avl_rx_st,    // AVST RX channels carrying Rx TLP from upstream logic 
   input logic                             i_avl_rx_ready, // Backpressure signal to upstream logic
   input   t_avst_txs                      i_avl_tx_st,
   output logic                            o_avl_tx_ready,

   output  t_avst_rxs                      o_avl_rxreq_st,    // AVST RX channels carrying Rx TLP from upstream logic 
   input logic                             i_avl_rxreq_ready, // Backpressure signal to upstream logic

   // Error sideband signals to upstream PCIe IP
   input logic                             i_b2a_app_err_valid,    // Error is detected in the incoming TLP
   input logic [31:0]                      i_b2a_app_err_hdr,      // Header of the erroneous TLP
   input logic [10:0]                      i_b2a_app_err_info,     // Info of the error
   input logic [1:0]                       i_b2a_app_err_func_num, // Function number associated with the erroneous TLP

   // Error signals to PCIe error status registers
   input logic                             i_chk_rx_err,           // Error is detected in the incoming TLP
   input logic                             i_chk_rx_err_vf_act,    // Indicates if error is associated with PF or VF
   input logic [ofs_fim_pcie_pkg::PF_WIDTH-1:0]              i_chk_rx_err_pfn,       // PF associated with the erroneous TLP
   input logic [ofs_fim_pcie_pkg::VF_WIDTH-1:0]              i_chk_rx_err_vfn,       // VF associated with the erroneous TLP
   input logic [31:0]                      i_chk_rx_err_code,      // Error info

   input t_sideband_from_pcie              i_pcie_p2c_sideband,
   input  logic [7:0]                      i_flr_pf_done,
   output logic [7:0]                      o_flr_pf_active,
   output logic                            o_flr_rcvd_vf,
   output logic [2:0]                      o_flr_rcvd_pf_num,
   output logic [10:0]                     o_flr_rcvd_vf_num,
   input  logic                            i_flr_completed_vf,
   input  logic [2:0]                      i_flr_completed_pf_num,
   input  logic [10:0]                     i_flr_completed_vf_num
);

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_pkg::*;
import ofs_fim_pcie_hdr_def::*;

//Timeout in 1ms
`ifdef SIM_TIMEOUT
   `define TIMEOUT `SIM_TIMEOUT
`else
//   `define TIMEOUT 1000000000
     `define TIMEOUT 64'd15000000000
`endif

localparam LOG2_TLP_BUF_SIZE = $clog2(TLP_BUF_SIZE);
localparam MAX_NUM_VF = (1<<11);

`ifdef RP_MAX_TAGS
   localparam RP_MAX_TAGS = `RP_MAX_TAGS;
`else
   localparam RP_MAX_TAGS = 64;
`endif

localparam RP_TAG_WIDTH = $clog2(RP_MAX_TAGS);

typedef logic [RP_TAG_WIDTH-1:0] t_tlp_rp_tag;

typedef struct packed {
   logic                vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;
} t_id;

typedef struct packed {
   t_id         requester_id;
   t_id         completer_id;
   logic [6:0]  lower_addr;
} t_req_info;

typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;


logic [31:0] test_id;
logic reset_test;
logic test_done;
logic test_result;
t_test_info [MAX_TEST-1:0] test_summary;

//-----------------------
// Test packets buffer
//-----------------------
// This buffer stores the packets from the test cases
t_avst_pcie_rx [TLP_BUF_SIZE-1:0] tx_buffer;
t_avst_pcie_rx [NUM_AVST_CH-1:0]  tx_packet;
logic [LOG2_TLP_BUF_SIZE:0]   num_tx_packet;
logic [LOG2_TLP_BUF_SIZE-1:0] tx_buf_idx;

// This buffer stores the memory read response packets
logic [LOG2_TLP_BUF_SIZE:0]   num_mem_packet;
t_avst_pcie_rx [NUM_AVST_CH-1:0]  mem_tx_packet;
logic [LOG2_TLP_BUF_SIZE-1:0] mem_tx_buf_idx;

// Packet sender
logic send_test_packet, send_mem_packet;
logic send_test_ack, send_mem_ack;
t_tlp_rp_tag tester_tag;
logic      [RP_MAX_TAGS-1:0] tag_active; 
t_req_info [RP_MAX_TAGS-1:0] tag_req_info;

// PCIe checker error
logic [7:0] checker_err_count;
logic [255:0][10:0] checker_err_info; 
logic [255:0][1:0]  checker_err_func; 

// Packet receiver
logic clear_rx_buf;

// PCIe error code to downstream module
logic [31:0] pcie_p2c_chk_err_code;

// FLR signals
logic assert_flr;

logic        vf_active;
logic [2:0]  flr_pfn;
logic [10:0] flr_vfn;
logic [7:0][MAX_NUM_VF-1:0] flr_vf_active;

/////////////////////////////////////////////////////////////////////////

initial begin
   test_utils::init_logfile("reg.rout");
end

initial begin
   reset_test = 1'b0;
   test_id = '0;
   test_done = 1'b0;
   test_result = 1'b0;
   tester_tag = '0;
   
   tx_buffer = '0;
   num_tx_packet = '0;
   send_test_packet = 1'b0;
   
   clear_rx_buf  = 1'b0;

   assert_flr   = 1'b0;
end

initial begin
   fork: timeout_thread begin
     // timeout thread, wait for TIMEOUT period to pass
     #(`TIMEOUT);
  
     // The test hasn't finished within TIMEOUT Period
     @(posedge avl_clk);
     $display ("TIMEOUT, test_pass didn't go high in 1 ms\n");
     
     disable timeout_thread;
   end
 
   wait (test_done==1) begin
      // Test summary
      $display("\n********************");
      $display("  Test summary");
      $display("********************");
      for (int i=0; i < test_id; i=i+1) begin
         if (test_summary[i].result)
            $display("   %0s (id=%0d) - pass", test_summary[i].name, i);
         else
            $display("   %0s (id=%0d) - FAILED", test_summary[i].name, i);
      end

      if(test_utils::get_err_count() == 0 && test_utils::get_assert_err_count() == 0) begin
          $fdisplay(test_utils::get_logfile_handle(), "Test passed!");
       end else begin
          if (test_utils::get_err_count() != 0) begin
             $fdisplay(test_utils::get_logfile_handle(), "Test FAILED! %d errors reported.\n", test_utils::get_err_count());
          end
          if (test_utils::get_assert_err_count() != 0) begin
             $fdisplay(test_utils::get_logfile_handle(), "Test FAILED! %d assertion errors reported.", test_utils::get_assert_err_count());
          end
       end
       $display("Assertion count: %0d", test_utils::get_assert_count());
   end
   
   join_any    
   $finish();  
end

always begin : main   
   #10000;
   wait (avl_rst_n);
   wait (fim_rst_n);
   //-------------------------
   // deassert port reset
   //-------------------------
   deassert_afu_reset();
   //-------------------------
   // Test scenarios 
   //-------------------------
   main_test(test_result);
   test_done = 1'b1;
end

//------------------------
// TLP packet sender
//------------------------
always_comb begin
   if (tx_buf_idx == num_tx_packet-1) begin
      tx_packet = {'0, tx_buffer[tx_buf_idx]};
   end else begin
      tx_packet = tx_buffer[tx_buf_idx+:2]; 
   end
end

// Packet sender arbitrates between test packets interface and memory response interface
packet_sender #(
   .BUF_SIZE    (TLP_BUF_SIZE),
   .NUM_PKT_BUF (1)
) mem_packet_sender (
   .clk         (avl_clk),
   .rst_n       (avl_rst_n),

   // Packet from test case 
   .i_buf_size  (num_mem_packet),
   .i_send_req  (send_mem_packet),
   .o_send_ack  (send_mem_ack),
   .o_buf_idx   (mem_tx_buf_idx),
   .i_packet    (mem_tx_packet),
   
   // Packet sender interface
   .i_ready     (i_avl_rx_ready),
   .o_rx_st     (o_avl_rx_st)
);

packet_sender #(
   .BUF_SIZE    (TLP_BUF_SIZE),
   .NUM_PKT_BUF (1)
) test_packet_sender (
   .clk         (avl_clk),
   .rst_n       (avl_rst_n),

   // Packet from test case 
   .i_buf_size  (num_tx_packet),
   .i_send_req  (send_test_packet),
   .o_send_ack  (send_test_ack),
   .o_buf_idx   (tx_buf_idx),
   .i_packet    (tx_packet),
   
   // Packet sender interface
   .i_ready     (i_avl_rxreq_ready),
   .o_rx_st     (o_avl_rxreq_st)
);

//------------------------
// TLP receiver
//------------------------
t_avst_pcie_tx cpl_st;
t_avst_pcie_tx mem_st;

logic cpl_st_ready;
logic mem_st_ready;

packet_receiver #(
   .BUF_SIZE(TLP_BUF_SIZE),
   .READY_LATENCY(3) // Mimic PCIe IP ready latency
) packet_receiver (
   .clk             (avl_clk),
   .rst_n           (avl_rst_n && ~clear_rx_buf),

   // Packet receiver interface
   .i_tx_st         (i_avl_tx_st),
   .o_tx_st_ready   (o_avl_tx_ready),

   .o_cpl_st        (cpl_st),
   .i_cpl_st_ready  (cpl_st_ready),

   .o_mem_st        (mem_st),
   .i_mem_st_ready  (mem_st_ready)
);

//------------------------
// MMIO Request/Response
//------------------------
typedef struct packed {
   logic rsp_valid;
   logic [63:0] rsp_data;
   logic [2:0]  rsp_status;
} t_mmio_entry;

t_mmio_entry [255:0] tester_mmio_buf;
t_mmio_entry         tester_mmio_entry;

logic         tester_mmio_req_valid;
t_tlp_rp_tag  tester_mmio_req_tag;
t_req_info    tester_mmio_req_info;
logic         tester_mmio_buf_rd;
logic [7:0]   tester_mmio_buf_raddr;

t_tlp_cpl_hdr cpl_hdr;
logic         cpl_hdr_4dw;
 
initial begin
   tester_mmio_req_valid = 1'b0;
end

`ifdef HTILE
   assign cpl_hdr = to_big_endian(cpl_st.data[127:0]);
`else
   assign cpl_hdr = cpl_st.hdr;
`endif

assign cpl_hdr_4dw  = func_is_addr64(cpl_hdr.dw0.fmttype);

// De-assert ready when previous response wth the same tag hasn't been consumed
assign cpl_st_ready = ~tester_mmio_buf[cpl_hdr.tag].rsp_valid;

// MMIO request
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      tester_mmio_buf <= '0;
      tag_active <= '0;
   end else begin
      if (cpl_st.valid && cpl_st_ready) begin
         if (tag_active[cpl_hdr.tag]) begin
            if (func_unexp_cpl(cpl_hdr, tag_req_info[cpl_hdr.tag])) begin
               $finish();
            end

            tester_mmio_buf[cpl_hdr.tag].rsp_valid <= 1'b1;
            tag_active[cpl_hdr.tag] <= 1'b0;
         end
         
         `ifdef HTILE
            tester_mmio_buf[cpl_hdr.tag].rsp_data  <= cpl_hdr_4dw ? cpl_st.data[128+:64] : cpl_st.data[96+:64]; 
         `else
            tester_mmio_buf[cpl_hdr.tag].rsp_data  <= cpl_st.data[63:0]; 
         `endif

         tester_mmio_buf[cpl_hdr.tag].rsp_status <= cpl_hdr.status;
      end

      if (tester_mmio_req_valid) begin
         tag_active[tester_mmio_req_tag]   <= 1'b1;
         tag_req_info[tester_mmio_req_tag] <= tester_mmio_req_info;
      end

      if (tester_mmio_buf_rd) begin
         tester_mmio_entry <= tester_mmio_buf[tester_mmio_buf_raddr];
         tester_mmio_buf[tester_mmio_buf_raddr].rsp_valid <= 1'b0;
      end
   end
end

//------------------------
// Shared memory
//------------------------
shmem #(
   .MEM_ADDR_SIZE (MEM_ADDR_SIZE),
   .TLP_BUF_SIZE  (TLP_BUF_SIZE)
) shmem (
   .clk           (avl_clk),
   .rst_n         (avl_rst_n),

   .mem_st        (mem_st),
   .mem_st_ready  (mem_st_ready),

   .send_req      (send_mem_packet),
   .send_ack      (send_mem_ack),
   .num_tx_packet (num_mem_packet),
   .tx_buf_idx    (mem_tx_buf_idx),
   .tx_packet     (mem_tx_packet)
);

//------------------------
// Checker error logging
//------------------------
// Sticky error registers until reset
always_ff @(posedge fim_clk) begin
   if (~avl_rst_n || reset_test) begin
      pcie_p2c_chk_err_code <= '0;
   end else begin
      pcie_p2c_chk_err_code <= (pcie_p2c_chk_err_code | i_pcie_p2c_sideband.pcie_chk_rx_err_code);
   end
end

// PCIe checker error count
always_ff @(posedge avl_clk) begin
   if (~avl_rst_n) begin
      checker_err_count <= '0;
   end else begin
      if (reset_test) begin 
         checker_err_count <= '0;
      end else if (i_b2a_app_err_valid) begin
         checker_err_info[checker_err_count] <= i_b2a_app_err_info;
         checker_err_func[checker_err_count] <= i_b2a_app_err_func_num;
         checker_err_count <= checker_err_count + 1;
      end
   end
end

//------------------------
// FLR BFM
//------------------------
pcie_flr #(
   .MAX_NUM_VF (MAX_NUM_VF)
) pcie_flr (
   .clk                    (avl_clk),
   .rst_n                  (avl_rst_n),
   .i_assert_flr           (assert_flr),
   .i_vf_active            (vf_active),
   .i_pf_num               (flr_pfn),
   .i_vf_num               (flr_vfn),
   .i_flr_pf_done          (i_flr_pf_done),
   .o_flr_pf_active        (o_flr_pf_active),
   .o_flr_rcvd_vf          (o_flr_rcvd_vf),
   .o_flr_rcvd_pf_num      (o_flr_rcvd_pf_num),
   .o_flr_rcvd_vf_num      (o_flr_rcvd_vf_num),
   .o_flr_vf_active        (flr_vf_active), 
   .i_flr_completed_vf     (i_flr_completed_vf),
   .i_flr_completed_pf_num (i_flr_completed_pf_num),
   .i_flr_completed_vf_num (i_flr_completed_vf_num)
);

//--------------------
// Funtions & Tasks
//--------------------
function automatic bit func_unexp_cpl (
   t_tlp_cpl_hdr  cpl_hdr,
   t_req_info     req_info
);
   logic unexp_cpl;
   logic vf_active;
   logic [PF_WIDTH-1:0] pfn;
   logic [VF_WIDTH-1:0] vfn;

   vf_active    = cpl_hdr.completer_id[3];
   pfn          = cpl_hdr.completer_id[2:0];
   vfn          = cpl_hdr.completer_id[15:4];

   unexp_cpl = 1'b0;

   if (cpl_hdr.requester_id !== req_info.requester_id) begin
      unexp_cpl = 1'b1;
   end

   if (vf_active !== req_info.completer_id.vf_active) begin
      unexp_cpl = 1'b1;
   end

   if (pfn !== req_info.completer_id.pfn) begin
      unexp_cpl = 1'b1;
   end

   if (vfn !== req_info.completer_id.vfn) begin
      unexp_cpl = 1'b1;
   end

   if (unexp_cpl) begin
      $display("\nError: unexpected CPL (tag=%0d)", cpl_hdr.tag);
      $display("      Request    (requester_id=0x%0x   vf_active=%0b   pfn=0x%0x   vfn=0x%0x)", req_info.requester_id, req_info.completer_id.vf_active, req_info.completer_id.pfn, req_info.completer_id.vfn);
      $display("      Completion (requester_id=0x%0x   vf_active=%0b   pfn=0x%0x   vfn=0x%0x)\n", cpl_hdr.requester_id, vf_active, pfn, vfn);
      $fatal(0, $psprintf("%8t: %m Unexpected CPL is received with tag=%0d", $time, cpl_hdr.tag));
   end

   return unexp_cpl;
endfunction


//-------------------------------------------------------
// Test cases
//-------------------------------------------------------
`include "tester_utils.sv"
`include "tester_tests.sv"

endmodule
