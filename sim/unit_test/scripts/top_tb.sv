// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Top level testbench with OFS top level module instantaited as DUT
//
//-----------------------------------------------------------------------------

`include "vendor_defines.vh"
`include "fpga_defines.vh"

import ofs_fim_cfg_pkg::*;
import ofs_fim_if_pkg::*;
import ofs_fim_pcie_hdr_def::*;
import ofs_fim_pcie_pkg::*;

module top_tb ();

logic SYS_REFCLK;
logic PCIE_REFCLK0;
logic PCIE_REFCLK1;
logic PCIE_RESET_N;

initial begin
   SYS_REFCLK = 0;
   PCIE_REFCLK0 = 0;
   PCIE_REFCLK1 = 0;
   PCIE_RESET_N = 0;
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

`ifdef INCLUDE_DDR4
   ofs_fim_emif_x32_if ddr4_x32 [1:0] ();// [3:0] ();
   ofs_fim_emif_x40_if ddr4_x40 [1:0] ();// [3:0] ();
   ofs_fim_emif_x40_if ddr4_hps ();
`endif

initial #2us PCIE_RESET_N = 1; //  IOPLL sim model requires at least 1us of reset
always #5000 SYS_REFCLK = ~SYS_REFCLK; // 100MHz
always #5000 PCIE_REFCLK0 = ~PCIE_REFCLK0; // 100MHz
always #5000 PCIE_REFCLK1 = ~PCIE_REFCLK1; // 100MHz

top DUT (
   .SYS_REFCLK      (SYS_REFCLK),
   .PCIE_REFCLK0    (PCIE_REFCLK0),
   .PCIE_REFCLK1    (PCIE_REFCLK1),
   .PCIE_RESET_N    (PCIE_RESET_N),
 `ifdef INCLUDE_DDR4
   .ddr4_mem     (ddr4_mem),
`endif  
   .PCIE_RX_P       ('0),
   .PCIE_RX_N       ('0),
   .PCIE_TX_P       (),
   .PCIE_TX_N       ()
);


endmodule
