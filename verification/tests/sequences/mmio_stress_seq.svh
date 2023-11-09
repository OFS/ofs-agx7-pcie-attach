//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 *
 * class mmio_stress_seq is executed by mmio_stress_test
 * The sequence perfoms write/read using mmio_write64 and mmio_read64_blocking task which in defined base_sequence
 * Scratchpad is accessed simultaneosly to generate the stress                               
 **/
//===============================================================================================================

`ifndef MMIO_STRESS_SEQ_SVH
`define MMIO_STRESS_SEQ_SVH

class mmio_stress_seq extends base_seq;
    `uvm_object_utils(mmio_stress_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand int loop;

    constraint loop_c { soft loop inside {[10:20]}; }

    function new(string name = "mmio_stress_seq");
        super.new(name);
    endfunction : new

    task mmio_wr_rd_cmp(input [63:0] addr);
        int iter;
	bit [63:0] wdata, rdata, exp_data;

	std::randomize(iter) with {iter inside {[1:10]}; };
	for(int i = 0; i < iter; i++) begin
            std::randomize(wdata);
            mmio_write64(.addr_(addr), .data_(wdata));
	    exp_data = wdata;
	end

	std::randomize(iter) with {iter inside {[1:10]}; };
	for(int i = 0; i < iter; i++) begin
            mmio_read64_blocking (.addr_(addr), .data_(rdata));
            if(rdata !== exp_data)
                `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, exp_data, rdata))
            else
                `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
	end
    endtask : mmio_wr_rd_cmp

    task body();
    bit [63:0] wdata, rdata, addr;
        super.body();
        `uvm_info(get_name(), "Entering mmio_stress_seq...", UVM_LOW)

	this.randomize();

        fork
	    begin // FME Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR +'h28;
		  mmio_wr_rd_cmp(.addr(addr));
          	end
	    end
	    begin // HE-LPBK Scratchpad
	        for(int i = 0; i < loop; i++) begin
                 addr = tb_cfg0.PF2_BAR0+ HE_LB_BASE_ADDR +'h100;
		 mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin // HE-MEM Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_VF0_BAR0+HE_MEM_BASE_ADDR +'h100;
		  mmio_wr_rd_cmp(.addr(addr));
	        end
            end
           `ifndef INCLUDE_CVL
	    begin // HE-HSSI Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+'h48;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
            `endif 
	    begin  //Virtio Loopback Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF3_BAR0+VIRTIO_LB_BASE_ADDR+'h18;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin // PCIe Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_BAR0+PCIE_BASE_ADDR+'h0_0008;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin // HSSI Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h820;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin // ST2MM Scratchpad
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_BAR0+ ST2MM_BASE_ADDR +'h0_0008;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin  //HPS-Copy Engine Scratchpad register
        `ifdef INCLUDE_HPS
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF4_BAR0+'h100;
		  mmio_wr_rd_cmp(.addr(addr));
		end
        `endif
	    end
	    begin  //PR-Gasket Scratchpad register
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_BAR0+ PORT_GASKET_BASE_ADDR +'h000b8;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	    end
	    begin  //MEM-TG Scratchpad register
	    
	    `ifdef INCLUDE_MEM_TG
             `ifdef INCLUDE_DDR4
	        for(int i = 0; i < loop; i++) begin
                  addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR +'h0028;
		  mmio_wr_rd_cmp(.addr(addr));
		end
	      `endif
             `endif
	    end

	join

        `uvm_info(get_name(), "Exiting mmio_stress_seq...", UVM_LOW)
    endtask : body

endclass : mmio_stress_seq

`endif // MMIO_STRESS_SEQ_SVH
