// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Definition of AXI4 streaming interfaces used in CoreFIM
//
//-----------------------------------------------------------------------------

`ifndef __OFS_FIM_AXIS_IF_SV__
`define __OFS_FIM_AXIS_IF_SV__

import ofs_fim_if_pkg::*;

// Interface of PCIe RX AXIS channel with multiple TLP data streams 
interface ofs_fim_pcie_rxs_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_pcie_rxs rx;

   // Ready signal
   logic tready;
   
   // AXI-S channel master
   modport master (
        input  tready,
        output clk,
        output rst_n,   
        output rx
   );

   // AXI-S channel slave
   modport slave (
        output tready,
        input  clk,
        input  rst_n,
        input  rx     
   );

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(rx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));   

   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));        
   
   assert_valid_undef:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (rx.tvalid |-> (!$isunknown(rx.tdata[0].valid) && !$isunknown(rx.tdata[1].valid) )))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tdata[*].valid is undefined", $time));   
   
   assert_tdata_tuser_ch0_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ((rx.tvalid && rx.tdata[0].valid) |-> (!$isunknown(rx.tdata[0]) && !$isunknown(rx.tuser[0]))))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tdata[0] or rx.tuser[0] is undefined when rx.tdata[0].valid is asserted", $time));   
   
   assert_tdata_tuser_ch1_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ((rx.tvalid && rx.tdata[1].valid) |-> (!$isunknown(rx.tdata[1]) && !$isunknown(rx.tuser[1]))))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tdata[1] or rx.tuser[1] is undefined when rx.tdata[1].valid is asserted", $time));   

   assert_tvalid_tready_handshake:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (rx.tvalid && ~tready) |-> ##1 rx.tvalid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is dropped before acknowledged by tready", $time));
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 

endinterface : ofs_fim_pcie_rxs_axis_if

// Interface of PCIe RX AXIS channel with 1 TLP data stream
interface ofs_fim_pcie_rx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_pcie_rx rx;

   // Ready signal
   logic tready;

   // AXI-S channel master
   modport master (
        input  tready,
        output clk,
        output rst_n,   
        output rx
   );

   // AXI-S channel slave
   modport slave (
        output tready,
        input  clk,
        input  rst_n,
        input  rx     
   );   

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(rx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is undefined", $time));   
   
   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));        
   
      assert_valid_undef:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (~rx.tvalid |-> !$isunknown(rx.tdata.valid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tdata[*].valid is undefined", $time));   
   
   assert_tdata_tuser_ch0_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ((rx.tvalid && rx.tdata.valid) |-> !$isunknown(rx.tdata) ))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tdata or rx.tuser is undefined when rx.tdata.valid is asserted", $time));   
   
   assert_tvalid_tready_handshake:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (rx.tvalid && ~tready) |-> ##1 rx.tvalid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, rx.tvalid is dropped before acknowledged by tready", $time));
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 
   
endinterface : ofs_fim_pcie_rx_axis_if

// Interface of PCIe TX AXIS channel with multiple TLP data streams 
interface ofs_fim_pcie_txs_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_pcie_txs tx;

   // Ready signal
   logic tready;

   // AXI-S channel master
   modport master (
        input  tready,
        output clk,
        output rst_n,   
        output tx
   );

   // AXI-S channel master for PR boundary
   // No global signals
   modport afu_master (
        input  tready,
        output tx
   );
   
   // AXI-S channel slave
   modport slave (
        output tready,
        input  clk,
        input  rst_n,
        input  tx     
   );

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tvalid is undefined", $time));   
   
   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));        
   
   assert_valid_undef:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (tx.tvalid |-> (!$isunknown(tx.tdata[0].valid) && !$isunknown(tx.tdata[1].valid))))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tdata[*].valid is undefined", $time));   
   
   assert_tdata_tuser_ch0_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ((tx.tvalid && tx.tdata[0].valid) |-> (!$isunknown(tx.tdata[0]) && !$isunknown(tx.tuser[0]))))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tdata[0] or tx.tuser[0] is undefined when tx.tdata[0].valid is asserted", $time));   
   
   assert_tdata_tuser_ch1_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ((tx.tvalid && tx.tdata[1].valid) |-> (!$isunknown(tx.tdata[1]) && !$isunknown(tx.tuser[1]))))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tdata[1] or tx.tuser[1] is undefined when tx.tdata[1].valid is asserted", $time)); 
   
   assert_tvalid_tready_handshake:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (tx.tvalid && ~tready) |-> ##1 tx.tvalid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tvalid is dropped before acknowledged by tready", $time));
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 
   
