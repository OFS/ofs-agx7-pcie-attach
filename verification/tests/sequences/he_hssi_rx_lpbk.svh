//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class he_hssi_rx_lpbk_seq is executed by he_hssi_rx_lpbk_25G_10G_test 
 * This sequence waits for HSSI IP to be stable and ENABLES the RX_LPBK bit of HE_HSSI
 * The LPBK data is compared on ethernet_scoreboard
 *
 * Sequence is running on virtual_sequencer 
 *
*/
//===============================================================================================================

`ifndef HE_HSSI_RX_LPBK_SEQ_SVH
`define HE_HSSI_RX_LPBK_SEQ_SVH

class he_hssi_rx_lpbk_seq extends base_seq;
    `uvm_object_utils(he_hssi_rx_lpbk_seq)

    /*parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter TRAFFIC_CTRL_CH_SEL = 32'h40;
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;
    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_NOOP = 32'h0;
    parameter MB_RD = 32'h1;
    parameter MB_WR = 32'h2;
    parameter HSSI_RCFG_CMD0 = 32'h28;*/
    
    parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter TRAFFIC_CTRL_CH_SEL = 32'h40;
    parameter TG_PKT_LEN_TYPE_ADDR =32'h3801;
    //parameter TG_PKT_LEN_TYPE_VAL=1'b0;
    parameter TG_PKT_LEN_ADDR=32'h380D;
    parameter TG_PKT_LEN_VAL=32'h42;
    parameter TG_DATA_PATTERN_ADDR=32'h3802;
    parameter LOOPBACK_EN_ADDR = 32'h3A00;
    //parameter TG_DATA_PATTERN_VAL=32'h0;
    parameter TG_NUM_PKT_ADDR=32'h3800;
    parameter TG_NUM_PKT_VAL=32'h20;
    parameter TG_START_XFR_ADDR=32'h3803;
    parameter TG_STOP_XFR_ADDR=32'h3804;
    parameter TG_SRC_MAC_L_ADDR=32'h3805;
    parameter TG_SRC_MAC_H_ADDR=32'h3806;
    parameter TG_DST_MAC_L_ADDR=32'h3807;
    parameter TG_DST_MAC_H_ADDR=32'h3808;
    parameter TG_PKT_XFRD_ADDR=32'h3809;
    parameter TG_RANDOM_SEED0_ADDR=32'h380A;
    parameter TG_RANDOM_SEED1_ADDR=32'h380B;
    parameter TG_RANDOM_SEED2_ADDR=32'h380C;
    parameter TM_PKT_BAD_ADDR=32'h3902;
    parameter TM_PKT_GOOD_ADDR=32'h3901;
    parameter TM_NUM_PKT_ADDR=32'h3900;
    parameter TM_BYTE_COUNT0_ADDR=32'h3903;
    parameter TM_BYTE_COUNT1_ADDR=32'h3904;
    parameter TM_LOOPBACK_EN_ADDR=32'h3A00;
    parameter TM_LOOPBACK_FIFO_ADDR=32'h3A01;
    parameter TM_FIFO_ADDR=32'h3A80;
  
    parameter MB_ADDRESS_OFFSET = 32'h4;
    parameter MB_RDDATA_OFFSET  = 32'h8;
    parameter MB_WRDATA_OFFSET  = 32'hC;
    parameter MB_NOOP = 32'h0;
    parameter MB_RD = 32'h1;
    parameter MB_WR = 32'h2;
    parameter RX_STATISTICS_ADDR = 32'h3000;
    parameter TX_STATISTICS_ADDR = 32'h7000;
    parameter HSSI_RCFG_CMD_ADDR = 32'h28;

    
   logic [63:0] wdata;
   logic [63:0] addr;
   int Lane;
   function new (string name = "he_hssi_rx_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
       super.body();
	    `uvm_info(get_name(), "Entering sequence...", UVM_LOW)
       //uvm_config_db #(int )::get(null, "uvm_test_top.tb_env0", "Lane", Lane);
       //if (!uvm_config_db#(int)::get(null,"uvm_test_top.tb_env0", "Lane", Lane))
       $display("INFO:%t	WAIT TO UP all HSSI PORTS",$time);
       //`uvm_fatal("RX_LPBKSEQUNCE","LANE IS NOT SELECTED");
        `ifdef FTILE_SIM
           wait_for_f_tile_hssi_to_ready();
        `else
           wait_for_hssi_to_ready(Lane);
         `endif
 
       $display("INFO:%t   All HSSI PORTS ARE UP",$time);
       ENABLE_LPBK(Lane);
       $display("INFO:%t  LPBK ENABLED FOR ALL PORTS",$time);
       `uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask : body

    task write_mailbox();
        input [63:0] cmd_ctrl_addr;
	input [63:0] addr;
	input [63:0] write_data32;
	begin
            #2000 mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
            #2000 mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr      );
            #2000 mmio_write32(cmd_ctrl_addr                    , MB_WR       );
	    #2000 read_ack_mailbox(cmd_ctrl_addr);
            #2000 mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
	end
    endtask : write_mailbox

    task read_ack_mailbox;
        input bit [63:0] cmd_ctrl_addr;
        begin
	    bit [63:0] rdata = 64'h0;
	    int        rd_attempts = 0;
	    bit        ack_done_reg = 0;
	    while(~ack_done_reg && rd_attempts < 7) begin
                //mmio_read64(cmd_ctrl_addr, rdata);
                mmio_read32(cmd_ctrl_addr, rdata);
		ack_done_reg = rdata[2];
		rd_attempts++;
	    end

	    if(~ack_done_reg)
	        `uvm_fatal(get_name(), "Did not ACK for last transaction!")

	end
    endtask : read_ack_mailbox
task read_mailbox;
   input  logic [63:0] cur_pf_table;
   input  logic [31:0] bar;
   input  logic [63:0] cmd_ctrl_addr; // Start address of mailbox access reg
   input  logic [63:0] addr; //Byte address
   output logic [63:0] rd_data64;
   begin
      mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr); // DW address
      mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
      read_ack_mailbox(cmd_ctrl_addr);
      mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
     $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
      mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
   end
endtask

`ifndef FTILE_SIM
task wait_for_hssi_to_ready;
   input int            Lane;
   logic [2:0]          bar;
   logic                error;
   logic                result;
   logic [63:0]         scratch;
   logic [63:0] addr;
   logic [63:0] rdata;
   begin
      bar         = 3'h0;
      // Ports                                                                                                              
     `ifdef INCLUDE_HSSI_PORT_0
     //Port-0
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,0);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p0_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,0);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p0_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 0);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p0_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 0);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 0);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 0);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p0_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p0_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 0);
      end                                                       
      join_none
      wait fork;

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hc0; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 0,rdata[4],rdata[0]);
      `endif
      //`ifdef INCLUDE_HSSI_PORT_1
      // Port-1
      `ifdef INCLUDE_HSSI_PORT_1
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,1);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p1_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,1);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p1_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 1);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p1_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 1);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 1);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 1);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p1_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p1_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 1);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hc4; //HSSI_PORT1_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 1,rdata[4],rdata[0]);
      `endif
      //`ifdef INCLUDE_HSSI_PORT_2
      // Port-2
      `ifdef INCLUDE_HSSI_PORT_2
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,2);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p2_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p2_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 2);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p2_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 2);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 2);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p2_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p2_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 2);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hc8; //HSSI_PORT2_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 2,rdata[4],rdata[0]);
      `endif

      //`ifdef INCLUDE_HSSI_PORT_3
      // Port-3
      `ifdef INCLUDE_HSSI_PORT_3
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,3);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p3_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,3);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p3_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 3);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p3_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 3);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 3);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 3);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p3_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p3_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 3);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hcc; //HSSI_PORT3_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 3,rdata[4],rdata[0]);
      `endif

      //`ifdef INCLUDE_HSSI_PORT_4
     // Port-4
      `ifdef INCLUDE_HSSI_PORT_4
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,4);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p4_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,4);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p4_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 4);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p4_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 4);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 4);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 4);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p4_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p4_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 4);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd0; //HSSI_PORT4_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 4,rdata[4],rdata[0]);
      `endif
      //`ifdef INCLUDE_HSSI_PORT_5
     // Port-5
      `ifdef INCLUDE_HSSI_PORT_5
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,5);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p5_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,5);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p5_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 5);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p5_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 5);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 5);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 5);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p5_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p5_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 5);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd4; //HSSI_PORT5_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 5,rdata[4],rdata[0]);
       `endif
      //`ifdef INCLUDE_HSSI_PORT_6
      // Port-6
      `ifdef INCLUDE_HSSI_PORT_6
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,6);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p6_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,6);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p6_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 6);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p6_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 6);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 6);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 6);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p6_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p6_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 6);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd8; //HSSI_PORT6_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 6,rdata[4],rdata[0]);
       `endif
     // `ifdef INCLUDE_HSSI_PORT_7
      // Port-7
     `ifdef INCLUDE_HSSI_PORT_7
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,7);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p7_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,7);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p7_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 7);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.p7_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 7);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 7);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 7);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.p7_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p7_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 7);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hdc; //HSSI_PORT7_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 7,rdata[4],rdata[0]);
       `endif
      //#5000000;
      #5us;
        $display("INFO:%t	HSSI_READY Sequence Complete",$time);

      // Check rx pcs ready, tx lane stable and pll lock by reading register
      //test_csr_ro_access_64(result, ADDR32, HSSI_WRAP_STATUS_ADDR, bar, vf_active, pfn, vfn, HSSI_WRAP_STATUS_VAL);
      
   end
