// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   System reset controller
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Module ports
//-----------------------------------------------------------------------------

module rst_ctrl (
   input    logic clk_sys,             // Global clock
   input    logic clk_100m,            // Clock 100 MHz
   input    logic clk_50m,             // Clock 50 MHz
   input    logic clk_ptp_slv,         // Clock 155.56Mhz
   input    logic clk_sys_div2,        // Global clock half freq
   input    logic pll_locked,          // PLL locked flag
   input    logic pcie_reset_status,   // PCIe SRC reset status
   input    logic pcie_cold_rst_ack_n, // PCIe cold reset ack (active low)
   input    logic pcie_warm_rst_ack_n, // PCIe warm reset ack (active low),
   
   input    logic ninit_done,          // FPGA initialization done (active low)
   output   logic rst_n_sys,           // System reset synchronous to clk_sys 
   output   logic rst_n_100m,          // System reset synchronous to clk_100m
   output   logic rst_n_50m,           // System reset synchronous to clk_50m
   output   logic rst_n_sys_div2,      // System reset synchronous to clk_sys_div2
   output   logic rst_n_ptp_slv,
   output   logic pwr_good_n,          // Hardware reset synchronous to clk_sys
   output   logic pwr_good_csr_clk_n,  // power_good resetsynchronous to csr_clk (clk_100m)  
   output   logic pcie_cold_rst_n,     // PCIe cold reset synchronous to clk_sys
   output   logic pcie_warm_rst_n      // PCIe warm reset synchronous to clk_sys
);

//--------------------------------------------------------------------------
// Reset inputs 
//--------------------------------------------------------------------------
logic  rst_warm_n, rst_warm_n_sync, rst_warm_n_sync_din;
logic  rst_cold_n, rst_cold_n_sync;
logic  rst_cold_n_sync_clk100,pll_locked_sync_clk100,pcie_reset_status_sync_clk100;
logic  npor;

assign npor       = ~ninit_done;
//assign rst_cold_n = ~ninit_done && pcie_reset_perst_n; // Quartus 21.1 will not allow routing of PERST to logic.  This should be revisited as this seems to be an appropriate usage.
assign rst_cold_n = ~ninit_done;


