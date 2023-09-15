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
// this logic assembles and wtites i2C read data into CSR register memory in 64 bits chunk 

module csr_wr_logic (
 input  logic        clk,
 input  logic        reset,
 input  logic        src_valid,
 input  logic [7:0]  src_data,
 output logic        src_ready,
                     
 input  logic        wren_logic,
 input  logic [7:0]  curr_rd_addr,
 output logic        rd_done,
 input  logic        rd_done_ack,
 input   logic       poll_en,
                     
 output logic        mem_wren ,
 output logic [63:0] mem_wdata,
 output logic        mem_chipsel,
 output logic [7:0]  mem_waddr,  //
 input  logic        wr_cnt_rst

);

 logic [1:0]  state_nxt  ;
 logic    mem_wren_nxt   ;
 logic    mem_chipsel_nxt   ;
 logic [63:0] mem_wdata_nxt  ;
 logic [7:0] mem_waddr_nxt  ;
 logic    rd_done_nxt    ;
 logic [2:0]  wr_count_nxt   ;
 logic [63:0] data_stored_nxt;
 logic    src_ready_nxt  ;
 
 logic [1:0]  state  ;
 logic [2:0]  wr_count   ;
 logic [63:0] data_stored;

 logic [7:0] mem_addr_count;
 logic [7:0] mem_addr_count_nxt;


 localparam IDLE = 2'b00;
 localparam RDATA = 2'b01;
 localparam MEM_WRITE = 2'b10;

always_comb
begin

 state_nxt        = state;
 rd_done_nxt      = rd_done;
 mem_wren_nxt     = mem_wren; 
 mem_wdata_nxt    = mem_wdata;
 mem_waddr_nxt    = mem_waddr;
 mem_chipsel_nxt  = mem_chipsel;
// if (wr_cnt_rst == 1'b1)
// begin
//   wr_count_nxt     = 'd0;
// end
// else
// begin
//   wr_count_nxt     = wr_count;
// end
 wr_count_nxt = wr_cnt_rst ? 'd0 : wr_count;
 data_stored_nxt  = data_stored;
 src_ready_nxt    = src_ready;

 if(rd_done_ack)
   rd_done_nxt = 0;

 case(state)
  IDLE: 
  begin
   mem_wren_nxt = 0;
   mem_chipsel_nxt = 0;
   src_ready_nxt = 0;
   if(wren_logic && src_valid && ~rd_done)
   begin
    src_ready_nxt = 1;
    state_nxt = RDATA;
   end
   else if(~poll_en)
   begin
	src_ready_nxt = 1;
   end
   
  end

  RDATA:
  begin
    if(src_ready && src_valid)
      begin
	    if ((curr_rd_addr > 118) && (curr_rd_addr < 128))
		begin
		  data_stored_nxt = {8'hFF,data_stored[63:8]};
        end
        else
        begin		
        data_stored_nxt = {src_data,data_stored[63:8]};
		end
    end
    src_ready_nxt = 1;
      
    if ((wr_count==7) || (wr_cnt_rst == 1'b1))
      begin
        wr_count_nxt = 0;
        state_nxt = MEM_WRITE;
      end
      
    else
      begin
        wr_count_nxt = wr_count +1;
        rd_done_nxt = 1;
        state_nxt = IDLE;
      end
    
    
  end

   
  MEM_WRITE:
  begin
    src_ready_nxt = 0;
    mem_wren_nxt = 1;
    mem_chipsel_nxt = 1;
    mem_wdata_nxt = data_stored;
    mem_waddr_nxt = mem_addr_count;
    rd_done_nxt = 1; // delayed rd_done for writing 64 bits to shadow CSR before taking another read
    state_nxt = IDLE;	
  end
  default: state_nxt = IDLE;
 endcase
end

always_comb
begin
	mem_addr_count_nxt = mem_addr_count;
	if(state == MEM_WRITE)
	begin
      if (mem_addr_count < 95)
      begin
        mem_addr_count_nxt = mem_addr_count +1;
      end
      else
      begin
        mem_addr_count_nxt = 0;
      end
    end
end
			
always_ff@(posedge clk or posedge reset)
begin
  if(reset)
  begin
    state       <='d0;
    rd_done     <='d0;
    mem_wren    <='d0;
    mem_wdata   <='d0;
    mem_waddr   <='d0;
    mem_chipsel <='d0;
    wr_count    <='d0;
    data_stored <='d0;
    src_ready   <='d0;
	mem_addr_count <= 'd0;
  end
   
  else
  begin
    state       <= state_nxt;
    rd_done     <= rd_done_nxt;
    mem_wren    <= mem_wren_nxt; 
    mem_wdata   <= mem_wdata_nxt;
    mem_waddr   <= mem_waddr_nxt;
    mem_chipsel <= mem_chipsel_nxt;
    wr_count    <= wr_count_nxt;
    data_stored <= data_stored_nxt;
    src_ready   <= src_ready_nxt;
	mem_addr_count <= mem_addr_count_nxt;
  end
  
end

endmodule
