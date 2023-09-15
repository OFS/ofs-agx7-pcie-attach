// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Engineer     : bharath
// Create Date  : Sept 2020
// Module Name  : qsfp_top.sv
// Project      : IOFS
// -----------------------------------------------------------------------------
//
// Description: 
// Poller FSM logic reads the registers from QSFP module

module poller_fsm (
  input   logic        clk,      
  input   logic        reset,  // reset.reset
  input   logic        poll_en,
  output  logic [15:0] sink_data,     //
  output  logic        sink_valid,    //
  input   logic        sink_ready,    //

  output  logic        wren_logic,    //
  output  logic [7:0]  curr_rd_addr,    //
  output  logic [7:0]  curr_rd_page,  //
  input   logic        rd_done,    //
  output  logic        rd_done_ack,    //
  output  logic        wr_cnt_rst,    //
  input   logic [9:0]  csr_wdata,
  input   logic        csr_write,
  input   logic [11:0] csr_addr,
  input   logic [31:0] delay_csr_in,
  output  logic        fsm_paused    //
);

  localparam  IDLE       = 4'b0000;
  localparam  WRCW       = 4'b0001;
  localparam  WRADDR     = 4'b0010;
  localparam  WDATA      = 4'b0011;
  localparam  WRCW1      = 4'b0100;
  localparam  WADDR1     = 4'b0101;
  localparam  RDCW       = 4'b0110;
  localparam  RDCLK      = 4'b0111;
  localparam  RDDATA     = 4'b1000;
  localparam  ADDR_CHECK = 4'b1001;
  localparam  WAIT       = 4'b1010;
  localparam  WRDATA_AVMM = 4'b1011;
  
  
  logic  [3:0]  state_nxt     ;
  logic  [15:0] sink_data_nxt ;
  logic         sink_valid_nxt;
  logic  [7:0]  curr_addr_nxt ;
  logic         wren_logic_nxt;
  logic  [7:0]  curr_page_nxt ;
  logic         fsm_paused_nxt;
  logic  [3:0]  state     ;
  logic  [7:0]  curr_addr ;
  logic  [7:0]  curr_page ;
  logic         rd_done_ack_nxt;
  logic         poll_en_d1;
  logic         wr_cnt_rst_nxt;
  logic  [31:0] delay_st_sp_nxt;
  logic  [31:0] delay_st_sp;

  localparam  TFR_WRITE_CTRL = 10'b1010100000; // value to be written in TFR register to initiate write with i2c slave
  localparam  TFR_ADDR_127   = 10'b0001111111; // value to be written in TFR register to address byte 127 for selecting upper page
  localparam  TFR_RD_CTRL    = 10'b1010100001; // TFR register value to initiate read with i2c slave
  localparam  TFR_RD_CLK     = 10'b0000000000;
  localparam  TFR_RD_ACK     = 10'b0000000000; // TFR register value to send ack for i2c reads
  localparam  TFR_RD_NACK    = 10'b0100000000; // TFR register value to send nack for i3c reads
 
  assign curr_rd_addr = curr_addr;
  assign curr_rd_page = curr_page;

