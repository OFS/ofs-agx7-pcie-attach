// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   FME Testbench Top.
//
//   This file provides the overall module connectivity for the FME unit test.
//
//-----------------------------------------------------------------------------
`timescale 1 ns/10 ps

module testbench_top;
//---------------------------------------------------------
// Packages
//---------------------------------------------------------
import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_csr_pkg::*;
import fme_csr_pkg::*;

parameter clk_cycle = 10ns; // 100MHz Clock

logic clk   = 1'b0;


//---------------------------------------------------------
// Instantiation of the AXI Interface
//---------------------------------------------------------
ofs_fim_axi_mmio_if #(
   .AWID_WIDTH   (MMIO_TID_WIDTH),
   .AWADDR_WIDTH (MMIO_ADDR_WIDTH),
   .WDATA_WIDTH  (MMIO_DATA_WIDTH),
   .ARID_WIDTH   (MMIO_TID_WIDTH),
   .ARADDR_WIDTH (MMIO_ADDR_WIDTH),
   .RDATA_WIDTH  (MMIO_DATA_WIDTH)
) axi();


//---------------------------------------------------------
// Instantiation of the FME I/O Interface
//---------------------------------------------------------
fme_csr_io_if #(
   .CSR_REG_WIDTH(64)
) fme_io();


//---------------------------------------------------------
// Instantiation of the Power Good Signal Interface
//  This is done primarily to simplify simulation in 
//  test block.
//---------------------------------------------------------
ofs_fim_pwrgoodn_if pgn();


//---------------------------------------------------------
// Clock Logic
//---------------------------------------------------------
initial
begin
   forever #(clk_cycle/2) clk = ~clk;
end


//---------------------------------------------------------
// Turn on VCD Plus dumping for logic and memory.
//---------------------------------------------------------
initial
begin
   $vcdpluson();
   $vcdplusmemon();
end


//---------------------------------------------------------
// Turn on FSDB dumping for logic and memory so that VERDI
// tools can be used for interactive simulation.
//---------------------------------------------------------
//initial
//begin
//   $fsdbDumpfile("fme_test.fsdb");
//   $fsdbDumpvars(0,testbench_top,"+all","+mda");
//   $fsdbDumpMem();
//end


//---------------------------------------------------------
// Instantiation of the register example.
//---------------------------------------------------------
fme_csr dut(
   .pgn(pgn), 
   .axi(axi),
   .fme_io(fme_io)
);


//---------------------------------------------------------
// Instantiation of the test block running the simulation.
//---------------------------------------------------------
test_csr_directed directed_test(
   .clk(clk),
   .pgn(pgn),
   .axi(axi),
   .fme_io(fme_io)
);

endmodule
