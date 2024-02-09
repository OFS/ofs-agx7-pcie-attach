//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class emif_csr_seq is executed by emif_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef EMIF_CSR_SEQ_SVH
`define EMIF_CSR_SEQ_SVH

class emif_csr_seq extends base_seq;
  `uvm_object_utils(emif_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)
   uvm_reg m_regs[$];
   uvm_reg m_regs_m[$];
   string m_regs_a[string],m_regs_b[string];
   bit [63:0] r_array[string],r_a_array[string] ;
   bit [63:0] w_array[string] ;

   function new(string name = "emif_csr_seq");
   	super.new(name);
   endfunction : new

   task body();
     //EMIF DFH
     localparam EMIF_STATUS_OFFSET     = 'h08;
     localparam EMIF_CAPABILITY_OFFSET = 'h10;
     localparam EMIF_FEAT_ID           = 12'h9;
     bit [63:0]   wdata,rdata,mask,expdata,addr;
     bit [63:0]   mem_dfh, mem_capability;
     bit 	   cal_done; 
     uvm_status_e       status;

     super.body();
    	`uvm_info(get_name(), "Entering emif_csr_seq...", UVM_LOW)
         mem_dfh  = tb_cfg0.PF0_BAR0;
         rdata = '0;
	`ifdef  INCLUDE_DDR4
     	 while(rdata[11:0] != EMIF_FEAT_ID) begin
         	mem_dfh = mem_dfh + rdata[39:16];
        	 mmio_read64(.addr_(mem_dfh), .data_(rdata));
         end
	`else
          m_regs_a["EMIF_DFH"] = "EMIF_DFH";
	`endif

	 m_regs_a["EMIF_STATUS"] = "EMIF_STATUS_REG";
	 m_regs_a["EMIF_CAPABILITY"] = "EMIF_CAPABILITY_REG";
	 m_regs_a["MEM_SS_VERSION"] = "MEM_SS_VERSION_REG";
	 m_regs_a["MEM_SS_FEAT_LIST"] = "MEM_SS_FEAT_LIST_REG";
	 m_regs_a["MEM_SS_FEAT_LIST_2"] = "MEM_SS_FEAT_LIST_2_REG";
	 m_regs_a["MEM_SS_IF_ATTR"] = "MEM_SS_IF_ATTR_REG";
	 m_regs_a["MEM_SS_SCRATCH"] = "MEM_SS_SCRATCH_REG";
	 m_regs_a["MEM_SS_STATUS"] = "MEM_SS_STATUS_REG";
	 m_regs_a["MEM_SS_CH0_ATTR"] = "MEM_SS_CH0_ATTR_REG";
	 m_regs_a["MEM_SS_CH1_ATTR"] = "MEM_SS_CH1_ATTR_REG";
	 m_regs_a["MEM_SS_CH2_ATTR"] = "MEM_SS_CH2_ATTR_REG";
	 m_regs_a["MEM_SS_CH3_ATTR"] = "MEM_SS_CH3_ATTR_REG" ;
         tb_env0.emif_regs.get_registers(m_regs);
	 check_reset_value(m_regs,m_regs_a,r_array);
         wr_rd_cmp(m_regs,m_regs_a,w_array); 

     `ifdef  INCLUDE_DDR4
       
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
         m_regs_m[0] = tb_env0.emif_regs.get_reg_by_name("EMIF_STATUS");
       `ifdef FTILE_SIM
         r_a_array["EMIF_STATUS"] = 64'h0000_0000_0000_0003;
       `else
         r_a_array["EMIF_STATUS"] = 64'h0000_0000_0000_000f;
       `endif
	 check_reset_value(m_regs_m,m_regs_b,r_a_array);
	 m_regs_m[1] = tb_env0.emif_regs.get_reg_by_name("EMIF_CAPABILITY");
        `ifdef FTILE_SIM
         r_a_array["EMIF_CAPABILITY"] = 64'h0000_0000_0000_0003;
        `endif
         check_reset_value(m_regs_m,m_regs_b,r_a_array);
     `else
         m_regs_m[0] = tb_env0.emif_regs.get_reg_by_name("EMIF_STATUS");
         check_reset_value(m_regs_m,m_regs_b,r_a_array);
	 m_regs_m[1] = tb_env0.emif_regs.get_reg_by_name("EMIF_CAPABILITY");
         r_a_array["EMIF_CAPABILITY"] = 64'h0000_0000_0000_0000;
         m_regs_m[2] = tb_env0.emif_regs.get_reg_by_name("EMIF_DFH");	 
         r_a_array["EMIF_DFH"] = 64'h3000_0000_b000_1000;
	 check_reset_value(m_regs_m,m_regs_b,r_a_array);
     `endif 
     `uvm_info(get_name(), "Exiting  emif_csr_seq...", UVM_LOW)
   endtask : body
endclass :  emif_csr_seq

`endif //  EMIF_CSR_SEQ_SVH


