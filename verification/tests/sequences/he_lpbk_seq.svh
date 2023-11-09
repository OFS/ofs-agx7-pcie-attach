//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class he_lpbk_seq is executed by he_lpbk_test
* 
* This sequence verifies its constraints num_lines ,req_len and mode   
* The sequence extends the base_seq 
* Sequence is running on virtual_sequencer 
*/
//=========================================================================================================
`ifndef HE_LPBK_SEQ_SVH
`define HE_LPBK_SEQ_SVH

class he_lpbk_seq extends base_seq;
    `uvm_object_utils(he_lpbk_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand bit [31:0] num_lines;
    rand bit [63:0] src_addr, dst_addr;
    rand bit [63:0] dsm_addr;
    rand bit [ 2:0] mode;
    rand bit [ 3:0] req_len;
    rand bit        src_addr_64bit, dst_addr_64bit, dsm_addr_64bit;
    rand bit        he_mem,ral_mode_prtcl;
    bit [63:0] base_addr,addr;
    rand bit        cont_mode;
    rand int        run_time_in_ms;
    bit [511:0]     dsm_data;
    rand bit        report_perf_data;
    rand bit [2:0]  tput_interleave;
    rand int cont_mode_dly;
    rand bit en_msix_chk;
    rand int        num_of_user_intr;

    rand bit[63:0] intr_addr, intr_wr_data, msix_addr_reg, msix_ctldat_reg;
    bit[63:0] msix_base;
    int timeout;
    rand bit [1:0] intr_id;
    bit msix_req_set;
    rand bit [31:0] rand_data [16];
    rand bit [31:0] host_dsm_rdata [16];
    rand bit [63:0] dut_mem_start;
    rand bit [63:0] dut_mem_end;

    constraint num_lines_c {
        if(en_msix_chk) num_lines inside {[1:10]};
        else num_lines inside {[1:1024]};

	if(mode != 3'b011) {
	    (num_lines % (2**req_len)) == 0;
	    (num_lines / (2**req_len)) >  0;
	}
	else {
	    num_lines % 2 == 0;
	    ((num_lines/2) % ((2**req_len) * (2**tput_interleave))) == 0;
	    ((num_lines/2) / ((2**req_len) * (2**tput_interleave))) >  0;
	}
	solve mode before num_lines;
	solve req_len before num_lines;
	solve tput_interleave before num_lines;
    }

    constraint req_len_c {
	req_len <= 4;
    }

    constraint tput_interleave_c {
        tput_interleave inside {3'b000, 3'b001, 3'b010};
        }  
    constraint en_msix_chk_c { soft en_msix_chk == 0; } // By default msix testing will be disable
    constraint mode_c { soft mode == 3'b000; } // LPBK1
    constraint he_mem_c { soft he_mem == 0; }
    constraint ral_mode { soft ral_mode_prtcl == 0; }
   
    constraint cont_mode_c {
        soft cont_mode == 0;
    }

    constraint cont_mode_dly_c {soft cont_mode_dly == 18000;}

    constraint run_time_in_ms_c {
        run_time_in_ms inside {[1:5]};
    }

    constraint report_perf_data_c {
        soft report_perf_data == 0;
    }

    constraint intr_addr_cons {
    dut_mem_end > dut_mem_start;
    intr_addr[7:0] == 0;
    intr_addr   >= dut_mem_start;
    intr_addr    < dut_mem_end;
    intr_addr[63:32] == 32'b0;
    }
      
    constraint intr_wr_data_cons{
       !(intr_wr_data inside {64'h0});
        intr_wr_data[63:32] == 32'b0; 
    }
    
    constraint msix_addr_reg_cons {
        msix_addr_reg inside {20'h0_3000, 20'h0_3010, 20'h0_3020, 20'h0_3030};
    }
    
    constraint msix_ctldat_reg_cons {
       solve msix_addr_reg before msix_ctldat_reg;
       (msix_addr_reg == 20'h3000) -> {msix_ctldat_reg inside {20'h3008};}
       (msix_addr_reg == 20'h3010) -> {msix_ctldat_reg inside {20'h3018};}
       (msix_addr_reg == 20'h3020) -> {msix_ctldat_reg inside {20'h3028};}
       (msix_addr_reg == 20'h3030) -> {msix_ctldat_reg inside {20'h3038};}
    } 
    
    constraint intr_id_cons {
        solve msix_addr_reg before intr_id;
        (msix_addr_reg == 20'h3000) -> {intr_id inside {2'b00};}
        (msix_addr_reg == 20'h3010) -> {intr_id inside {2'b01};}
        (msix_addr_reg == 20'h3020) -> {intr_id inside {2'b10};}
        (msix_addr_reg == 20'h3030) -> {intr_id inside {2'b11};}
    } 
    
    constraint num_of_user_intr_c { soft num_of_user_intr == 1; }


    function new(string name = "he_lpbk_seq");
        super.new(name);
    endfunction : new

    task body();
	bit [63:0]                  wdata, rdata;
	bit [63:0]                  dsm_addr_tmp;	
	bit [511:0]                 src_data[], dst_data[];
    uvm_reg_data_t ctl_data;
    uvm_status_e       status;
        bit [31:0] host_rdata [16];
        bit [63:0] host_addr;

        super.body();
         `ifdef INCLUDE_DDR4                             
        addr  = tb_cfg0.PF0_BAR0;
	  	rdata = '0;
	  	while(rdata[11:0] != 12'h9) begin
	  		addr = addr + rdata[39:16];
	  		mmio_read64(.addr_(addr), .data_(rdata));
	  	end
	  	addr = addr + 'h8;
		
        mmio_read64 (.addr_(addr), .data_(rdata));
		`uvm_info(get_name(), $psprintf("EMIF_STATUS  data Addr= %0h, Act = %0h", addr, rdata),UVM_LOW)
       		while(rdata[0]==0)
		begin
		mmio_read64 (.addr_(addr), .data_(rdata));
		`uvm_info(get_name(), $psprintf("EMIF_STATUS  data Addr= %0h, Act = %0h", addr, rdata),UVM_LOW)
		#50us;
		end
	`endif
	`uvm_info(get_name(), "Entering he_lpbk_seq...", UVM_LOW)

	if(he_mem) base_addr = tb_cfg0.HE_MEM_BASE;
	else       base_addr = tb_cfg0.HE_LB_BASE;

	if(he_mem) msix_base = tb_cfg0.PF0_VF0_BAR4;
	else       msix_base = tb_cfg0.PF2_BAR4;

	src_addr = alloc_mem(num_lines, !src_addr_64bit);
	dst_addr = alloc_mem(num_lines, !dst_addr_64bit);
	dsm_addr = alloc_mem(1, !dsm_addr_64bit);

	//this.randomize();
	`uvm_info(get_name(), $psprintf("he_mem = %0d, en_msix_chk=%0d msix_base=%0h src_addr = %0h, dst_addr = %0h, dsm_addr = %0h. num_lines = %0d, req_len = %0h, mode = %0b, cont_mode = %0d, intlv = %0b", he_mem, en_msix_chk, msix_base, src_addr, dst_addr, dsm_addr, num_lines, req_len, mode, cont_mode, tput_interleave), UVM_LOW)
	src_data = new[num_lines];
	dst_data = new[num_lines];

	// Prepare source data in host memory
	for(int i = 0; i < num_lines; i++) begin
            //std::randomize(rand_data);
            foreach(rand_data[j]) begin  rand_data[j] = $urandom();
	    `uvm_info(get_name(), $psprintf("RAND_DATA[%d] :- %h \n",j,rand_data[j]), UVM_LOW)end
                                  
           host_mem_write( .addr_(src_addr+'h40*i) , .data_(rand_data) , .len('d16) );
	end

        // initialize DSM data
        foreach(rand_data[i]) rand_data[i] = 32'h0;
        host_mem_write( .addr_(dsm_addr) , .data_(rand_data) , .len('d16) );

        // Program CSR_CTL to reset HE-LPBK
	wdata = 64'h0;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

        // Program CSR_CTL to remove reset HE-LPBK
	wdata = 64'h1;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

	// Program CSR_SRC_ADDR
        mmio_write64(.addr_(base_addr+'h120), .data_(src_addr>>6));
        mmio_read64 (.addr_(base_addr+'h120), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_SRC_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_DST_ADDR
        mmio_write64(.addr_(base_addr+'h128), .data_(dst_addr>>6));
        mmio_read64 (.addr_(base_addr+'h128), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_DST_ADDR = %0h", rdata), UVM_LOW)

	dsm_addr_tmp = dsm_addr >> 6;
	// Program CSR_AFU_DSM_BASEH
        mmio_write32(.addr_(base_addr+'h114), .data_(dsm_addr_tmp[63:32]));
        mmio_read32 (.addr_(base_addr+'h114), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("DSM_H_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_AFU_DSM_BASEL
        mmio_write32(.addr_(base_addr+'h110), .data_(dsm_addr_tmp[31:0]));
        mmio_read32 (.addr_(base_addr+'h110), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("DSM_L_ADDR = %0h", rdata), UVM_LOW)

	// Program CSR_NUM_LINES
        mmio_write64(.addr_(base_addr+'h130), .data_(num_lines-1));
        mmio_read64 (.addr_(base_addr+'h130), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_NUM_LINES = %0h", rdata), UVM_LOW)

	// Program CSR_CFG
	wdata = {32'h0, req_len[3:2], 7'h0, tput_interleave, 13'h0, req_len[1:0], mode, cont_mode, 1'b0};
        mmio_write64(.addr_(base_addr+'h140), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h140), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CFG = %0h", rdata), UVM_LOW)

        if(en_msix_chk) config_he_user_intr();

        // Program CSR_CTL to start HE-LPBK
	wdata = 64'h3;
        mmio_write64(.addr_(base_addr+'h138), .data_(wdata));
        mmio_read64 (.addr_(base_addr+'h138), .data_(rdata));	
	`uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)

        
	if(cont_mode) begin
	    #(cont_mode_dly*1ns);
	    rdata[2] = 1;
            mmio_write64(.addr_(base_addr+'h138), .data_(rdata));
	    `uvm_info(get_name(), $psprintf("CSR_CTL = %0h", rdata), UVM_LOW)
	end

    if(ral_mode_prtcl == 0) begin
        `ifdef COV 
            if(he_mem) begin
                tb_env0.mem_regs.CFG.read(status,rdata);
                tb_env0.mem_regs.CFG.cg_vals.sample();
                end
            else  begin
                tb_env0.he_lpbk_regs.CFG.read(status,rdata);
                tb_env0.he_lpbk_regs.CFG.cg_vals.sample();
                end
        `endif
        `ifdef COV 
            if(he_mem) begin
                tb_env0.mem_regs.STATUS0.read(status,rdata);
                tb_env0.mem_regs.STATUS0.cg_vals.sample();
                end
            else  begin
                tb_env0.he_lpbk_regs.STATUS0.read(status,rdata);
                tb_env0.he_lpbk_regs.STATUS0.cg_vals.sample();
                end
        `endif
            
        `ifdef COV 
            if(he_mem) begin
                tb_env0.mem_regs.STATUS1.read(status,rdata);
                tb_env0.mem_regs.STATUS1.cg_vals.sample();
                end
            else begin
                tb_env0.he_lpbk_regs.STATUS1.read(status,rdata);
                tb_env0.he_lpbk_regs.STATUS1.cg_vals.sample();
                end
        `endif
    end

	if(en_msix_chk) 
	    check_he_user_intr();

        rdata = 0;
	// Polling DSM
	fork
	    while(!dsm_data[0]) begin
               foreach (host_dsm_rdata[i]) host_dsm_rdata[i] = 32'h0;
		`uvm_info(get_name(), $psprintf("INSIDE WHILE WILL START HOST_RDATA"), UVM_LOW)
               host_mem_read( .addr_(dsm_addr) , .data_(host_dsm_rdata) , .len('d16) ); 
	        foreach(host_dsm_rdata[i])
	            dsm_data |= changeEndian(host_dsm_rdata[i]) << (i*32);
		`uvm_info(get_name(), $psprintf("Polling DSM status Addr = %0h Data = %h", dsm_addr, dsm_data), UVM_LOW)
	 	#1us;
	    end
	    #1.5ms; // Changing from 50us to 1.5ms for HE_MEM tests.
	join_any
	if(!dsm_data[0])
	    `uvm_fatal(get_name(), $psprintf("TIMEOUT! polling dsm_addr = %0h!", dsm_addr))

        if(mode == 3'b000) begin
	    // Compare data
	    for(int i = 0; i < num_lines; i++) begin
               host_addr = src_addr + 'h40*i;

               host_mem_read( .addr_(host_addr) , .data_(host_rdata) , .len('d16) ); 
	        foreach(host_rdata[j])
	            src_data[i] |= changeEndian(host_rdata[j]) << (j*32);
	        `uvm_info(get_name(), $psprintf("addr = %0h src_data = %0h", host_addr, src_data[i]), UVM_LOW)
	    end

	    for(int i = 0; i < num_lines; i++) begin               
               host_addr = dst_addr + 'h40*i;
               host_mem_read( .addr_(host_addr) , .data_(host_rdata) , .len('d16) ); 

	        foreach(host_rdata[j])
	            dst_data[i] |= changeEndian(host_rdata[j]) << (j*32);
	        `uvm_info(get_name(), $psprintf("addr = %0h dst_data = %0h", host_addr, dst_data[i]), UVM_LOW)
	    end

	    foreach(src_data[i]) begin
	        if(src_data[i] !== dst_data[i])
	            `uvm_error(get_name(), $psprintf("Data mismatch! src_data[%0d] = %0h dst_data[%0d] = %0h", i, src_data[i], i, dst_data[i]))
	        else
	            `uvm_info(get_name(), $psprintf("Data match! data[%0d] = %0h", i, src_data[i]), UVM_LOW)
	    end
	end

        if(!cont_mode)
            check_counter();

        if(report_perf_data) begin
	    if(mode inside {3'b001, 3'b010, 3'b011})
	        report_perf();
	end

 	`uvm_info(get_name(), "Exiting he_lpbk_seq...", UVM_LOW)
    endtask : body

    task check_counter();
        bit [63:0] rdata;
        bit interrupt_enabled;
        interrupt_enabled ='b0;
        mmio_read64 (.addr_(base_addr+'h140), .data_(rdata));
        interrupt_enabled=rdata[29];
        mmio_read64 (.addr_(base_addr+'h160), .data_(rdata));	
     if (he_mem) begin
            `ifdef INCLUDE_DDR4
       if(mode == 3'b000) begin // LPBK {
        if(!(interrupt_enabled)) // { 
          begin
	       if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
          end
       else
         begin
	          if((rdata[31:0]-2) != num_lines) // For interrupt scenarios, interrupt command is also counted as write, hence subtracting interrupt request. Refer HSD for further reference : https://hsdes.intel.com/appstore/art			icle/#/16018197141
	          `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
         end//}
	       	  if(rdata[63:32] != num_lines)
	          `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end//}
       else if(mode == 3'b010) begin // WRITE ONLY {
        	if(!(interrupt_enabled)) // { 
        	 begin
	       	  if((rdata[31:0]) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
	         end //}
               else //{
        	begin
	         if((rdata[31:0]) != num_lines)//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        	end //}
       end //}
       else if(mode == 3'b001) begin // READ ONLY
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
       end
       else if(mode == 3'b011) begin // THRUPUT {
       		if(!(interrupt_enabled)) // { 
                  begin
	            if((rdata[31:0]) != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines/2))
                  end
               else 
                 begin
	       	   if((rdata[31:0]-2) != (num_lines/2))//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
                 end //}
	       if(rdata[63:32] != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines/2))
	end//}
         
      `else
	   if(mode == 3'b000) begin // LPBK {
        if(!(interrupt_enabled)) // { 
          begin
	       if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
          end
       else
         begin
	          if((rdata[31:0]-2) != num_lines) // For interrupt scenarios, interrupt command is also counted as write, hence subtracting interrupt request. Refer HSD for further reference : https://hsdes.intel.com/appstore/art			icle/#/16018197141
	          `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
         end//}
	       	  if(rdata[63:32] != num_lines)
	          `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end//}
       else if(mode == 3'b010) begin // WRITE ONLY {
        	if(!(interrupt_enabled)) // { 
        	 begin
	       	  if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
	         end //}
               else //{
        	begin
	         if((rdata[31:0]-2) != num_lines)//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        	end //}
       end //}
       else if(mode == 3'b001) begin // READ ONLY
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
       end
       else if(mode == 3'b011) begin // THRUPUT {
       		if(!(interrupt_enabled)) // { 
                  begin
	            if((rdata[31:0]-1) != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines/2))
                  end
               else 
                 begin
	       	   if((rdata[31:0]-2) != (num_lines/2))//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
                 end //}
	       if(rdata[63:32] != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines/2))
	end//}
            `endif
        end //he-mem end

        else begin //he_lpbk
	   if(mode == 3'b000) begin // LPBK {
        if(!(interrupt_enabled)) // { 
          begin
	       if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
          end
       else
         begin
	          if((rdata[31:0]-2) != num_lines) // For interrupt scenarios, interrupt command is also counted as write, hence subtracting interrupt request. Refer HSD for further reference : https://hsdes.intel.com/appstore/art			icle/#/16018197141
	          `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
         end//}
	       	  if(rdata[63:32] != num_lines)
	          `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
	   end//}
       else if(mode == 3'b010) begin // WRITE ONLY {
        	if(!(interrupt_enabled)) // { 
        	 begin
	       	  if((rdata[31:0]-1) != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines))
	         end //}
               else //{
        	begin
	         if((rdata[31:0]-2) != num_lines)//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
        	end //}
       end //}
       else if(mode == 3'b001) begin // READ ONLY
	       if(rdata[63:32] != num_lines)
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines))
       end
       else if(mode == 3'b011) begin // THRUPUT {
       		if(!(interrupt_enabled)) // { 
                  begin
	            if((rdata[31:0]-1) != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-1, num_lines/2))
                  end
               else 
                 begin
	       	   if((rdata[31:0]-2) != (num_lines/2))//Refer HSD for further reference : https://hsdes.intel.com/appstore/article/#/1601819714
	           `uvm_error(get_name(), $psprintf("Stats counter for numWrites doesn't match num_lines! numWrites = %0h, num_lines = %0h", rdata[31:0]-2, num_lines))
                 end //}
	       if(rdata[63:32] != (num_lines/2))
	           `uvm_error(get_name(), $psprintf("Stats counter for numReads doesn't match num_lines! numReads = %0h, num_lines = %0h", rdata[63:32], num_lines/2))
	end//}
        end //he_lpbk
    endtask : check_counter

    task report_perf();
        real num_ticks;
	real perf_data;
    `ifdef  FIM_C
	    num_ticks = dsm_data[103:64];
        perf_data = (num_lines * 64) / (2.5 * num_ticks);
     `else
     	num_ticks = dsm_data[103:64];
        perf_data = (num_lines * 64) / (2.8 * num_ticks);
     `endif
	$display("DSM data = %0h", dsm_data);
	$display("*** PERFORMANCE MEASUREMENT *** ", $psprintf("num_lines = %0d req_len = 0x%0h num_ticks = 0x%0h perf_data = %.4f GB/s", num_lines, req_len, num_ticks, perf_data));
    endtask : report_perf

    virtual task config_he_user_intr();
        bit [63:0] wdata, rdata, addr, intr_masked_data;
	uvm_status_e status;

        `uvm_info(get_name(), $psprintf("TEST: Configure MSIX Table BAR4 MSIX_ADDR/MSIX_CTLDAT"), UVM_LOW)
        `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE to MSIX_ADDR=%0h data=%0h",(msix_base+msix_addr_reg),intr_addr), UVM_LOW)
        mmio_write64(.addr_(msix_base+msix_addr_reg), .data_(intr_addr));
        #1us;

        intr_masked_data[31:0] = intr_wr_data[31:0];
        intr_masked_data[63:32] = 32'b1; 
        `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE with masked Interrupt - MSIX_CTLDAT=%0h intr_data=%0h intr_masked_data=%0h ",(msix_base+msix_ctldat_reg),intr_wr_data,intr_masked_data), UVM_LOW)
        mmio_write64(.addr_(msix_base+msix_ctldat_reg), .data_(intr_masked_data));

        #25us;
 
        `uvm_info(get_name(), $psprintf("TEST: Initiate User interrupt request for ID=%0d",intr_id), UVM_LOW)
	if(he_mem)begin
  	  tb_env0.mem_regs.CTL.write(status, 1);	
  	  tb_env0.mem_regs.INTERRUPT0.read(status, rdata[31:0]);
  	  rdata[31:16] = intr_id; // Interrupt vector 0..3
  	  tb_env0.mem_regs.INTERRUPT0.write(status, rdata[31:0]);
  	  tb_env0.mem_regs.CFG.read(status, rdata);
  	  rdata[29] = 1;
  	  tb_env0.mem_regs.CFG.write(status, rdata);
        end
	else begin
  	  tb_env0.he_lpbk_regs.CTL.write(status, 1);	
  	  tb_env0.he_lpbk_regs.INTERRUPT0.read(status, rdata[31:0]);
  	  rdata[31:16] = intr_id; // Interrupt vector 0..3
  	  tb_env0.he_lpbk_regs.INTERRUPT0.write(status, rdata[31:0]);
  	  tb_env0.he_lpbk_regs.CFG.read(status, rdata);
  	  rdata[29] = 1;
  	  tb_env0.he_lpbk_regs.CFG.write(status, rdata);
        end
    endtask

    virtual task check_he_user_intr();
        bit [63:0] wdata, rdata, addr, intr_masked_data;
        bit [31:0] host_intr_rdata [16];
        bit msix_req_set;
	uvm_status_e status;

        `uvm_info(get_name(), $psprintf("TEST: Check MSIX_PBA[%0d] is set for masked User interrupt",intr_id), UVM_LOW)
        for(int i=0;i<200;i++) begin
          mmio_read64(.addr_(msix_base+20'h0_3070),.data_(rdata));
          if(rdata[intr_id]) break;
          #1ns;
        end
        assert(rdata[intr_id]) else 
          `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[%0d] not set post masked interrupt",intr_id))

        `uvm_info(get_name(), $psprintf("TEST: Unmask User interrupt by writing on MSIX_CTLDAT[63:32]"), UVM_LOW)
        mmio_write64(.addr_(msix_base+msix_ctldat_reg), .data_(intr_wr_data));

        #1us;
        `uvm_info(get_name(), $psprintf("TEST: Check MSIX_PBA[%0d] is clear after asserting pending User interrupt",intr_id), UVM_LOW)
        mmio_read64(.addr_(msix_base+20'h0_3070),.data_(rdata));
        assert(rdata[intr_id]==0) else 
          `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[%0d] is not clear after asserting pending User interrupt",intr_id));

        for(int i=0;i<20;i++)begin
          #25us;
          `uvm_info(get_name(), $psprintf("TEST: HOST READ Loop Iteration %0d",i), UVM_LOW)
          `uvm_info(get_name(), $psprintf("TEST: Read Host memory"), UVM_LOW)
          host_mem_read( .addr_(intr_addr) , .data_(host_intr_rdata) , .len('d16) ); 
          if(changeEndian(host_intr_rdata[0]) !== intr_wr_data)
              `uvm_error(get_name(), $psprintf("Interrupt write data mismatch exp = %0h act = %0h", intr_wr_data, changeEndian(host_intr_rdata[0])))
          else begin
              `uvm_info(get_name(), $psprintf("TEST: Interrupt data match intr_addr=%0h intr_wr_data = %0h", intr_addr, intr_wr_data), UVM_LOW)
              break;
          end
        end
        msix_req_set = 0;
        #1us;
    endtask
endclass : he_lpbk_seq

`endif // HE_LPBK_SEQ_SVH