always_comb
  begin
     state_nxt       =  state     ;
     sink_data_nxt   =  sink_data  ;
     sink_valid_nxt  =  sink_valid  ;
     curr_addr_nxt   =  curr_addr  ;
     wren_logic_nxt  =  wren_logic  ;
     curr_page_nxt   =  curr_page  ;
     fsm_paused_nxt  =  fsm_paused  ;
     rd_done_ack_nxt =  rd_done_ack  ;
     wr_cnt_rst_nxt  =  wr_cnt_rst;
	 delay_st_sp_nxt =  delay_st_sp;

  case(state)
    IDLE: 
    begin
	  delay_st_sp_nxt = 32'd0;
      if(poll_en)
	   begin
        state_nxt = WRCW;
	   end
	  else if (~poll_en)
	   begin
	    state_nxt = WRDATA_AVMM;
	   end
	end
    
	WRDATA_AVMM:
    begin
      fsm_paused_nxt  = 1'b1;
      wr_cnt_rst_nxt  = 1'b0;
	  delay_st_sp_nxt = 32'd0;
      if(sink_ready & ~sink_valid & ~poll_en)
      begin
        sink_data_nxt = csr_wdata[9:0];
        sink_valid_nxt = csr_write && (csr_addr == 12'h040);
        state_nxt = WRDATA_AVMM;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt = 0;
        sink_valid_nxt = 0;
        state_nxt = IDLE;
      end
      else if (poll_en)
      begin
        state_nxt = WRCW;
      end
    end
	
	
    WRCW:
    begin
	  if(delay_st_sp == 0)
	  begin
		fsm_paused_nxt  = 1'b0;
		wr_cnt_rst_nxt  = 1'b0;
		if(sink_ready & ~sink_valid)
		begin
			sink_data_nxt = TFR_WRITE_CTRL;
			sink_valid_nxt = 1;
			state_nxt = WRCW;
		end
		else if (sink_ready & sink_valid)
		begin
			sink_data_nxt = 0;
			sink_valid_nxt = 0;
			state_nxt = WRADDR;
		end
	  end
	  else
	  begin
		delay_st_sp_nxt = delay_st_sp - 1;
	  end
	end

    WRADDR:
    begin
      if(sink_ready & ~sink_valid)
      begin
        sink_data_nxt = TFR_ADDR_127;
        sink_valid_nxt = 1;
        state_nxt = WRADDR;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt = 0;
        sink_valid_nxt = 0;
        state_nxt = WDATA;
      end
    end

    WDATA:
    begin
      if(sink_ready & ~sink_valid)
      begin
        sink_data_nxt  = {2'b01,curr_page};
        sink_valid_nxt = 1;
        state_nxt      = WDATA;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt = 0;
        sink_valid_nxt = 0;
		delay_st_sp_nxt = delay_csr_in;
        state_nxt = WRCW1;
      end
    end

    WRCW1:
    begin
	  if(delay_st_sp == 0)
	  begin
		wr_cnt_rst_nxt = 1'b0;
		if(sink_ready & ~sink_valid)
		begin
			sink_data_nxt = TFR_WRITE_CTRL;
			sink_valid_nxt = 1;
			state_nxt = WRCW1;
		end
		else if (sink_ready & sink_valid)
		begin
			sink_data_nxt = 0;
			sink_valid_nxt = 0;
			state_nxt = WADDR1;
			delay_st_sp_nxt = 0;
			
        // set byte address for QSFP module
			if(curr_page == 0)
				curr_addr_nxt = 0;
			else
				curr_addr_nxt = 128;
		end
	  end
	  else
	  begin
		delay_st_sp_nxt = delay_st_sp - 1;
	  end
	end
    
	WADDR1:
    begin
      if(sink_ready & ~sink_valid)
      begin
        sink_data_nxt = {2'b0 , curr_addr};
        sink_valid_nxt = 1;
        state_nxt = WADDR1;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt  = 0;
        sink_valid_nxt = 0;
        state_nxt      = RDCW;
      end
    end

    RDCW:
    begin
      if(sink_ready & ~sink_valid)
      begin
        sink_data_nxt  = TFR_RD_CTRL;
        sink_valid_nxt = 1;
        state_nxt      = RDCW;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt  = 0;
        sink_valid_nxt = 0;
        state_nxt      = RDCLK;
        wren_logic_nxt = 1;
      end
    end
	
	RDCLK:
    begin
      if(sink_ready & ~sink_valid)
      begin
        sink_data_nxt  = TFR_RD_CLK;
        sink_valid_nxt = 1;
        state_nxt      = RDCLK;
      end
      else if (sink_ready & sink_valid)
      begin
        sink_data_nxt  = 0;
        sink_valid_nxt = 0;
        state_nxt      = RDDATA;
        wren_logic_nxt = 1;
      end
    end
	
    RDDATA:
    begin
      if(rd_done) // handshake from wren_logic fsm
      begin
        rd_done_ack_nxt = 1;
        if(poll_en && (curr_addr < 255))
        begin
          if(sink_ready & ~sink_valid)
          begin
			if (curr_addr == 254)
			begin
			sink_data_nxt    = TFR_RD_NACK;
            sink_valid_nxt   = 1;
			end
			else
			begin
			sink_data_nxt    = TFR_RD_ACK;
			sink_valid_nxt   = 1;
			end
            state_nxt        = ADDR_CHECK;
          end
        end

        else // if poller not enabled or change of page 
        begin
          if(sink_ready & ~sink_valid & ~poll_en)
          begin
            sink_data_nxt   = TFR_RD_NACK;
            sink_valid_nxt  = 1;
            state_nxt       = WAIT;
            wren_logic_nxt  = 0;
            fsm_paused_nxt  = 1;
          end
		  else if(sink_ready & ~sink_valid & poll_en)
		  begin
		    //sink_data_nxt   = TFR_RD_NACK;
          //sink_valid_nxt  = 1;
            state_nxt       = ADDR_CHECK;
            wren_logic_nxt  = 0;
            fsm_paused_nxt  = 1;
		  end
	    end
      end
    end

    ADDR_CHECK: 
    begin
      rd_done_ack_nxt = 0;
      sink_valid_nxt = 0;
      if(curr_addr < 255) 
      begin
        curr_addr_nxt = curr_addr +1;
        state_nxt = RDDATA;
      end  
      else
      begin
        case(curr_page)
          8'h00: curr_page_nxt  = 8'h02;
          8'h02: curr_page_nxt  = 8'h03;
          8'h03: curr_page_nxt  = 8'h20;
          8'h20: curr_page_nxt  = 8'h21;
          8'h21: curr_page_nxt  = 8'h00;
        endcase
        if(curr_page == 8'h21)
          curr_addr_nxt = 0;
        else
          curr_addr_nxt = 128;
        
		delay_st_sp_nxt = delay_csr_in;
        state_nxt = WRCW;		
      end
    end

    WAIT:
    begin
      sink_valid_nxt = 0;
      rd_done_ack_nxt = 0;

      if(poll_en == 1'b1 && poll_en_d1 == 1'b0)
      begin
	    delay_st_sp_nxt = delay_csr_in;
        state_nxt     = WRCW;  
        curr_page_nxt = 8'h00;
        curr_addr_nxt = 0;
        wr_cnt_rst_nxt = 1'b1;
      end
      else if(poll_en) 
      begin
        curr_addr_nxt = curr_addr +1;
		delay_st_sp_nxt = delay_csr_in;
        state_nxt = WRCW1;  
      end
    end

    default: state_nxt = IDLE;
  endcase
  end


  always@(posedge clk or posedge reset)
  begin
    if(reset)
    begin
      state       <= 'd0;
      sink_data   <= 'd0;
      sink_valid  <= 'd0;
      curr_addr   <= 'd0;
      wren_logic  <= 'd0;
      curr_page   <= 'd0;
      fsm_paused  <= 'd0;
      rd_done_ack <= 'd0;
      poll_en_d1  <= 1'b0;
      wr_cnt_rst  <= 1'b0;
	  delay_st_sp <= 32'd0;
    end

    else
    begin
      state       <=  state_nxt   ;
      sink_data   <=  sink_data_nxt  ;
      sink_valid  <=  sink_valid_nxt  ;
      curr_addr   <=  curr_addr_nxt  ;
      wren_logic  <=  wren_logic_nxt  ;
      curr_page   <=  curr_page_nxt  ;
      fsm_paused  <=  fsm_paused_nxt  ;
      rd_done_ack <=  rd_done_ack_nxt;
      poll_en_d1  <=  poll_en;
      wr_cnt_rst  <=  wr_cnt_rst_nxt;
	  delay_st_sp <=  delay_st_sp_nxt;
    end
  end

  endmodule
