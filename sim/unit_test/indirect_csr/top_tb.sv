// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Top level testbench with OFS top level module instantiated as DUT
//
//-----------------------------------------------------------------------------

module top_tb ();

//import test_utils::*;
import test_csr_defs::*;

//Timeout in 1ms
`ifdef SIM_TIMEOUT
   `define TIMEOUT `SIM_TIMEOUT
`else
   `define TIMEOUT 1000000000
`endif

localparam CMD_W = 16;
localparam AW    = 19;
localparam DW    = 64;

localparam CMD_NOOP   = 2'h0;
localparam CMD_READ   = 2'h1;
localparam CMD_WRITE  = 2'h2;

logic rst_n;
logic csr_clk, csr_rst_n;

logic [CMD_W-1:0] csr_cmd;
logic [AW-1:0]    csr_addr;
logic [DW-1:0]    csr_writedata;
logic [DW-1:0]    csr_readdata;
logic             csr_ack;
logic [1:0]       csr_rresp;
logic [1:0]       csr_bresp;

int err_count = 0;
logic [31:0] test_id;
logic [7:0] checker_err_count;
logic test_done;
logic test_result;


//---------------------------------------------------------
//  Test Utilities
//---------------------------------------------------------
function void incr_err_count();
   err_count++;
endfunction


function int get_err_count();
   return err_count;
endfunction

task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

//---------------------------------------------------------


initial begin
   csr_clk  = 1'b0;
   csr_cmd  = CMD_NOOP;
end

initial begin
   rst_n    = 1'b0;
   #1us;
   rst_n    = 1'b1;

   fork
   begin : timeout_thread
     // timeout thread, wait for TIMEOUT period to pass
     #(`TIMEOUT);
  
     // The test hasn't finished within TIMEOUT Period
     @(posedge csr_clk);
     $display ("TIMEOUT, test_pass didn't go high in 1 ms\n");
     
     disable timeout_thread;
   end

   begin : test_thread
      // Test scenarios
      $display("\nTest : Read DFH (1)");
      csr_read(DFH, DFH_VALUE);
      $display("\nTest : Write scratchpad");
      csr_write(SCRATCHPAD, 64'h1111_2222_3333_4444);
      $display("\nTest : Read scratchpad");
      csr_read(SCRATCHPAD, 64'h1111_2222_3333_4444);
      $display("\nTest : Read DFH (2)");
      csr_read(DFH, DFH_VALUE);

      if(get_err_count() == 0) begin
          $display("Test passed!");
      end else begin
          $display("Test FAILED! %d errors reported.\n", get_err_count());
      end
   end
   join_any
   $finish();
end

initial 
begin
`ifdef VCD_ON  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon();
   `endif 
`endif
end        

always #5000 csr_clk = ~csr_clk;   // 100MHz

always_ff @(posedge csr_clk) begin
   csr_rst_n <= rst_n;
end

test #(
   .CMD_W (CMD_W),
   .AW    (AW),
   .DW    (DW)
) dut (
   .i_csr_clk       (csr_clk),
   .i_csr_rst_n     (csr_rst_n),

   .i_csr_cmd       (csr_cmd),
   .i_csr_addr      (csr_addr),
   .i_csr_writedata (csr_writedata),
   .o_csr_readdata  (csr_readdata),
   .o_csr_ack       (csr_ack),
   .o_csr_rresp     (csr_rresp),
   .o_csr_bresp     (csr_bresp)
);

task csr_write;
   input logic [AW-1:0] addr;
   input logic [DW-1:0] data;
begin
   @(posedge csr_clk) begin
      csr_cmd  = {'0, CMD_WRITE}; 
      csr_addr = addr;
      csr_writedata = data;
   end
   
   repeat(5)
      @(posedge csr_clk);

   $display("   Waiting for csr_ack to be asserted");
   wait (csr_ack === 1'b1);

   if (csr_bresp !== 2'b0) begin
       $display("\nERROR: Error status is returned for CSR write.\n");
       incr_err_count();
   end

   @(posedge csr_clk) begin
      csr_cmd = {'0, CMD_NOOP};
   end

   $display("   Waiting for csr_ack to be de-asserted");
   wait (csr_ack === 1'b0);
end
endtask

task csr_read;
   input  logic [AW-1:0] addr;
   input  logic [DW-1:0] data;
begin
   @(posedge csr_clk) begin
      csr_cmd  = {'0, CMD_READ}; 
      csr_addr = addr;
   end
   
   repeat(5)
      @(posedge csr_clk);

   $display("   Waiting for csr_ack to be asserted");
   wait (csr_ack === 1'b1);
   
   if (csr_rresp !== 2'b0) begin
       $display("\nERROR: Error status is returned for CSR read.\n");
       incr_err_count();
   end else if (csr_readdata !== data) begin
       $display("\nERROR: CSR read data mismatch! expected=0x%x actual=0x%x\n", data, csr_readdata);
       incr_err_count();
   end

   @(posedge csr_clk) begin
      csr_cmd = {'0, CMD_NOOP};
   end

   $display("   Waiting for csr_ack to be de-asserted");
   wait (csr_ack === 1'b0);
end
endtask

endmodule