endtask
`endif
`ifdef FTILE_SIM
task wait_for_f_tile_hssi_to_ready;
   logic [2:0]          bar;
   logic                vf_active;
   logic                error;
   logic                result;
   logic [31:0]         scratch;
   begin
      bar         = 3'h0;
      vf_active   = 1'b0;
      // Port-0
      `ifdef INCLUDE_HSSI_PORT_0
      fork begin
        //$display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,0);
        //wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p0_ehip_ready == 1);
        //wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p0_ehip_ready == 1);
        //$display ("INFO:%t	Port %0d - EHIP READY is 1", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,0);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p0.eth_f_top_p0.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 0);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p0.eth_f_top_p0.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 0);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 0);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 0);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p0.eth_f_top_p0.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p0_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 0);
      end
      join_none
      wait fork;

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h000c0; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 0,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_1
      // Port-1
      fork begin
       // $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,1);
       // wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p1_ehip_ready == 1);
       // $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,1);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p1.eth_f_top_p1.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 1);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p1.eth_f_top_p1.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 1);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 1);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 1);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p1.eth_f_top_p1.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p1_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 1);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hc4; //HSSI_PORT1_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 1,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_2
      // Port-2
      fork begin
      //  $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,2);
      //  wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p2_ehip_ready == 1);
      //  $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p2.eth_f_top_p2.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 2);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p2.eth_f_top_p2.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 2);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 2);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p2.eth_f_top_p2.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p2_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 2);
      end
      join_none
      wait fork;

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hc8; //HSSI_PORT2_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 2,rdata[4],rdata[0]);
      `endif
      `ifdef INCLUDE_HSSI_PORT_3
      // Port-3
      fork begin
      //  $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,3);
      //  wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p3_ehip_ready == 1);
      //  $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,3);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p3.eth_f_top_p3.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 2);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p3.eth_f_top_p3.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 2);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 2);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p3.eth_f_top_p3.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p2_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 2);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hcc; //HSSI_PORT3_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 3,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_4
     // Port-4
      fork begin
       // $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,4);
       // wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p4_ehip_ready == 1);
       // $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,4);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p4.eth_f_top_p4.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 4);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p4.eth_f_top_p4.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 4);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 4);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 4);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p4.eth_f_top_p4.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p4_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 4);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd0; //HSSI_PORT4_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 4,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_5
     // Port-5
      fork begin
       // $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,5);
       // wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p5_ehip_ready == 1);
       // $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,5);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p5.eth_f_top_p5.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 5);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p5.eth_f_top_p5.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 5);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 5);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 5);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p5.eth_f_top_p5.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p5_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 5);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd4; //HSSI_PORT5_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 5,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_6
      // Port-6
      fork begin
        //$display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,6);
        //wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p6_ehip_ready == 1);
        //$display ("INFO:%t	Port %0d - EHIP READY is 1", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,6);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p6.eth_f_top_p6.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 6);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p6.eth_f_top_p6.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 6);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 6);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 6);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p6.eth_f_top_p6.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p6_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 6);
      end
      join_none
      wait fork;
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hd8; //HSSI_PORT6_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 6,rdata[4],rdata[0]);

      `endif
      `ifdef INCLUDE_HSSI_PORT_7
      // Port-7
      fork begin
       // $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,7);
       // wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_hssi_ss_ip_wrapper.o_p7_ehip_ready == 1);
       // $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,7);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p7.eth_f_top_p7.sip_inst.o_rx_block_lock  === 1'b1);
        $display ("INFO:%t	Port %0d - EHIP RX Block Lock  is high", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for RX PCS Ready", $time, 7);
        while (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p7.eth_f_top_p7.sip_inst.o_rx_pcs_ready !== 1'b1) @(negedge tb_top.DUT.hssi_wrapper.hssi_ss.app_ss_lite_clk);
        $display ("INFO:%t	Port %0d - RX deskew locked", $time, 7);
        $display ("INFO:%t	Port %0d - RX lane aligmnent locked", $time, 7);
        $display ("INFO:%t	Port %0d - Waiting for TX Lanes Stable", $time, 7);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss.U_eth_f_inst_p7.eth_f_top_p7.sip_inst.o_tx_lanes_stable === 1'b1);
        @(posedge tb_top.DUT.hssi_wrapper.hssi_ss.o_p7_clk_pll);
        $display ("INFO:%t	Port %0d - TX enabled", $time, 7);
      end
      join_none
      wait fork;

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'hdc; //HSSI_PORT7_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 7,rdata[4],rdata[0]);
      `endif
      #5us;
      // Check rx pcs ready, tx lane stable and pll lock by reading register
      
   end