endinterface : ofs_fim_pcie_txs_axis_if

// Interface of PCIe TX AXIS channel with 1 TLP data stream
interface ofs_fim_pcie_tx_axis_if ();
   logic clk;
   logic rst_n; // Active-low reset

   // struct declaration contains tvalid, tlast, tdata, and tuser signals of the AXIS channel
   t_axis_pcie_tx tx;

   // Ready signal
   logic tready;

   // AXI-S channel master
   modport master (
        input  tready,
        output clk,
        output rst_n,   
        output tx
   );

   // AXI-S channel slave 
   modport slave (
        output tready,
        input  clk,
        input  rst_n,
        input  tx     
   );

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tx.tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tvalid is undefined", $time));   
   
   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));        
   
   assert_valid_when_tvalid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (tx.tvalid |-> !$isunknown(tx.tdata.valid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tdata[*].valid is undefined when tvalid is asserted", $time));   
   
   assert_tdata_tuser_ch0_undef_when_valid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (tx.tvalid && tx.tdata.valid) |-> !$isunknown(tx.tdata) ))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tdata or tx.tuser is undefined when tvalid and valid is asserted", $time));   
   
   assert_tvalid_tready_handshake:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (tx.tvalid && ~tready) |-> ##1 tx.tvalid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tx.tvalid is dropped before acknowledged by tready", $time));
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 

endinterface : ofs_fim_pcie_tx_axis_if

// Interface of PCIe AXIS interrupt response channel
interface ofs_fim_afu_irq_rsp_axis_if #(
   parameter TDATA_WIDTH = 24
);
   logic                       clk;
   logic                       rst_n;
   logic                       tvalid;
   logic                       tready;
   logic [TDATA_WIDTH-1:0]     tdata;

    modport master (
        input  tready,
        output clk, rst_n, tvalid, tdata  
    );
    modport slave (
        output tready,
        input  clk, rst_n, tvalid, tdata     
    );

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tvalid is undefined", $time));   
   
   assert_tready_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tready)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tready is undefined", $time));        
   
   assert_tdata_undef_when_tvalid_high:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (tvalid |-> (!$isunknown(tdata) )))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tdata is undefined when tdata.valid is asserted", $time));   
   
   assert_tvalid_tready_handshake:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) ( (tvalid && ~tready) |-> ##1 tvalid))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tvalid is dropped before acknowledged by tready", $time));
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 
    
endinterface : ofs_fim_afu_irq_rsp_axis_if

// Interface of AXIS IRQ channel
interface ofs_fim_irq_axis_if ();
   logic                       clk;
   logic                       rst_n;
   logic                       tvalid;

    modport master (
        output clk, rst_n, tvalid 
    );
    modport slave (
        input  clk, rst_n, tvalid     
    );

`ifdef OFS_FIM_ASSERT_OFF
   `define OFS_FIM_AXIS_IF_ASSERT_OFF
`endif  // OFS_FIM_ASSERT_OFF
   
`ifndef OFS_FIM_AXIS_IF_ASSERT_OFF
// synopsys translate_off
   logic enable_assertion;

   initial begin
      enable_assertion = 1'b0;
      repeat(2) 
         @(posedge clk);

      wait (rst_n === 1'b0);
      wait (rst_n === 1'b1);
      
      enable_assertion = 1'b1;
   end

   assert_tvalid_undef_when_not_in_reset:
      assert property (@(posedge clk) disable iff (~rst_n || ~enable_assertion) (!$isunknown(tvalid)))
      else $fatal(0,$psprintf("%8t: %m ASSERTION_ERROR, tvalid is undefined", $time));   
// synopsys translate_on
`endif  // OFS_FIM_AXIS_IF_ASSERT_OFF 

endinterface : ofs_fim_irq_axis_if

`endif // __OFS_FIM_AXIS_IF_SV__
