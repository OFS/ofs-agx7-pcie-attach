//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class he_hssi_tx_lpbk_seq is executed by he_hssi_tx_lpbk_P*_test 
 * This sequence generate the PKTs from HE-HSSI block and external loopback is done at QSFP level
 * The Number of good and bad packets are captured in HE_HSSI registers
 * 
 * Sequence is running on virtual_sequencer 
 *
**/
//===============================================================================================================


`ifndef HE_HSSI_TX_LPBK_SEQ_SVH
`define HE_HSSI_TX_LPBK_SEQ_SVH

class he_hssi_tx_lpbk_seq extends base_seq;
    `uvm_object_utils(he_hssi_tx_lpbk_seq)

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
    parameter STATISTICS_framesOK_OFFSET                        = 32'h008;
    parameter STATISTICS_framesErr_OFFSET                       = 32'h010;
    parameter STATISTICS_framesCRCErr_OFFSET                    = 32'h018;
    parameter STATISTICS_octetsOK_OFFSET                        = 32'h020;
    parameter STATISTICS_pauseMACCtrlFrames_OFFSET              = 32'h028;
    parameter STATISTICS_ifErrors_OFFSET                        = 32'h030;
    parameter STATISTICS_unicastFramesOK_OFFSET                 = 32'h038;
    parameter STATISTICS_unicastFramesErr_OFFSET                = 32'h040;
    parameter STATISTICS_multicastFramesOK_OFFSET               = 32'h048;
    parameter STATISTICS_multicastFramesErr_OFFSET              = 32'h050;
    parameter STATISTICS_broadcastFramesOK_OFFSET               = 32'h058;
    parameter STATISTICS_broadcastFramesErr_OFFSET              = 32'h060;
    parameter STATISTICS_etherStatsOctets_OFFSET                = 32'h068;
    parameter STATISTICS_etherStatsPkts_OFFSET                  = 32'h070;
    parameter STATISTICS_etherStatsUndersizePkts_OFFSET         = 32'h078;
    parameter STATISTICS_etherStatsOversizePkts_OFFSET          = 32'h080;
    parameter STATISTICS_etherStatsPkts64Octets_OFFSET          = 32'h088;
    parameter STATISTICS_etherStatsPkts65to127Octets_OFFSET     = 32'h090;
    parameter STATISTICS_etherStatsPkts128to255Octets_OFFSET    = 32'h098;
    parameter STATISTICS_etherStatsPkts256to511Octets_OFFSET    = 32'h0A0;
    parameter STATISTICS_etherStatsPkts512to1023Octets_OFFSET   = 32'h0A8;
    parameter STATISTICS_etherStatPkts1024to1518Octets_OFFSET   = 32'h0B0;
    parameter STATISTICS_etherStatsPkts1519toXOctets_OFFSET     = 32'h0B8;
    parameter STATISTICS_etherStatsFragments_OFFSET             = 32'h0C0;
    parameter STATISTICS_etherStatsJabbers_OFFSET               = 32'h0C8;
    parameter STATISTICS_etherStatsCRCErr_OFFSET                = 32'h0D0;
    parameter STATISTICS_unicastMACCtrlFrames_OFFSET            = 32'h0D8;
    parameter STATISTICS_multicastMACCtrlFrames_OFFSET          = 32'h0E0;
    parameter STATISTICS_broadcastMACCtrlFrames_OFFSET          = 32'h0E8;

    rand bit RD_MAC_STATS_EN;
    rand bit TG_PKT_LEN_TYPE_VAL;
    rand bit TG_DATA_PATTERN_VAL;
    constraint RD_MAC_STATS_EN_c {
        soft RD_MAC_STATS_EN == 0;
    }

    function new (string name = "he_hssi_tx_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
        logic [63:0] cur_pf_table;
        logic [63:0] framesOK_1,framesOK_2;
	logic        tx_rx_mismatch = 0;
	logic        error_bit = 0;
    int len;
        super.body();
	`uvm_info(get_name(), "Entering sequence...", UVM_LOW)
	uvm_config_db #(int unsigned)::get(null, " ", "LANE_NUM", len);
        `uvm_info("body", $sformatf("TX_LPBK_SEQ: LANE_NUM %d ",len), UVM_LOW);
         wait_for_reset_done();
         wait_for_hssi_to_ready(len);
         traffic_10G_25G(len);

	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask : body

    task write_mailbox();
        input [63:0] cmd_ctrl_addr;
	input [63:0] addr;
	input [63:0] write_data32;
	begin
             mmio_write32(cmd_ctrl_addr + MB_WRDATA_OFFSET , write_data32);
             mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr      );
             mmio_write32(cmd_ctrl_addr                    , MB_WR       );
	     read_ack_mailbox(cmd_ctrl_addr);
             mmio_write32(cmd_ctrl_addr                    , MB_NOOP     );
	end
    endtask : write_mailbox

    task read_ack_mailbox;
        input bit [63:0] cmd_ctrl_addr;
        begin
	    bit [63:0] rdata = 64'h0;
	    int        rd_attempts = 0;
	    bit        ack_done_reg = 0;
      uvm_status_e       status;
	    while(~ack_done_reg && rd_attempts < 7) begin
        //Adding RAL read for covering RAL coverage
          //      mmio_read64(cmd_ctrl_addr, rdata);
        tb_env0.he_hssi_regs.TRAFFIC_CTRL_CMD.read(status,rdata);
       `ifdef COV tb_env0.he_hssi_regs.TRAFFIC_CTRL_CMD.cg_vals.sample();`endif
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
   uvm_status_e       status;
   begin
      mmio_write32(cmd_ctrl_addr + MB_ADDRESS_OFFSET, addr); // DW address
      mmio_write32(cmd_ctrl_addr, MB_RD); // read Cmd
      read_ack_mailbox(cmd_ctrl_addr);
      mmio_read64(cmd_ctrl_addr + MB_RDDATA_OFFSET, rd_data64);
      tb_env0.he_hssi_regs.TRAFFIC_CTRL_DATA.read(status,rd_data64);
     `ifdef COV tb_env0.he_hssi_regs.TRAFFIC_CTRL_DATA.cg_vals.sample();`endif
     $display("INFO: Read MAILBOX ADDR:%x, READ_DATA64:%X", addr, rd_data64);
      mmio_write32(cmd_ctrl_addr, MB_NOOP); // no op Cmd
   end
endtask
    



task wait_for_reset_done;
   bit [63:0]   wdata, rdata, mask, addr;     
   bit[63:0] expdata;

   begin
     
      $display("INFO:%t	Waiting for subsystem cold reset deassertion acknowledgment",$time);
      wait(tb_top.DUT.hssi_wrapper.hssi_ss.subsystem_cold_rst_ack_n);
      $display("INFO:%t	Subsystem cold reset deassertion acknowledged",$time);
      `uvm_info(get_name(), "Just read  HSSI_COLD_RST Read write  CSR Registers...", UVM_LOW)
			          
         addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h810;
	 expdata =  64'h0000000000000000;
         mmio_read32 (.addr_(addr), .data_(rdata));
 
       	 if(rdata[31:0]== expdata[31:0])
            `uvm_info(get_name(), $psprintf("HSSI_COLD_RST  Data match!addr = %0h, Exp = %0h, Act = %0h",addr, expdata, rdata),UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf(" HSSI_COLD_RST Data mismatch!addr = %0h, EXp = %0h, data = %0h",addr,expdata, rdata))
      $display("INFO:%t	Reset Sequence Complete",$time);
   end
endtask

task wait_for_hssi_to_ready;
   input int            len;
   logic [2:0]          bar;
   logic                error;
   logic                result;
   logic [31:0]         scratch;
   logic [63:0] addr;
   logic [63:0] rdata;
   begin
      bar         = 3'h0;
      // Ports           
      if(len==0)begin
    `ifdef INCLUDE_HSSI_PORT_0      // ports        
     //Port-0
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,0);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p0_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,0);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,0);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p0_rx_block_lock  === 1'b1);
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

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h000c0; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 0,rdata[4],rdata[0]);
       `endif
    end
      // Port-1
     else if(len==1)begin
    `ifdef INCLUDE_HSSI_PORT_1      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,1);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p1_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,1);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,1);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p1_rx_block_lock  === 1'b1);
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
    end
      // Port-2
     else if(len==2)begin
    `ifdef INCLUDE_HSSI_PORT_2      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,2);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p2_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,2);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,2);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p2_rx_block_lock  === 1'b1);
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
   end
      // Port-3
     else if(len==3)begin
    `ifdef INCLUDE_HSSI_PORT_3      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,3);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p3_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,3);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,3);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p3_rx_block_lock  === 1'b1);
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
    end
     // Port-4
     else if(len==4)begin
    `ifdef INCLUDE_HSSI_PORT_4      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,4);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p4_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,4);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,4);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p4_rx_block_lock  === 1'b1);
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

    end
     // Port-5
     else if(len==5)begin
    `ifdef INCLUDE_HSSI_PORT_5      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,5);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p5_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,5);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,5);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p5_rx_block_lock  === 1'b1);
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

    end
      // Port-6
    else if(len==6)begin
    `ifdef INCLUDE_HSSI_PORT_6      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,6);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p6_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,6);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,6);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p6_rx_block_lock  === 1'b1);
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
    end
      // Port-7
    else if(len==7)begin
    `ifdef INCLUDE_HSSI_PORT_7      // ports        
      fork begin
        $display ("INFO:%t	Port %0d - Waiting for EHIP READY", $time,7);
        wait(tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p7_ehip_ready == 1);
        $display ("INFO:%t	Port %0d - EHIP READY is 1", $time,7);
        $display ("INFO:%t	Port %0d - Waiting for EHIP RX Block Lock", $time,7);
        wait (tb_top.DUT.hssi_wrapper.hssi_ss.hssi_ss_0.U_hssi_ss_ip_wrapper.o_p7_rx_block_lock  === 1'b1);
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

    end
      #5us;
        $display("INFO:%t	HSSI_READY Sequence Complete",$time);
      
   end
endtask


task traffic_10G_25G;
   input int len;
   logic [63:0] wdata;
   logic [63:0] addr;
   logic [31:0] scratch1;
   logic [31:0] GOOD_PKT_RCVD;
   logic [31:0] BAD_PKT_RCVD;
   logic [31:0] TM_NUM_PKT_SET;
   logic [31:0] RDDATA;
   logic [63:0] cur_pf_table;
   uvm_status_e       status;

   begin
      //---------------------------------------------------------------------------
      // Traffic Controller Configuration
      //---------------------------------------------------------------------------
      fork 
        begin
        wdata =   32'h1*len;
	    addr =tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	 //   mmio_write32(.addr_(addr), .data_(wdata));
   //  Adding RAL Write Access here for RAL coverage
        tb_env0.he_hssi_regs.TRAFFIC_CTRL_CH_SEL.write(status,wdata);
       `ifdef COV tb_env0.he_hssi_regs.TRAFFIC_CTRL_CH_SEL.cg_vals.sample();`endif

        $display("INFO:%t	TRAFFIC_CTRL_CH_SEL_DONE",$time);

         // Port-0                                                                                                          
            //Set packet length type
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_TYPE_ADDR, TG_PKT_LEN_TYPE_VAL);
            //Set packet length
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_PKT_LEN_ADDR, TG_PKT_LEN_VAL);
            //Set data pattern type
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_DATA_PATTERN_ADDR, TG_DATA_PATTERN_VAL);
            //Set number of packets
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_NUM_PKT_ADDR, TG_NUM_PKT_VAL);
            //SRC_MAC_L
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_L_ADDR, $urandom);
           //SRC_MAC_H
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_SRC_MAC_H_ADDR, $urandom);
           //DST_MAC_L
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_L_ADDR, $urandom);
           //DST_MAC_H
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_DST_MAC_H_ADDR, $urandom);
           //RANDOM_SEED0
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED0_ADDR, $urandom);
           //RANDOM_SEED1
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED1_ADDR, $urandom);
           //RANDOM_SEED2
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TG_RANDOM_SEED2_ADDR, $urandom);
           //accessing FIFO 
           //write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TM_FIFO_ADDR, $urandom);
            // TM_NUM_PKT
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TM_NUM_PKT_ADDR, 'hFFFFFFFF);
            //Set start to send packets
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, 32'h1); 
      end
        $display("INFO:%t	TRAFFIC IS SENT ON PORT_%d",$time,len);                                                                  

        begin
          `ifndef DISABLE_AFU_MAIN
            wait_for_all_eop_done(TG_NUM_PKT_VAL,len);
            $display("INFO:%t	WAIT FOR EOP DONE",$time);
          `endif
        end
      join
      //---------------------------------------------------------------------------
      // Read Monitor statistics
      //---------------------------------------------------------------------------

      // Port-0
       wdata =   32'h1*len;//SEL_PORT_0
	   addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	   mmio_write32(.addr_(addr), .data_(wdata));
            
        write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_STOP_XFR_ADDR, 32'h1); 
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
        //read FIFO 
       // read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR,TM_FIFO_ADDR, RDDATA);
         //Set start to send packets
         read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TG_START_XFR_ADDR, RDDATA); 



 
        read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_PKT_GOOD_ADDR,GOOD_PKT_RCVD);
        $display("INFO:%t	MONITOR THE TRAFFIC",$time);

      if (GOOD_PKT_RCVD != TG_NUM_PKT_VAL) begin
         $display("\nError: Received good packets does not match Transmitted packets on Port-%0d !\n",len);
         $display("Number of Good Packets Received: \tExpected: %0d\n \tRead: %0d",TG_NUM_PKT_VAL,GOOD_PKT_RCVD);
      end else begin
         $display("INFO: Number of Good Packets Received on Port-%0d :%0d",len,GOOD_PKT_RCVD);
      end
      // Bad packet received at Traffic monitor
      read_mailbox(cur_pf_table, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, TM_PKT_BAD_ADDR,BAD_PKT_RCVD);
      if (BAD_PKT_RCVD != 32'h0) begin
         $display("\nError: Received bad packets on Port-%0d !\n",len);
         $display("Number of Bad Packets Received: \tExpected: %0d\n \tRead: %0d",32'h0,BAD_PKT_RCVD);
      end else begin
         $display("INFO: Number of Bad Packets Received on Port-%0d :%0d",len,BAD_PKT_RCVD);
      end

   end
endtask

// Wait until all packets received back
task wait_for_all_eop_done;
   input logic [31:0]  num_pkt;
   input int len;
   logic [31:0]        pkt_cnt;
   begin
      pkt_cnt = 32'h0;
      if(len==0) begin
      `ifdef INCLUDE_HSSI_PORT_0  //ports
         $display("LEN_0 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(0).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(0).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==1) begin
         `ifdef INCLUDE_HSSI_PORT_1   //ports
         $display("LEN_1 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(1).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(1).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==2) begin
       `ifdef INCLUDE_HSSI_PORT_2   //ports 
         $display("LEN_2 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(2).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(2).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==3) begin
       `ifdef INCLUDE_HSSI_PORT_3    //ports
         $display("LEN_3 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(3).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(3).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end 
   `ifndef FIM_A_3 
        if(len==4) begin
       `ifdef INCLUDE_HSSI_PORT_4  //ports
         $display("LEN_4 is selected", $time);
          while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(4).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(4).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==5) begin
       `ifdef INCLUDE_HSSI_PORT_5  //ports
         $display("LEN_5 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(5).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(5).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==6) begin
        `ifdef INCLUDE_HSSI_PORT_6  //ports
         $display("LEN_6 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(6).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(6).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end else if(len==7) begin
        `ifdef INCLUDE_HSSI_PORT_7  //ports
         $display("LEN_7 is selected", $time);
      while (pkt_cnt < num_pkt) begin
	      @(posedge `HE_HSSI_RX_ST_Q(7).rx.eop);
	      @(posedge `HE_HSSI_RX_ST_Q(7).clk);
         pkt_cnt=pkt_cnt+1;
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      $display("INFO:%t	- pkt_num count is %d", $time, num_pkt);
      end
      $display("INFO:%t	- RX EOP count is %d", $time, pkt_cnt);
      `endif
   end
   `endif
  end
endtask



endclass : he_hssi_tx_lpbk_seq

`endif // HE_HSSI_TX_LPBK_SEQ_SVH