endtask
`endif
task ENABLE_LPBK;
   input int Lane;
   logic [63:0] wdata;
   logic [63:0] addr;
   logic [63:0] LOOP_BACK;
   logic [63:0] RDDATA;
   logic [63:0] TM_NUM_PKT_SET;
   logic [63:0] cur_pf_table;
        for(int i=0;i<8;i++) begin
           wdata =   32'h1*i;
	   addr =tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	   mmio_write32(.addr_(addr), .data_(wdata));
        $display("INFO:%t TRAFFIC_CTRL_CH_SEL_LANE_%d_DONE",$time,i);
      #5us;
       write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A00, 32'h1); //LOOPBACK_EN
   	`uvm_info(get_name(), "LOOP ENABLED...", UVM_LOW)
       read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,32'h3A00, LOOP_BACK);
       read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,32'h3A01, RDDATA);
       read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_STOP_XFR_ADDR,RDDATA); 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_XFRD_ADDR,RDDATA);  

        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_NUM_PKT_ADDR,TM_NUM_PKT_SET);  //Moinitor set for Max num pkt
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_BYTE_COUNT0_ADDR,RDDATA);  //Moinitor 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_BYTE_COUNT1_ADDR,RDDATA);  //Moinitor 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_LOOPBACK_EN_ADDR,RDDATA);  //Moinitor 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_LOOPBACK_FIFO_ADDR,RDDATA);  //Moinitor 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_TYPE_ADDR,RDDATA);
         //Set packet length
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_ADDR, RDDATA);
         //Set data pattern type
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_DATA_PATTERN_ADDR, RDDATA);
         //Set number of packets
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_NUM_PKT_ADDR, RDDATA);
         //SRC_MAC_L
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_L_ADDR, RDDATA);
        //SRC_MAC_H
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_H_ADDR, RDDATA);
        //DST_MAC_L
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_L_ADDR, RDDATA);
        //DST_MAC_H
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_H_ADDR, RDDATA);
        //RANDOM_SEED0
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR, RDDATA);
        //RANDOM_SEED1
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR, RDDATA);
        //RANDOM_SEED2
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR, RDDATA);
         // TM_NUM_PKT
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TM_NUM_PKT_ADDR, RDDATA);
         //Set start to send packets
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, RDDATA); 

        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_PKT_GOOD_ADDR,RDDATA);
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_PKT_BAD_ADDR,RDDATA);
        //read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_FIFO_ADDR,RDDATA);

       end
   	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)

endtask

task ENABLE_LPBK_4ports;
   logic [63:0] wdata;
   logic [63:0] addr;
        
       for(int i=0;i<4;i++)begin
           wdata =   32'h1*i;
	   addr =tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	   mmio_write32(.addr_(addr), .data_(wdata));
        $display("INFO:%t TRAFFIC_CTRL_CH_SEL_LANE_%d_DONE",$time,i);
      #50us;
       write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A00, 32'h1); //LOOPBACK_EN
   	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
       end

endtask






endclass : he_hssi_rx_lpbk_seq

`endif // HE_HSSI_TX_LPBK_SEQ_SVH
