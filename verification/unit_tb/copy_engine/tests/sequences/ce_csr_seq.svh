// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_CSR_SEQ_SVH
`define CE_CSR_SEQ_SVH

class ce_csr_seq extends base_seq;
 `uvm_object_utils(ce_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "ce_csr_seq");
        super.new(name);
    endfunction : new
 task body();
	bit [63:0]   wdata,rdata,mask,expdata,addr;
                          

        super.body();
        `uvm_info(get_name(), "Entering ce_csr_seq...", UVM_LOW)
	         
		`uvm_info(get_name(), "Entering CE_FEATURE_DFH READ ONLY CSR Registers...", UVM_LOW)
				
	   	expdata =64'h1000010010001001;
		addr = `PF4_BAR0+'h0000;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	`uvm_info(get_name(), $psprintf(" CE_FEATURE_DFH match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_DFH data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata,rdata))

      		`uvm_info(get_name(), "Exiting  CE_FEATURE_DFH_seq...", UVM_LOW)


            
             `uvm_info(get_name(), "Entering CE_FEATURE_DFH READ ONLY CSR Registers...", UVM_LOW)
				
	   	expdata =64'h1000010010001001;
		addr = `PF4_BAR0+'h0000;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0] )
            	`uvm_info(get_name(), $psprintf(" CE_FEATURE_DFH match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_DFH data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0],rdata[31:0]))

      		`uvm_info(get_name(), "Exiting  CE_FEATURE_DFH_seq...", UVM_LOW)


		`uvm_info(get_name(), "Entering CE_FEATURE_DFH READ ONLY CSR Registers...", UVM_LOW)
				
	   	expdata =64'h1000010010001001;
		addr = `PF4_BAR0+'h0000+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32] ) 
            	`uvm_info(get_name(), $psprintf("  CE_FEATURE_DFH match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_DFH data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32],rdata[31:0]))

      		`uvm_info(get_name(), "Exiting  CE_FEATURE_DFH_seq...", UVM_LOW)



		`uvm_info(get_name(), "Entering CE_FEATURE_GUID_L READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'hbd4257dc93ea7f91;
		addr = `PF4_BAR0+'h0008;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata== expdata)
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_L Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_L Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

         	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_L_seq...", UVM_LOW)


		

            
           `uvm_info(get_name(), "Entering CE_FEATURE_GUID_L READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'hbd4257dc93ea7f91;
		addr = `PF4_BAR0+'h0008;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0]== expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_L Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_L Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_L_seq...", UVM_LOW)


		  
           `uvm_info(get_name(), "Entering CE_FEATURE_GUID_L READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'hbd4257dc93ea7f91;
		addr = `PF4_BAR0+'h0008+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0]== expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_L Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_L Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_L_seq...", UVM_LOW)




	 `uvm_info(get_name(), "Entering  CE_FEATURE_GUID_H READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h44bfc10db42a44e5;
		addr = `PF4_BAR0+'h0010;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_H Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_H Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_H_seq...", UVM_LOW)

	

		

	 `uvm_info(get_name(), "Entering  CE_FEATURE_GUID_H READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h44bfc10db42a44e5;
		addr = `PF4_BAR0+'h0010;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_H Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_H Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_H_seq...", UVM_LOW)


			
	 `uvm_info(get_name(), "Entering  CE_FEATURE_GUID_H READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h44bfc10db42a44e5;
		addr = `PF4_BAR0+'h0010+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_GUID_H Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_GUID_H Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_GUID_H_seq...", UVM_LOW)

		`uvm_info(get_name(), "Entering CE_FEATURE_CSR_ADDR READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000100;
		addr = `PF4_BAR0+'h0018;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf("  CE_FEATURE_CSR_ADDR Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_ADDR Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_CSR_ADDR_seq...", UVM_LOW)





	 `uvm_info(get_name(), "Entering CE_FEATURE_CSR_ADDR READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000100;
		addr = `PF4_BAR0+'h0018;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf("  CE_FEATURE_CSR_ADDR Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_ADDR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_CSR_ADDR_seq...", UVM_LOW)



	`uvm_info(get_name(), "Entering CE_FEATURE_CSR_ADDR READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000100;
		addr = `PF4_BAR0+'h0018+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf("  CE_FEATURE_CSR_ADDR Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_ADDR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CE_FEATURE_CSR_ADDR_seq...", UVM_LOW)


		`uvm_info(get_name(), "Entering CE_FEATURE_CSR_SIZE_GROUP READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000005000000000;
		addr = `PF4_BAR0+'h0020;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata== expdata)
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting CE_FEATURE_CSR_SIZE_GROUP_seq...", UVM_LOW)



	

	 `uvm_info(get_name(), "Entering CE_FEATURE_CSR_SIZE_GROUP READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000005000000000;
		addr = `PF4_BAR0+'h0020;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0]== expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting CE_FEATURE_CSR_SIZE_GROUP_seq...", UVM_LOW)


		`uvm_info(get_name(), "Entering CE_FEATURE_CSR_SIZE_GROUP READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000005000000000;
		addr = `PF4_BAR0+'h0020+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0]== expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CE_FEATURE_CSR_SIZE_GROUP Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting CE_FEATURE_CSR_SIZE_GROUP_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Entering CSR_CE2HOST_DATA_REQ_LIMIT READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000003;
		addr = `PF4_BAR0+'h0108;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), "Exiting  CSR_CE2HOST_DATA_REQ_LIMIT seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering  CSR_CE2HOST_DATA_REQ_LIMIT  READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000003;
		addr = `PF4_BAR0+'h0108;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CSR_CE2HOST_DATA_REQ_LIMIT _seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering  CSR_CE2HOST_DATA_REQ_LIMIT  READ ONLY CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000003;
		addr = `PF4_BAR0+'h0108+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT  Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "Exiting  CSR_CE2HOST_DATA_REQ_LIMIT _seq...", UVM_LOW)


	`uvm_info(get_name(), "Writing CSR_CE2HOST_DATA_REQ_LIMIT  CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0108;
                wdata = 64'h1;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_CE2HOST_DATA_REQ_LIMIT Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	`uvm_info(get_name(), "  Exiting CSR_CE2HOST_DATA_REQ_LIMIT_seq...", UVM_LOW)


     `uvm_info(get_name(), "Writing CSR_CE2HOST_DATA_REQ_LIMIT CSR Registers...", UVM_LOW)
			
	  	
	addr = `PF4_BAR0+'h0108;
         wdata = 64'h1;
	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == wdata[31:0])
           	 `uvm_info(get_name(), $psprintf(" CSR_CE2HOST_DATA_REQ_LIMIT match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
           else
            	 `uvm_error(get_name(), $psprintf("CSR_CE2HOST_DATA_REQ_LIMIT Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting CSR_CE2HOST_DATA_REQ_LIMIT...", UVM_LOW)
		
		

		`uvm_info(get_name(), "Entering read CSR_HOST_SCRATCHPAD CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0100;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST_SCRATCHPAD match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST_SCRATCHPAD Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), "  Exiting read CSR_HOST_SCRATCHPAD_seq...", UVM_LOW)



      `uvm_info(get_name(), "Entering read CSR_HOST_SCRATCHPAD CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0100;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST_SCRATCHPAD match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST_SCRATCHPAD Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting read CSR_HOST_SCRATCHPAD_seq...", UVM_LOW)

	
      `uvm_info(get_name(), "Entering read CSR_HOST_SCRATCHPAD CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0100+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf("CSR_HOST_SCRATCHPAD match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST_SCRATCHPAD Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting read CSR_HOST_SCRATCHPAD_seq...", UVM_LOW)


	`uvm_info(get_name(), "Writing CSR_HOST_SCRATCHPAD CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0100;
                wdata = 64'hdeadbeefdeadbeef;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST_SCRATCHPAD match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST_SCRATCHPAD Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	`uvm_info(get_name(), "  Exiting CSR_HOST_SCRATCHPAD_seq...", UVM_LOW)

	
        `uvm_info(get_name(), "Writing CSR_HOST_SCRATCHPAD CSR Registers...", UVM_LOW)
			
	  	
	addr = `PF4_BAR0+'h0100;
         wdata = 64'hdeadbeefdeadbeef;
	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == wdata[31:0])
           	 `uvm_info(get_name(), $psprintf(" CSR_HOST_SCRATCHPAD match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
           else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST_SCRATCHPAD Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting CSR_SCRATCHPAD_seq...", UVM_LOW)

         

    `uvm_info(get_name(), "Writing CSR_HOST_SCRATCHPAD...", UVM_LOW)
			
	   	
	addr = `PF4_BAR0+'h0100+'h4;
          wdata = 64'hdeadbeefdeadbeef;
	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
       	if(rdata[31:0] == wdata[63:32])
            	 `uvm_info(get_name(), $psprintf("  CSR_HOST_SCRATCHPAD match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
          	 `uvm_error(get_name(), $psprintf(" CSR_HOST_SCRATCHAPD Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting  CSR_HOST_SCRATCHPAD_seq...", UVM_LOW)



    

	`uvm_info(get_name(), "Entering CSR_CE2HOST_STATUS CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0130;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf("CSR_CE2HOST_STATUS Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_CE2HOST_STATUS Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting  CSR_CE2HOST_STATUS_seq...", UVM_LOW)
	
    `uvm_info(get_name(), "Entering CSR_CE2HOST_STATUS CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0130;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf("CSR_CE2HOST_STATUS Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_CE2HOST_STATUS Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting  CSR_CE2HOST_STATUS_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Entering CSR_CE2HOST_STATUS CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0130+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf("CSR_CE2HOST_STATUS Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_CE2HOST_STATUS Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting  CSR_CE2HOST_STATUS_seq...", UVM_LOW)



    `uvm_info(get_name(), "Entering read CSR_HOST2CE_MRD_START CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0128;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data match 64!Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2CE_MRD_START_seq...", UVM_LOW)



     `uvm_info(get_name(), "Entering read CSR_HOST2CE_MRD_START CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0128;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2CE_MRD_START_seq...", UVM_LOW)



	`uvm_info(get_name(), "Entering read CSR_HOST2CE_MRD_START CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0128+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2CE_MRD_START_seq...", UVM_LOW)


  `uvm_info(get_name(), "Entering read CSR_SRC_ADDR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0110;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_SRC_ADDR  match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_SRC_ADDR  Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting read CSR_SRC_ADDR_seq...", UVM_LOW)

	  `uvm_info(get_name(), "Entering read CSR_SRC_ADDR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0110;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_SRC_ADDR  match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_SRC_ADDR  Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_SRC_ADDR_seq...", UVM_LOW)


         `uvm_info(get_name(), "Entering read CSR_SRC_ADDR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0110+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_SRC_ADDR  match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_SRC_ADDR  Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_SRC_ADDR_seq...", UVM_LOW)

	`uvm_info(get_name(), "Writing CSR_SRC_ADDR CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0110;
                mask = 64'h00000000deadbeef;

                wdata = 64'hdeadbeefdeadbeef & mask;

             	mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf("  CSR_SRC_ADDR match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_SRC_ADDR Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	 `uvm_info(get_name(), "  Exiting  CSR_SRC_ADDR_seq...", UVM_LOW)


	 `uvm_info(get_name(), "Writing   CSR_SRC_ADDR CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0110;
                mask = 64'h00000000deadbeef;

                wdata = 64'hdeadbeefdeadbeef & mask;

             	mmio_write32(.addr_(addr), .data_(wdata));
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == wdata[31:0])
            	 `uvm_info(get_name(), $psprintf("  CSR_SRC_ADDR match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_SRC_ADDR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	 `uvm_info(get_name(), "  Exiting  CSR_SRC_ADDR_seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering read  CSR_DST_ADDR  CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0118;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_DST_ADDR  match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_DST_ADDR   Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting read CSR_DST_ADDR_seq...", UVM_LOW)


     `uvm_info(get_name(), "Entering read  CSR_DST_ADDR  CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0118;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_DST_ADDR  match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_DST_ADDR   Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_DST_ADDR_seq...", UVM_LOW)


	 `uvm_info(get_name(), "Entering read  CSR_DST_ADDR  CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0118+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_DST_ADDR  match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_DST_ADDR   Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_DST_ADDR_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Writing CSR_DST_ADDR CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0118;
		mask = 64'h00000000deadbeef;
                wdata = 64'hdeadbeefdeadbeef & mask;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf("  CSR_DST_ADDR match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_DST_ADDR Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	 `uvm_info(get_name(), "  Exiting  CSR_DST_ADDR_seq...", UVM_LOW)


   `uvm_info(get_name(), "Entering   CSR_DST_ADDR CSR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0118;
		wdata = 64'h000000001eadbeef;
              		mmio_write32(.addr_(addr), .data_(wdata));
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == wdata[31:0])
            	 `uvm_info(get_name(), $psprintf("  CSR_DST_ADDR match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_DST_ADDR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	 `uvm_info(get_name(), "  Exiting  CSR_DST_ADDR_seq...", UVM_LOW)


          `uvm_info(get_name(), "Entering read CSR_DATA_SIZE CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0120;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_DATA_SIZE  Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_DATA_SIZE Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting read  CSR_DATA_SIZE_seq...", UVM_LOW)


	 `uvm_info(get_name(), "Entering read CSR_DATA_SIZE CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0120;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_DATA_SIZE  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_DATA_SIZE Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read  CSR_DATA_SIZE_seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering read CSR_DATA_SIZE CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0120+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_DATA_SIZE  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_DATA_SIZE Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read  CSR_DATA_SIZE_seq...", UVM_LOW)

	
	`uvm_info(get_name(), "Writing CSR_DATA_SIZE Registers...", UVM_LOW)
		 
	addr = `PF4_BAR0+'h0120;

	mask = 64'h00000000deadbeef;
        wdata = 64'hdeadbeefdeadbeef & mask;
		
	mmio_write64(.addr_(addr), .data_(wdata));
	mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == wdata)
          `uvm_info(get_name(), $psprintf(" CSR_DATA_SIZE  Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
           else
           `uvm_error(get_name(), $psprintf(" CSR_DATA_SIZE Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	 `uvm_info(get_name(), "  Exiting CSR_DATA_SIZE_seq...", UVM_LOW)


	 `uvm_info(get_name(), "Writing CSR_DATA_SIZE Registers...", UVM_LOW)
			
	  addr = `PF4_BAR0+'h0120;

	mask = 64'h00000000deadbeef;
         wdata = 64'hdeadbeefdeadbeef & mask;
	
	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
       	if(rdata[31:0] == wdata[31:0])
           `uvm_info(get_name(), $psprintf(" CSR_DATA_SIZE  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
       	   else
            `uvm_error(get_name(), $psprintf(" CSR_DATA_SIZE Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	 `uvm_info(get_name(), "  Exiting CSR_DATA_SIZE_seq...", UVM_LOW)

 `uvm_info(get_name(), "Entering Write CSR_HOST2CE_MRD_START Registers...", UVM_LOW)
		
	   	
		addr = `PF4_BAR0+'h0128;
		mask = 64'h0000000000000001;
                wdata = 64'hdeadbeefdeadbeef & mask;
		mmio_write32(.addr_(addr), .data_(wdata));
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0]== wdata[31:0])
            	 `uvm_info(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

         	 `uvm_info(get_name(), " Exiting CSR_HOST2CE_MRD_START_seq...", UVM_LOW)


	
	 `uvm_info(get_name(), " Writing CSR_HOST2CE_MRD_START Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0128;
		mask = 64'h0000000000000001;
                wdata = 64'hdeadbeefdeadbeef & mask;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata== wdata)
            	 `uvm_info(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf("CSR_HOST2CE_MRD_START Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	 `uvm_info(get_name(), " Exiting CSR_HOST2CE_MRD_START_seq...", UVM_LOW)

      

	`uvm_info(get_name(), "Entering read CSR_HOST2HPS_IMG_XFR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0138;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2HPS_IMG_XFR_seq...", UVM_LOW)


     `uvm_info(get_name(), "Entering read CSR_HOST2HPS_IMG_XFR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0138;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2HPS_IMG_XFR_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Entering read CSR_HOST2HPS_IMG_XFR CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0138+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting read CSR_HOST2HPS_IMG_XFR_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Entering CSR_HOST2HPS_IMG_XFR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0138;
		mask = 64'h0000000000000001;
                wdata = 64'hdeadbeefdeadbeef & mask;
		mmio_write32(.addr_(addr), .data_(wdata));
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == wdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	 `uvm_info(get_name(), "  Exiting CSR_HOST2HPS_IMG_XFR_seq...", UVM_LOW)

       `uvm_info(get_name(), "Writing  CSR_HOST2HPS_IMG_XFR Registers...", UVM_LOW)
			
	   	
		addr = `PF4_BAR0+'h0138;
		mask = 64'h0000000000000001;
                wdata = 64'hdeadbeefdeadbeef & mask;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	 `uvm_info(get_name(), "  Exiting CSR_HOST2HPS_IMG_XFR_seq...", UVM_LOW)

	`uvm_info(get_name(), "Entering CSR_HPS2HOST_RSP_SHDW CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0140;		
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == expdata)
            	 `uvm_info(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDW match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDW Data mismatch 64 ! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata, rdata))

      	`uvm_info(get_name(), " Exiting CSR_HPS2HOST_RSP_SHDW_seq...", UVM_LOW)


	  `uvm_info(get_name(), "Entering CSR_HPS2HOST_RSP_SHDW CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0140;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDW match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDw Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting CSR_HPS2HOST_RSP_SHDW_seq...", UVM_LOW)

	`uvm_info(get_name(), "Entering CSR_HPS2HOST_RSP_SHDW CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0140+'h4;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[63:32])
            	 `uvm_info(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDW match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[63:32], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_HPS2HOST_RSP_SHDW Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[63:32], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting CSR_HPS2HOST_RSP_SHDW_seq...", UVM_LOW)


      `uvm_info(get_name(), "Entering read CSR_CE_SFTRST CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0148;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_CE_SFTRST match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE_SFTRST Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting read CSR_CE_SFTRST_seq...", UVM_LOW)

	 `uvm_info(get_name(), "Entering CSR_CE_SFTRST CSR Registers...", UVM_LOW)
			
	   	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h014c;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        	if(rdata[31:0] == expdata[31:0])
            	 `uvm_info(get_name(), $psprintf(" CSR_CE_SFTRST match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE_SFTRST Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting CSR_CE_SFTRST_seq...", UVM_LOW)

		`uvm_info(get_name(), "Writing  CSR_CE_SFTRST  CSR Registers...", UVM_LOW)
	   	
		addr = `PF4_BAR0+'h0148;
                wdata = 64'h1;
		mmio_write64(.addr_(addr), .data_(wdata));
		mmio_read64 (.addr_(addr), .data_(rdata));
 
        	if(rdata == wdata)
            	 `uvm_info(get_name(), $psprintf("  CSR_CE_SFTRST match 64 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata, rdata),UVM_LOW)
        	   else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE_SFTRST Data mismatch 64! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata, rdata))

      	`uvm_info(get_name(), "  Exiting  CSR_CE_SFTRST_seq...", UVM_LOW)


	 `uvm_info(get_name(), "Writing  CSR_CE_SFTRST CSR Registers...", UVM_LOW)
	  	
	addr = `PF4_BAR0+'h0148;
         wdata = 64'h1;
	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == wdata[31:0])
           	 `uvm_info(get_name(), $psprintf("  CSR_CE_SFTRST match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
           else
            	 `uvm_error(get_name(), $psprintf(" CSR_CE_SFTRST Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting  CSR_CE_SFTRST_LIMIT...", UVM_LOW)
`ifdef n6000_10G
        #5us;	
`endif
`ifdef n6000_25G
        #5us;	
`endif
`ifdef n6000_100G
        #5us;	
`endif

	 `uvm_info(get_name(), "Entering CSR_HPS SCRATCHPAD CSR Registers...", UVM_LOW)
	  	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0150;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == expdata[31:0])
           `uvm_info(get_name(), $psprintf(" CSR_HPS SCRATCHPAD Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
           	 `uvm_error(get_name(), $psprintf(" CSR_HPS SCRATCHPAD Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting  CSR_HPS SCRATCHPAD_seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering CSR_HOST2HPS_IMG_XFR_SHDW CSR Registers...", UVM_LOW)

	  	expdata =64'h0000000000000000;

		addr = `PF4_BAR0+'h0154;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == expdata[31:0])
           `uvm_info(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR_SHDW Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
           	 `uvm_error(get_name(), $psprintf(" CSR_HOST2HPS_IMG_XFR_SHDW Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting  CSR_HOST2HPS_IMG_XFR_SHDW_seq...", UVM_LOW)


	`uvm_info(get_name(), "Entering CSR_HPS2HOST  CSR Registers...", UVM_LOW)

	  	expdata =64'h0000000000000000;
		addr = `PF4_BAR0+'h0158;		
		mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == expdata[31:0])
           `uvm_info(get_name(), $psprintf("CSR_HPS2HOST  Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, expdata[31:0], rdata[31:0]),UVM_LOW)
        	   else
           	 `uvm_error(get_name(), $psprintf(" CSR_HPS2HOST Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,expdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), " Exiting  CSR_HPS2HOST_seq...", UVM_LOW) 


        `uvm_info(get_name(), "Exiting  ce_csr_seq...", UVM_LOW)


    endtask : body
endclass :  ce_csr_seq

`endif //  CE_CSR_SEQ_SVH


