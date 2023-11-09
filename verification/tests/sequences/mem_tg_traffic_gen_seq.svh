//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class mem_tg_traffic_gen_seq is executed by mem_tg_traffic_gen_test
* Calbritaion check is done 
* This sequence verifies the Traffic Generator flow
* Also Verifies the WRITE, READ, REPEAT, and LOOP counts registers
* Sequence is running on virtual_sequencer .
*/
//===============================================================================================================

`ifndef MEM_TG_TRAFFIC_GEN_SEQ_SVH
`define MEM_TG_TRAFFIC_GEN_SEQ_SVH

 class mem_tg_traffic_gen_seq extends base_seq;
   `uvm_object_utils(mem_tg_traffic_gen_seq)
   `uvm_declare_p_sequencer(virtual_sequencer)

   rand int stride;
   rand int burstcount;
   rand int reads;
   rand int writes;
   rand int loops;
   constraint test_cfg_c {
      writes inside {[1:64]};
      burstcount inside {[1:8]};
      0 < reads; reads <= writes;
      burstcount <= stride; stride < 'hFFFF;
      0 < loops; loops < 'h4;
      solve writes before reads;
      solve burstcount before stride;
   }
    
   function new(string name = "mem_tg_traffic_gen_seq");
     super.new(name);
   endfunction : new

   task body();
      // EMIF DFH
      localparam EMIF_FEAT_ID           = 12'h9;
      localparam EMIF_STATUS_OFFSET     = 'h08;
      localparam EMIF_CAPABILITY_OFFSET = 'h10;

      // MemSS CSR offset from EMIF DFH
      localparam MEM_SS_OFFSET         = 'h6000;
      localparam MEM_SS_FEAT_LIST_2    = 'h08;

      // AFU Registers
      localparam AFU_ID_L_OFFSET = 'h08;
      localparam AFU_ID_H_OFFSET = 'h10;
      localparam AFU_SCRATCH_OFFSET = 'h28;
      
      localparam MEM_TG_CTRL_OFFSET    = 'h30;
      localparam MEM_TG_STATUS_OFFSET  = 'h38;
      localparam TG_CLK_COUNT_OFFSET   = 'h50;
      localparam TG2_CH_OFFSET         = 'h1000;

      localparam TG_VERSION            = 'h00;
      localparam TG_START              = 'h04;
      localparam TG_LOOP_COUNT         = 'h08;
      localparam TG_WRITE_COUNT        = 'h0C;
      localparam TG_READ_COUNT         = 'h10;
      localparam TG_WRITE_REPEAT_COUNT = 'h14;
      localparam TG_READ_REPEAT_COUNT  = 'h18;
      localparam TG_BURST_LENGTH       = 'h1C;
      localparam TG_RW_GEN_IDLE_COUNT  = 'h38;
      localparam TG_SEQ_ADDR_INCR      = 'h74;

      localparam AFU_DFH               = 64'h1000010000001000;
      localparam AFU_ID_L              = 64'hA3DC5B831F5CECBB;
      localparam AFU_ID_H              = 64'h4DADEA342C7848CB;

      localparam MEM_TG_VERSION        = 'd169;

      
      bit [63:0]   wdata,rdata,expdata,addr;
      bit [63:0]   mem_dfh, mem_capability, tg_capability;
      bit 	   cal_done;

      string 	   reg_name;

      uvm_status_e       status;

      super.body();
      this.randomize();
      
      `uvm_info(get_name(), "Entering mem_tg_traffic_gen_seq...", UVM_LOW)
      `uvm_info(get_name(), $psprintf("TG test config: stride = %0d :: burstcount = %0d :: reads = %0d :: writes = %0d :: loops = %0d", stride, burstcount, reads, writes, loops),UVM_LOW)

      // Mem DFH discovery
      mem_dfh  = tb_cfg0.PF0_BAR0;
      rdata = '0;
      while(rdata[11:0] != EMIF_FEAT_ID) begin
         mem_dfh = mem_dfh + rdata[39:16];
         mmio_read64(.addr_(mem_dfh), .data_(rdata));
      end

 `ifdef INCLUDE_DDR4
      // Wait for all channels to calibrate. MEM_SS_FEAT_LIST_2 = num EMIFs
      addr=mem_dfh+EMIF_CAPABILITY_OFFSET;
      mmio_read64 (.addr_(addr), .data_(mem_capability));
      addr=mem_dfh+EMIF_STATUS_OFFSET;
      cal_done = '0;
      while(!cal_done) begin
         mmio_read64(.addr_(addr), .data_(rdata));
	 `uvm_info(get_name(), $psprintf("EMIF_STATUS  data Addr= %0h, Act = %0h", addr, rdata),UVM_LOW)
	 cal_done = mem_capability == (mem_capability & rdata);
      end
 `endif //  `ifdef INCLUDE_DDR4

      //1.SW Reads DFH at offset 0x0
      addr  = tb_cfg0.PF0_VF2_BAR0;
      expdata = AFU_DFH;
      $sformat(reg_name,"AFU_DFH");
      test_mmio_rd(reg_name,addr,expdata);

      //2.SW Reads AFU ID at offset 0x8 (lower 64b), 0x10 (upper 64b)
      addr  = tb_cfg0.PF0_VF2_BAR0+AFU_ID_L_OFFSET;
      expdata = AFU_ID_L;
      $sformat(reg_name,"AFU_ID_L");
      test_mmio_rd(reg_name,addr,expdata);

      addr  = tb_cfg0.PF0_VF2_BAR0+AFU_ID_H_OFFSET;
      expdata = AFU_ID_H;
      $sformat(reg_name,"AFU_ID_H");
      test_mmio_rd(reg_name,addr,expdata);

      //3.SW Tests R/W access capability of scratch register at address 0x28
      addr  = tb_cfg0.PF0_VF2_BAR0+AFU_SCRATCH_OFFSET;
      expdata = '0;
      wdata   = {$urandom(),$urandom()};
      $sformat(reg_name,"AFU_SCRATCHPAD");
      test_mmio_rd(reg_name,addr,expdata);
      test_mmio_wr(reg_name,addr,wdata);

      `uvm_info(get_name, "Reading TG Capability", UVM_LOW);
      addr  = tb_cfg0.PF0_VF2_BAR0+MEM_TG_CTRL_OFFSET;
      mmio_read64(.addr_(addr), .data_(tg_capability));
 `ifdef INCLUDE_DDR4
      `uvm_info(get_name, "Verify that TG capabilty matches memory.", UVM_LOW)
      if (tg_capability != (tg_capability & mem_capability)) begin
         `uvm_warning(get_name, $psprintf("EMIF_CAPABILITY %04b not compatible with MEM_TG_CAPABILTIY %04b!", mem_capability, tg_capability))
      end
 `endif

      for (int ch = 0; tg_capability[ch] == 1'b1; ch++) begin : tg_cfg
	 addr  = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET;
 `ifdef INCLUDE_DDR4
	 expdata = MEM_TG_VERSION;
 `else
	 expdata = '0;
 `endif
	 $sformat(reg_name,"TG_VERSION_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 


	 `uvm_info(get_name, "Verify the WRITE, READ, REPEAT, and LOOP counts are 1.", UVM_LOW)
 `ifdef INCLUDE_DDR4
	 expdata = 1;
 `else
	 expdata = '0;
 `endif

        `ifdef INCLUDE_DDR4

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_LOOP_COUNT;
	 wdata   = loops;
	 $sformat(reg_name,"TG_LOOP_COUNT_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 test_mmio_wr(reg_name,addr,wdata);

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_WRITE_COUNT;
	 wdata   = writes;
	 $sformat(reg_name,"TG_WRITE_COUNT_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 test_mmio_wr(reg_name,addr,wdata);

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_READ_COUNT;
	 wdata   = reads;
	 $sformat(reg_name,"TG_READ_COUNT_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 test_mmio_wr(reg_name,addr,wdata);
	 
	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_WRITE_REPEAT_COUNT;
	 $sformat(reg_name,"TG_WRITE_REPEAT_COUNT_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_READ_REPEAT_COUNT;
	 $sformat(reg_name,"TG_READ_REPEAT_COUNT_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_BURST_LENGTH;
	 wdata   = burstcount;
	 $sformat(reg_name,"TG_BURST_LENGTH_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 test_mmio_wr(reg_name,addr,wdata);

	 addr    = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_SEQ_ADDR_INCR;
	 wdata   = stride;
	 $sformat(reg_name,"TG_SEQ_ADDR_INCR_%1d",ch);
	 test_mmio_rd(reg_name,addr,expdata);
	 test_mmio_wr(reg_name,addr,wdata);

	 `endif


      end : tg_cfg

      `uvm_info(get_name(), "TG Config complete! Starting traffic test...", UVM_LOW)
      for (int ch = 0; tg_capability[ch] == 1'b1; ch++) begin : tg_start
	 addr = tb_cfg0.PF0_VF2_BAR0+(ch+1)*TG2_CH_OFFSET+TG_START;
	 wdata = 'h1;
	 mmio_write32(.addr_(addr), .data_(wdata));
      end : tg_start

`ifdef INCLUDE_DDR4                             

  //6.SW polls the TG_CTRL register active bits while they are high at address 0x38, This corresponds to every 4th bit starting from bit 0 and extending to the number of traffic generators described by the capability value.

 //7. When the active bits go low, SW reads the TG_CTRL register and checks which test status bit went high for each traffic generator test. The 4 bit status value corresponding to each traffic generator will be  
  //  0x2 : Test timeout   0x4 : Test fail  0x8 : Test pass
    
  do begin
    addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR+ 'h0038;		
    mmio_read64 (.addr_(addr), .data_(rdata));

    tb_env0.mem_tg_regs.MEM_TG_STAT.read(status,rdata);
    `ifdef COV tb_env0.mem_tg_regs.MEM_TG_STAT.cg_vals.sample();`endif

   `uvm_info(get_name(), $psprintf("MEM_TG_STAT = %0h", rdata), UVM_LOW)
    end while( !(|(rdata[3:1])));

  `uvm_info(get_name(), $psprintf("Exit while_loop MEM_TG_STAT = %0h", rdata), UVM_LOW) 
  
   mmio_read64 (.addr_(addr), .data_(rdata));

   tb_env0.mem_tg_regs.MEM_TG_STAT.read(status,rdata);
   `ifdef COV tb_env0.mem_tg_regs.MEM_TG_STAT.cg_vals.sample();`endif

  `uvm_info(get_name(), $psprintf("MEM_TG_STAT = %0h", rdata), UVM_LOW)
   
    if (rdata[3:0]==4'h2)
      `uvm_info(get_name(), $psprintf("TEST timeout  = %0h", rdata), UVM_LOW)
    else if (rdata[3:0]==4'h4)
       `uvm_info(get_name(), $psprintf("TEST fail = %0h", rdata), UVM_LOW)
    else if (rdata[3:0]==4'h8)
      `uvm_info(get_name(), $psprintf("TEST pass = %0h", rdata), UVM_LOW)

  `uvm_info(get_name(), "Exiting  mem_tg_traffic_gen_seq...", UVM_LOW)

`endif

 endtask : body

   task test_mmio_wr  (input string     label, 
		       input bit [63:0] addr, 
		       input bit [31:0] wdata);

      bit [31:0] rdata;
      mmio_write32 (.addr_(addr), .data_(wdata));
      mmio_read64 (.addr_(addr),  .data_(rdata));
      if (rdata != wdata) begin
         `uvm_error(get_name(), $psprintf("Write %s Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", label, addr, wdata, rdata))
      end else begin
         `uvm_info(get_name(), $psprintf("Write %s Data match 32! Addr= %0h, Exp = %0h, Act = %0h", label, addr, wdata, rdata),UVM_LOW)
      end
      
   endtask : test_mmio_wr

   task test_mmio_rd  (input string     label, 
		       input bit [63:0] addr, 
		       input bit [31:0] expdata);

      bit [31:0] rdata;
      mmio_read64 (.addr_(addr),  .data_(rdata));
      if (rdata != expdata) begin
         `uvm_error(get_name(), $psprintf("Read %s Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", label, addr, expdata, rdata))
      end else begin
         `uvm_info(get_name(), $psprintf("Read %s Data match 32! Addr= %0h, Exp = %0h, Act = %0h", label, addr, expdata, rdata),UVM_LOW)
      end
      

   endtask : test_mmio_rd

endclass :  mem_tg_traffic_gen_seq

`endif //  MEM_TG_TRAFFIC_GEN_SEQ_SVH


