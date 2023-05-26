// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef BASE_SEQ_SVH
`define BASE_SEQ_SVH

`include "tb_env.svh"
class base_seq extends uvm_sequence;
    `uvm_object_utils(base_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    `include "VIP/vip_task.sv"
    // index by start_addr, value is size of the mem block
    static int mem_pool[bit [63:0]];

    config_seq config_seq_;
    tb_env   tb_env0;

    function new(string name = "base_seq");
        super.new(name);
        get_tb_env();
    endfunction : new

    task body();
        super.body();
        config_seq_ = config_seq::type_id::create("config_seq_");
        config_seq_.start(p_sequencer);
    endtask : body

    // below utility tasks will be phased out when RAL is ready
   task mmio_write32(input bit [63:0] addr_, input bit [31:0] data_);
      mmio_pcie_write32(.addr_(addr_) , .data_(data_));       
   endtask : mmio_write32 

    task mmio_write64(input bit [63:0] addr_, input bit [63:0] data_);
      mmio_pcie_write64(.addr_(addr_) , .data_(data_));       
    endtask : mmio_write64

    task mmio_read32(input bit [63:0] addr_, output bit [31:0] data_);
          mmio_pcie_read32(.addr_(addr_) , .data_(data_));       
    endtask : mmio_read32

    task mmio_read64(input  bit [63:0] addr_, output bit [63:0] data_);
      mmio_pcie_read64(.addr_(addr_) , .data_(data_));       
    endtask : mmio_read64

 //Accessing Env handle
  virtual function void get_tb_env();                
        uvm_component   comp;

        comp = uvm_top.find("uvm_test_top.tb_env0"); 
        assert(comp) else uvm_report_fatal("ofs_fpga_ac_base_seq", "failed finding tb_env0"); 
        
        assert ($cast(tb_env0, comp)) else 
        uvm_report_fatal("ofs_fpga_ac_base_seq", "failed in obtaining tb_env0!");
    endfunction

// Allocate the memory and return the start address
    function bit [63:0] alloc_mem(int size, bit low32 = 0);
        bit [63:0] m_addr;
	std::randomize(m_addr) with {
	    m_addr[11:0] == 0;
	    if(low32) {
	        m_addr[63:32] == 32'h0;
	    }
	    foreach(mem_pool[i]) {
	        !(m_addr inside {[i:i+'h40*mem_pool[i]]}); 
	    }
	    (m_addr + 'h40*size) < 64'hffff_ffff_ffff_ffff;
	};
	mem_pool[m_addr] = size;
        return m_addr;
    endfunction : alloc_mem

    // De-allocate the memory with start address and size of the memory
    function void dealloc_mem(bit [63:0] start_addr);
        mem_pool.delete(start_addr);
    endfunction : dealloc_mem





endclass : base_seq

`endif // BASE_SEQ_SVH
