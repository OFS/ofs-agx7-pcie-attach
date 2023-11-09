//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class qsfp_csr_stress_seq is executed by afu_stress_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef QSFP_CSR_STRESS_SEQ_SVH
`define QSFP_CSR_STRESS_SEQ_SVH

class qsfp_csr_stress_seq extends base_seq;
    `uvm_object_utils(qsfp_csr_stress_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "qsfp_csr_stress_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0]                               wdata, rdata, addr, mask, expdata;

        super.body();
        `uvm_info(get_name(), "Entering qsfp0_csr_seq...", UVM_LOW)


//Accessing DFH Register - Read Only  
               
       `uvm_info(get_name(), "READ ONLY qsfp0 DFH CSR Registers 32...", UVM_LOW)
	expdata = 64'h3000000010000013 ; 
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h00; //BAR_address + QSFP0_DFH + Address_offset
        mmio_read32(.addr_(addr), .data_(rdata));
		
	if (expdata [31:0] !== rdata) 
		`uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
	else
		`uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)


//Accessing DFH Register - Read Only 
               
       `uvm_info(get_name(), "READ ONLY qsfp0 DFH CSR Registers 64...", UVM_LOW)
	expdata = 64'h3000000010000013 ; 
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h00; //BAR_address + QSFP0_DFH + Address_offset
        mmio_read64(.addr_(addr), .data_(rdata));
		
	if (expdata !== rdata) 
		`uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
	else
		`uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)  

//Accessing TFR_CMD Register - write 
        
        `uvm_info(get_name(), "Writing to qsfp0 TFR_CMD CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h40;  
        wdata = 64'h3ff; 
	mmio_write32(.addr_(addr), .data_(wdata));


//Accessing Config Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 Config CSR Registers 32...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h20;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h18 & mask; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing Config Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 Config CSR Registers 64...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h20;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h18 & mask; 
	
	mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing Scratchpad Register - write/Read 
        
        `uvm_info(get_name(), "Writing to qsfp0 READ WRITE Scratchpad CSR Registers 32...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h30;  
        wdata = 64'hdead_beef; 
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing Scratchpad Register - write/Read 
        
        `uvm_info(get_name(), "Writing to qsfp0 READ WRITE Scratchpad CSR Registers 64...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h30;  
        wdata = 64'hdead_beef; 
	mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing TFR_CMD Register - write 
        
        `uvm_info(get_name(), "Writing to qsfp0 TFR_CMD CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h40;  
        wdata = 64'h3ff; 
	mmio_write32(.addr_(addr), .data_(wdata));

//Accessing I2c CTRL Register - write/Read  

	`uvm_info(get_name(), "Writing to qsfp0 READ WRITE I2c CTRL CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h48;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h0000_0000_0000_002f & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c ISER Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 READ WRITE I2c ISER CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h4c;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h0000_0000_0000_0010 & mask ; 

	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c SCL LOW Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 READ WRITE I2c SCL LOW CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h60;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 

	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c SCL HIGH Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 READ WRITE I2c SCL HIGH CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h64;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)	

//Accessing I2c SDA HOLD Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp0 READ WRITE I2c SDA HOLD CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+'h68;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)	
			
	`uvm_info(get_name(), "Exiting  qsfp0_csr_seq...", UVM_LOW)

	`uvm_info(get_name(), "Entering qsfp1_csr_seq...", UVM_LOW)
		
//Accessing DFH Register - Read Only
               
       `uvm_info(get_name(), "READ ONLY qsfp1 DFH CSR Registers 32...", UVM_LOW)
	expdata = 64'h3000000010000013 ; 
        addr = tb_cfg0.PF0_BAR0+QSFP1_BASE_ADDR+'h00; //BAR_address + QSFP1_DFH + Address_offset
        mmio_read32(.addr_(addr), .data_(rdata));
		
	if (expdata [31:0] !== rdata) 
		`uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
	else
		`uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)

//Accessing DFH Register - Read Only
               
       `uvm_info(get_name(), "READ ONLY qsfp1 DFH CSR Registers 64...", UVM_LOW)
	expdata = 64'h3000000010000013 ; 
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h00; //BAR_address + QSFP1_DFH + Address_offset
        mmio_read64(.addr_(addr), .data_(rdata));
		
	if (expdata !== rdata) 
		`uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata))
	else
		`uvm_info(get_name(), $psprintf(" Data match 64! Addr = %0h, Exp = %0h, Act = %0h", addr, expdata, rdata), UVM_LOW)  

		
//Accessing Config Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 Config CSR Registers 32...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h20;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h18 & mask; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing Config Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 Config CSR Registers 64...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h20;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h18 & mask; 
	
	mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing Scratchpad Register - write/Read 
        
        `uvm_info(get_name(), "Writing to qsfp1 Scratchpad CSR Registers 32...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h30;  
        wdata = 64'hdead_beef; 
		
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing Scratchpad Register - write/Read 
        
        `uvm_info(get_name(), "Writing to qsfp1 Scratchpad CSR Registers 64...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h30;  
        wdata = 64'hdead_beef; 
		
	mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

//Accessing TFR_CMD Register - write 
        
        `uvm_info(get_name(), "Writing to qsfp1 TFR_CMD CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h40;  
        wdata = 64'h3ff; 
	mmio_write32(.addr_(addr), .data_(wdata));


//Accessing I2c CTRL Register - write/Read  

	`uvm_info(get_name(), "Writing to qsfp1 I2c CTRL CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h48;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h0000_0000_0000_002f & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c ISER Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 I2c ISER CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h4c;  
        mask = 64'h0000_0000_0000_00FF;
        wdata = 64'h0000_0000_0000_0010 & mask ; 
		
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c SCL LOW Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 I2c SCL LOW CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h60;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 
		
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
			
//Accessing I2c SCL HIGH Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 I2c SCL HIGH CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h64;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)	

//Accessing I2c SDA HOLD Register - write/Read 

	`uvm_info(get_name(), "Writing to qsfp1 I2c SDA HOLD CSR Registers...", UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h68;  
        mask = 64'h0000_0000_0000_FFFF;
        wdata = 64'h0000_0000_0000_ffff & mask ; 
	
	mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32(.addr_(addr), .data_(rdata));

        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf(" Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)	
			
	`uvm_info(get_name(), "Exiting  qsfp1_csr_seq...", UVM_LOW)

    endtask : body
endclass :  qsfp_csr_stress_seq

`endif //  QSFP_CSR_STRESS_SEQ_SVH