// Sync rst_cold to clk_100
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(1),
   .NO_CUT(0)
) rst_cold_n_resync_rst_inst (
   .clk   (clk_100m),
   .reset (1'b1),
   .d     (rst_cold_n),
   .q     (rst_cold_n_sync_clk100)
);

// Sync pll_locked to clk_100
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(0)
) pll_locked_resync_rst_inst (
   .clk   (clk_100m),
   .reset (1'b0),
   .d     (pll_locked),
   .q     (pll_locked_sync_clk100)
);

// Sync pcie_reset_status to clk_100
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(1),
   .NO_CUT(0)
) pcie_reset_status_resync_rst_inst (
   .clk   (clk_100m),
   .reset (1'b0),
   .d     (pcie_reset_status),
   .q     (pcie_reset_status_sync_clk100)
);

assign rst_warm_n =  rst_cold_n_sync_clk100 && pll_locked_sync_clk100 && ~pcie_reset_status_sync_clk100;

fim_resync #(
   .SYNC_CHAIN_LENGTH(1),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(0)
) rst_warm_in_resync_rst_inst (
   .clk   (clk_100m),
   .reset (1'b0),
   .d     (rst_warm_n),
   .q     (rst_warm_n_sync_din)
);

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(0)
) rst_warm_in_resync (
   .clk   (clk_sys),
   .reset (~rst_warm_n_sync_din),
   .d     (1'b1),
   .q     (rst_warm_n_sync)
);

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(0)
) rst_cold_in_resync (
   .clk   (clk_sys),
   .reset (~rst_cold_n),
   .d     (1'b1),
   .q     (rst_cold_n_sync)
);

//--------------------------------------------------------------------------
// PCIe reset control
//--------------------------------------------------------------------------
logic pcie_cold_rst_ack_n_sync, pcie_warm_rst_ack_n_sync;
logic pcie_rst_cold_ack,        pcie_rst_warm_ack;
logic pcie_rst_cold_release,    pcie_rst_warm_release;
logic pcie_rst_cold_n,          pcie_rst_warm_n;
logic fim_rst_n;

`ifdef INCLUDE_PCIE_SS
   fim_resync #(
      .SYNC_CHAIN_LENGTH(3),
      .WIDTH(2),
      .INIT_VALUE(0),
      .NO_CUT(1)
   ) pcie_cold_rst_ack_sync (
      .clk   (clk_sys),
      .reset (1'b0),
      .d     ({pcie_cold_rst_ack_n, pcie_warm_rst_ack_n}),
      .q     ({pcie_cold_rst_ack_n_sync, pcie_warm_rst_ack_n_sync})
   );
`else
   assign pcie_cold_rst_ack_n_sync = pcie_rst_cold_n;
   assign pcie_warm_rst_ack_n_sync = pcie_rst_warm_n;
`endif

assign pcie_rst_cold_ack = (~pcie_cold_rst_ack_n_sync);
assign pcie_rst_warm_ack = (~pcie_warm_rst_ack_n_sync);
assign pcie_rst_cold_release = (pcie_rst_cold_n && pcie_cold_rst_ack_n_sync);
assign pcie_rst_warm_release = (pcie_rst_warm_n && pcie_warm_rst_ack_n_sync);

//------------------
// PCIe reset
//    Activate PCIe cold/warm reset when reset input is active
//    Wait for PCIe cold/warm reset ack
//    Release PCIe cold/warm reset
//------------------
always_ff @(posedge clk_sys) begin
   if (~rst_cold_n_sync) begin
      pcie_rst_cold_n <= 1'b0;
   end else begin
     if (~pcie_rst_cold_n && pcie_rst_cold_ack) begin
         pcie_rst_cold_n <= 1'b1;
     end
   end
end

always_ff @(posedge clk_sys) begin
   if (~rst_warm_n_sync) begin
      pcie_rst_warm_n <= 1'b0;
   end else begin
     if (~pcie_rst_warm_n && pcie_rst_warm_ack) begin
         pcie_rst_warm_n <= 1'b1;
     end
   end
end
//------------------
// FIM reset
//    Activate FIM reset when reset input is active
//    Wait for PCIe reset to be released
//    Release FIM reset
//------------------
always_ff @(posedge clk_sys) begin
   if (~rst_warm_n_sync) begin
      fim_rst_n  <= 1'b0;
   end else begin
      if (~fim_rst_n && pcie_rst_warm_release) begin
         fim_rst_n <= 1'b1;
      end
   end
end

//--------------------------------------------------------------------------
// Reset output
//--------------------------------------------------------------------------

// PCIe cold/warm reset ------------------
assign pcie_cold_rst_n = pcie_rst_cold_n; // Mapping Logic to I/O Port
assign pcie_warm_rst_n = pcie_rst_warm_n; // Mapping Logic to I/O Port
//----------------------------------------

// FIM reset synchronous to clk_sys
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) rst_clk_sys_resync (
   .clk   (clk_sys),
   .reset (~rst_warm_n | ~fim_rst_n),
   .d     (1'b1),
   .q     (rst_n_sys)
);

// FIM reset synchronous to clk_100m 
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) rst_clk100m_resync (
   .clk   (clk_100m),
   .reset (~rst_warm_n | ~fim_rst_n),
   .d     (1'b1),
   .q     (rst_n_100m)
);

// FIM reset synchronous to clk_50m 
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) rst_clk50m_resync (
   .clk   (clk_50m),
   .reset (~rst_warm_n | ~fim_rst_n),
   .d     (1'b1),
   .q     (rst_n_50m)
);

// FIM reset synchronous to clk_sys_div2
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) rst_clk_sys_div2_resync (
   .clk   (clk_sys_div2),
   .reset (~fim_rst_n),
   .d     (1'b1),
   .q     (rst_n_sys_div2)
);

fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) rst_clk_ptp_slv_resync (
   .clk   (clk_ptp_slv),
   .reset (~rst_warm_n | ~fim_rst_n),
   .d     (1'b1),
   .q     (rst_n_ptp_slv)
);

// FIM power good reset synchronous to clk_sys
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) pwr_good_n_resync (
   .clk   (clk_sys),
   .reset (~pll_locked | ninit_done),
   .d     (1'b1),
   .q     (pwr_good_n)
);

// FIM power good reset synchronous to csr_clk
fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(1),
   .INIT_VALUE(0),
   .NO_CUT(1)
) pwr_good_csr_clk_n_resync (
   .clk   (clk_100m),
   .reset (~pll_locked | ninit_done),
   .d     (1'b1),
   .q     (pwr_good_csr_clk_n)
);

endmodule
