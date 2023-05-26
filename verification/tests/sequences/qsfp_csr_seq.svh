//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class qsfp_csr_seq is executed by qsfp_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef QSFP_CSR_SEQ_SVH
`define QSFP_CSR_SEQ_SVH

class qsfp_csr_seq extends base_seq;
    `uvm_object_utils(qsfp_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    uvm_reg m_regs[$], n_regs[$];
    string m_regs_a[string];
    bit [63:0] r_array[string] ;
    bit [63:0] r_array_a[string] ;
    bit [63:0] w_array[string] ;


    function new(string name = "qsfp_csr_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0]  wdata, rdata, addr, mask, expdata;
        uvm_status_e             status;
        super.body();
        `uvm_info(get_name(), "Entering qsfp0_csr_seq...", UVM_LOW)

	m_regs_a["QSFP_CONTROLLER_I2C_REG"] = "QSFP_CONTROLLER_I2C_REG_REG";
        w_array["QSFP_CONTROLLER_CONFIG_REG"] = 64'h18 & 64'h0000_0000_0000_00FF ;// wdata & mask
        r_array_a["QSFP_CTRL_DFH"] = 64'h3000000010000013 ;// rarray for qsfp-1 reg	
        for(int k=0;k<=1;k++) begin    
          `uvm_info(get_name(), $psprintf("Entering qsfp_%0d",k), UVM_LOW)
	  if(k==0) begin	
            tb_env0.qsfp0_regs.get_registers(m_regs);
	    check_reset_value(m_regs,m_regs_a,r_array);
          end else if(k==1) begin   
            tb_env0.qsfp1_regs.get_registers(n_regs);
	    check_reset_value(n_regs,m_regs_a,r_array_a);
          end
        //Accessing I2c CTRL Register - Read
	  for (int i='h48; i<='h68; i=i+'h4) begin 
	    if(k==0) begin	
               addr = tb_cfg0.PF0_BAR0+ QSFP0_BASE_ADDR+i;  
            end else if(k==1) begin   
               addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+i;  
            end
            if(i<'h60) begin
	      expdata = 64'h0000000000000000 ;
            end else if (i>='h60) begin
	      expdata = 64'h0000000000000001 ;
            end  
	    mmio_read32(.addr_(addr), .data_(rdata));
	    	
	    if(expdata !== rdata)
                `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
    	    else
                `uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)
	  end

          //Accessing TFR_CMD Register - write

	  if(k==0) begin	
	    wr_rd_cmp(m_regs,m_regs_a,w_array);
            addr = tb_cfg0.PF0_BAR0+ QSFP0_BASE_ADDR +'h40;  
          end else if(k==1) begin   
	    wr_rd_cmp(n_regs,m_regs_a,w_array);
            addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h40;  
          end
          wdata = 64'h3ff; 
	  mmio_write32(.addr_(addr), .data_(wdata));


          //Accessing Shadow Register - Read only

	  `uvm_info(get_name(), "READ qsfo I2c Shadow CSR Registers 32...", UVM_LOW)
	  
	  for (int i='h0; i<='h127; i=i+'h8) begin 
	    if(k==0) //qsfp0	
	      addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h100+i;
    	    else //qsfp 1
	      addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h100+i;
	    expdata = 64'h0000000000000000 ;
	    mmio_read32(.addr_(addr), .data_(rdata));
	    	
	    if(expdata !== rdata)
                `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
    	    else
                `uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)
	  end

          //Accessing Shadow Register - Read only

	  `uvm_info(get_name(), "READ qsfo I2c Shadow CSR Registers 64...", UVM_LOW)
	  
	  for (int i='h0; i<='h127; i=i+'h8) begin 
	    if(k==0) //qsfp0	
	      addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h100+i;
    	    else //qsfp 1
	      addr = tb_cfg0.PF0_BAR0+QSFP1_BASE_ADDR+'h100+i;
	    expdata = 64'h0000000000000000 ;
	    mmio_read64(.addr_(addr), .data_(rdata));
	    	
	    if(expdata !== rdata)
                `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
    	    else
                `uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)
	  end		
	  	
          //Accessing TFR_CMD Register - write

	  if(k==0) begin	
                 addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h40;  
          end else if(k==1) begin   
                addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h40;  
	  end		
          `uvm_info(get_name(), "Writing to qsfp0 TFR_CMD CSR Registers...", UVM_LOW)
          wdata = 64'h3ff; 
	  mmio_write32(.addr_(addr), .data_(wdata));

          //Accessing I2c CTRL Register - write/Read  
	  for (int i='h48; i<='h68; i=i+'h4) begin 
            if (i =='h50 || i =='h54 || i =='h58 || i =='h5c) begin
               `uvm_info(get_name(), $psprintf("Skipping register to read addr offset %0h", i), UVM_LOW)
               continue;

	    end else begin
               if(k==0) begin //qsfp0	
                addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+i;  
               end else if(k==1) begin  //qsfp1 
                addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+i;  
               end  
               if (i=='h48) begin
                 mask = 64'h0000_0000_0000_00FF;
                 wdata = 64'h0000_0000_0000_002f & mask ; 
               end else if (i=='h4c) begin
                 mask = 64'h0000_0000_0000_00FF;
                 wdata = 64'h0000_0000_0000_0010 & mask ; 
               end else if (i>='h60) begin
                 mask = 64'h0000_0000_0000_FFFF;
                 wdata = 64'h0000_0000_0000_ffff & mask ; 
               end  
	       mmio_write32(.addr_(addr), .data_(wdata));
               mmio_read32(.addr_(addr), .data_(rdata));

               if(wdata !== rdata)
                   `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
               else
                   `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
	    end		
	  end		
	end		            
			
	`uvm_info(get_name(), "Exiting  qsfp1_csr_seq...", UVM_LOW)

    endtask : body
endclass :  qsfp_csr_seq

`endif //  QSFP_CSR_SEQ_SVH
