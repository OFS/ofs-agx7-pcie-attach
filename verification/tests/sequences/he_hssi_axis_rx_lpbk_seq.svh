//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class axi_master_random_sequence is AXI_VIP sequence,Used to generate AXI-S traffic 
 * class he_hssi_axis_rx_lpbk_seq uses axi_vip sequence to generate the traffic from TX-port of HSSI (when HSSI is disabled)
 * The LPBK is enabled in HE_HSSI and LPBK data is checked on waveform  
 * The sequence is also exercising the sc_fifo of he_hssi (for coverage)
 *
 * Sequence is running on virtual_sequencer 

 */
//===============================================================================================================


`ifndef HE_HSSI_AXIS_RX_LPBK_SEQ_SVH
`define HE_HSSI_AXIS_RX_LPBK_SEQ_SVH

class he_hssi_axis_rx_lpbk_seq extends base_seq;
    `uvm_object_utils(he_hssi_axis_rx_lpbk_seq)

    parameter TRAFFIC_CTRL_CMD_ADDR = 32'h30;
    parameter TRAFFIC_CTRL_CH_SEL = 32'h40;
    parameter TG_PKT_LEN_TYPE_ADDR =32'h3801;
    parameter TG_PKT_LEN_TYPE_VAL=1'b0;
    parameter TG_PKT_LEN_ADDR=32'h380D;
    parameter TG_PKT_LEN_VAL=32'h42;
    parameter TG_DATA_PATTERN_ADDR=32'h3802;
    parameter LOOPBACK_EN_ADDR = 32'h3A00;
    parameter TG_DATA_PATTERN_VAL=32'h0;
    parameter TG_NUM_PKT_ADDR=32'h3800;
    parameter TG_NUM_PKT_VAL=32'h20;
    parameter TG_START_XFR_ADDR=32'h3803;
    parameter TM_PKT_BAD_ADDR=32'h3902;
    parameter TM_PKT_GOOD_ADDR=32'h3901;
    parameter TM_NUM_PKT_ADDR=32'h3900;
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
   bit CVL_25G;
   bit CVL_100G;
  logic [63:0] RDDATA;
`ifdef INCLUDE_CVL
   axi_master_random_sequence axi_m_seq;
`endif
    function new (string name = "he_hssi_axis_rx_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
        
        super.body(); 
	`uvm_info(get_name(), "Entering sequence...", UVM_LOW)
        //uvm_config_db #(int )::get(null, "uvm_test_top.tb_env0", "Lane", Lane);
        `ifndef INCLUDE_CVL
         ENABLE_LPBK();
        `endif
	//`uvm_do_on(axi_m_seq,tb_env0.axis_HSSI_env.master[0].sequencer )

         axis_random_data(); //task generates random data on axi-s interface
         for(int i=0;i<8;i++) begin
         SC_FIFO_RDW(i);
         `uvm_info(get_name(), $psprintf("FIFO RD/WR DOne ...%0d",i), UVM_LOW)
         end
                 `uvm_info(get_name(), "Exiting sequence...", UVM_LOW)
    endtask : body


  task SC_FIFO_RDW();
     // Enable Loopback
   input [15:0]len;
   logic [63:0] RDDATA;
   logic [63:0] wdata ,addr ;
           
            wdata=32'h1*len;        
            addr =tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	    mmio_write32(.addr_(addr), .data_(wdata));
            //write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A00, 32'h1); //LOOPBACK_EN
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A80, 32'hFFFF_FFFF); //Access tx_scfifo to increase toggle coverage 
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A82, 32'hFFFF_FFFF); //Access tx_scfifio almost_full_thershold
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A83, 32'hFFFF_FFFF); //Access tx_scfifio almost_full_thershold
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A84, 32'hFFFF_FFFF); //Access tx_scfifo cut thorugh_threshold
            write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A85, 32'hFFFF_FFFF); //Access tx_scfifo cut thorugh_threshold
            #10us; 
           read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A82,RDDATA);  //Moinitor 
           read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A80,RDDATA);  //Moinitor
           read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A84,RDDATA);  //Moinitor
           read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A83,RDDATA);  //Moinitor
           read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A85,RDDATA);  //Moinitor
           //read_mailbox(0, 0, tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A80,RDDATA);  //Moinitor

  endtask

  task ENABLE_LPBK;
   //input int Lane;
   logic [63:0] wdata;
   logic [63:0] addr;
        for(int i=0;i<8;i++) begin
           wdata =   32'h1*0;
	   addr =tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CH_SEL;
 	   mmio_write32(.addr_(addr), .data_(wdata));
        $display("INFO:%t TRAFFIC_CTRL_CH_SEL_LANE_%d_DONE",$time,0);
      #5us;
       write_mailbox(tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+TRAFFIC_CTRL_CMD_ADDR, 32'h3A00, 32'h1); //LOOPBACK_EN
   	`uvm_info(get_name(), "LOOP ENABLED...", UVM_LOW)
       end
   	`uvm_info(get_name(), "Exiting sequence...", UVM_LOW)

endtask

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
	    while(~ack_done_reg && rd_attempts < 7) begin
                //mmio_read64(cmd_ctrl_addr, rdata);
                mmio_read32(cmd_ctrl_addr, rdata);
		ack_done_reg = rdata[2];
		rd_attempts++;
	    end

	    if(~ack_done_reg)
	        `uvm_error(get_name(), "Did not ACK for last transaction!")

	end
    endtask : read_ack_mailbox
task read_mailbox;
   input  logic [63:0] cur_pf_table;
   input  logic [63:0] bar;
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

`ifdef INCLUDE_CVL
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

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR +'h68; //HSSI_PORT0_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h6c; //HSSI_PORT1_STATUS
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
       addr = tb_cfg0.PF0_BAR0+ HSSI_BASE_ADDR +'h70; //HSSI_PORT2_STATUS
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
       addr = tb_cfg0.PF0_BAR0+ HSSI_BASE_ADDR+'h74; //HSSI_PORT3_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h78; //HSSI_PORT4_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h7c; //HSSI_PORT5_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h80; //HSSI_PORT6_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h84; //HSSI_PORT7_STATUS
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

`ifdef INCLUDE_CVL
task wait_for_hssi_4ports_to_ready;
   logic [63:0] addr;
   logic [63:0] rdata;
   begin
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

       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h68; //HSSI_PORT0_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR +'h6c; //HSSI_PORT1_STATUS
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR +'h70; //HSSI_PORT2_STATUS
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
       addr = tb_cfg0.PF0_BAR0 + HSSI_BASE_ADDR +'h74; //HSSI_PORT3_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 3,rdata[4],rdata[0]);
      `endif
   end
endtask

task wait_for_hssi_0and4_port_to_ready;
   logic [63:0] addr;
   logic [63:0] rdata;
   begin
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR +'h68; //HSSI_PORT0_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 0,rdata[4],rdata[0]);
      `endif
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
       addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h78; //HSSI_PORT4_STATUS
       mmio_read32 (.addr_(addr), .data_(rdata));
      $display("INFO:%t	Port %0d - EHIP RX Block Status bit is %d and EHIP Ready Bit is %d", $time, 4,rdata[4],rdata[0]);
      `endif
      end
    endtask
`endif



endclass : he_hssi_axis_rx_lpbk_seq

`endif // HE_HSSI_AXIS_RX_LPBK_SEQ_SVH
