//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class mem_tg_csr_seq is executed by mem_tg_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 * Sequence is running on virtual_sequencer .
 * Calbritaion check is done and verified TG config registers
 */
//===============================================================================================================

`ifndef MEM_TG_CSR_SEQ_SVH
`define MEM_TG_CSR_SEQ_SVH

 class mem_tg_csr_seq extends base_seq;
  `uvm_object_utils(mem_tg_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
   
    uvm_reg m_regs[$];
    uvm_reg m_regs_m[$];
    string m_regs_a[string],m_regs_b[string];
    bit [63:0] r_array[string],r_a_array[string] ;
    bit [63:0] w_array[string] ;
  
   function new(string name = "mem_tg_csr_seq");
   	super.new(name);
   endfunction : new

   task body();
     localparam EMIF_CAPABILITY_OFFSET = 'h10;
     //localparam NUM_TG = 3;
     localparam NUM_TG =ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS -1; 
     localparam EMIF_STATUS_OFFSET = 'h08;
     localparam EMIF_FEAT_ID       = 12'h9;
     bit [63:0]   wdata,rdata,mask,expdata,addr,default_value,rw_bits;
     bit [NUM_TG-1:0]   ch_done;
     bit 	   cal_done;
     bit [63:0]   mem_dfh, mem_capability; 
     int                ch;
     int                ch_count;
     uvm_status_e       status;
     
     super.body();
       `uvm_info(get_name(), "Entering mem_tg_csr_seq...", UVM_LOW)
        mem_dfh  = tb_cfg0.PF0_BAR0;
        rdata = '0;
        while(rdata[11:0] != EMIF_FEAT_ID) begin
       	  mem_dfh = mem_dfh + rdata[39:16];
          mmio_read64(.addr_(mem_dfh), .data_(rdata));
    	end

	`ifdef FTILE_SIM
        r_array["MEM_TG_CTRL"] = 64'h0000_0000_0000_0001;
        `else 
        r_array["MEM_TG_CTRL"] = 64'h0000_0000_0000_0007;
        `endif 
	m_regs_a["MEM_TG_STAT"] = "MEM_TG_STAT_REG";
        tb_env0.mem_tg_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
       	wr_rd_cmp(m_regs,m_regs_a,w_array);

      `ifdef  INCLUDE_DDR4
        ch_done  = 0;
        ch       = 0;
        ch_count = 0;

       
       m_regs_m[0] = tb_env0.mem_tg_regs.get_reg_by_name("MEM_TG_STAT");
       check_reset_value(m_regs_m,m_regs_b,r_a_array);
       
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

      while (~&ch_done && ch_count < 3) begin
         #1us;
         addr = mem_dfh + EMIF_STATUS_OFFSET;
         mmio_read32 (.addr_(addr), .data_(rdata));
         `uvm_info(get_name(), $psprintf("EMIF_STATUS = %0b", rdata[NUM_TG-1:0]), UVM_LOW)
         for (ch = 0; ch < NUM_TG; ch++) begin
            if (!ch_done[ch]) begin
               if (rdata[ch]) begin
                  verify_tg_cfg_regs(ch);
                  ch_done[ch] = 1;
                  ch_count++;
               end
            end
         end
      end
      `endif //  `ifdef INCLUDE_DDR4
      
   endtask : body

   task verify_tg_cfg_regs(input int ch);
       bit [31:0]   expdata;
       bit [31:0]   wdata;
       bit [31:0]   rdata;
       bit [63:0]   addr;
       bit [63:0]   base;
       
       base    = tb_cfg0.PF0_VF2_BAR0+'h1000+(ch*'h1000);
       addr    = base+'h000;
       expdata = 'ha9;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_VERSION_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_VERSION_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end

       addr    = base+'h004;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_START_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_START_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end

       addr    = base+'h008;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_LOOP_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_LOOP_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr  = base+'h00c;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
 
       if(rdata == expdata)
         `uvm_info(get_name(), $psprintf("TG_WRITE_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       else
         `uvm_error(get_name(), $psprintf("TG_WRITE_COUNT_%1d Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))


       addr    = base+'h010;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_READ_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_READ_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h014;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_WRITE_REPEAT_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_WRITE_REPEAT_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h018;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_READ_REPEAT_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_READ_REPEAT_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h01c;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BURST_LENGTH_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BURST_LENGTH_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h020;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_CLEAR_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_CLEAR_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h038;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RW_GEN_IDLE_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RW_GEN_IDLE_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h03c;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RW_GEN_LOOP_IDLE_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RW_GEN_LOOP_IDLE_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h040;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_SEQ_START_ADDR_WR_L_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_SEQ_START_ADDR_WR_L_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h044;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_SEQ_START_ADDR_WR_H_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_SEQ_START_ADDR_WR_H_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h048;
       expdata = 2;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_ADDR_MODE_WR_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_ADDR_MODE_WR_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h04c;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RAND_SEQ_ADDRS_WR_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RAND_SEQ_ADDRS_WR_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h050;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RETURN_TO_START_ADDR_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RETURN_TO_START_ADDR_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h074;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_SEQ_ADDR_INCR_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_SEQ_ADDR_INCR_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h078;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_SEQ_START_ADDR_RD_L_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_SEQ_START_ADDR_RD_L_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h07c;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_SEQ_START_ADDR_RD_H_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_SEQ_START_ADDR_RD_H_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h080;
       expdata = 2;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_ADDR_MODE_RD_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_ADDR_MODE_RD_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h084;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RAND_SEQ_ADDRS_RD_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RAND_SEQ_ADDRS_RD_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h088;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_PASS_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_PASS_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h08c;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_FAIL_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_FAIL_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h090;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_FAIL_COUNT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_FAIL_COUNT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end

       addr    = base+'h0a0;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_TOTAL_READ_COUNT_L_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_TOTAL_READ_COUNT_L_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0a4;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_TOTAL_READ_COUNT_H_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_TOTAL_READ_COUNT_H_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0a8;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_TEST_COMPLETE_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_TEST_COMPLETE_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0ac;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_INVERT_BYTEEN_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_INVERT_BYTEEN_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0b4;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_USER_WORM_EN_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_USER_WORM_EN_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0b8;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_TEST_BYTEEN_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_TEST_BYTEEN_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0c4;
       expdata = 8;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_NUM_DATA_GEN_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_NUM_DATA_GEN_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0c8;
       expdata = 1;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_NUM_BYTEEN_GEN_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_NUM_BYTEEN_GEN_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0dc;
       expdata = 'h200;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_RDATA_WIDTH_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_RDATA_WIDTH_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0ec;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_ERROR_REPORT_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_ERROR_REPORT_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h0f0;
       expdata = 8;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_DATA_RATE_WIDTH_RATIO_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_DATA_RATE_WIDTH_RATIO_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h100;
       expdata = 'hffff_ffff;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_PNF_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_PNF_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h200;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_FAIL_EXPECTED_DATA_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_FAIL_EXPECTED_DATA_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h300;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_FAIL_READ_DATA_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_FAIL_READ_DATA_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end
       


       addr    = base+'h400;
       expdata = 'h5a5a_5a5a;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_DATA_SEED_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_DATA_SEED_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'h800;
       expdata = 'hffff_ffff;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BYTEEN_SEED_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BYTEEN_SEED_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'hc00;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_PPPG_SEL_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_PPPG_SEL_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'he80;
       expdata = 0;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BYTEEN_SEL_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BYTEEN_SEL_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'hec0;
       expdata = 'hbad_f00d;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BURSTLENGTH_OVERFLOW_OCCURRED_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BURSTLENGTH_OVERFLOW_OCCURRED_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'hec4;
       expdata = 'hbad_f00d;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BURSTLENGTH_FAIL_ADDR_L_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BURSTLENGTH_FAIL_ADDR_L_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end


       addr    = base+'hec8;
       expdata = 'hbad_f00d;
       mmio_read32 (.addr_(addr), .data_(rdata));
       if(rdata == expdata) begin
          `uvm_info(get_name(), $psprintf("TG_BURSTLENGTH_FAIL_ADDR_H_%1d match 32 !Addr= %0h,  Exp = %0h, Act = %0h", ch, addr, expdata, rdata), UVM_LOW)
       end
       else begin
          `uvm_error(get_name(), $psprintf("TG_BURSTLENGTH_FAIL_ADDR_H_%1d data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", ch, addr, expdata, rdata))
       end

    endtask : verify_tg_cfg_regs   
endclass :  mem_tg_csr_seq

`endif //  MEM_TG_CSR_SEQ_SVH


