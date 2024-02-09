// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef MMIO_SEQ_SVH
`define MMIO_SEQ_SVH

class mmio_seq extends base_seq;
    `uvm_object_utils(mmio_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mmio_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr;
        bit [63:0] afu_id_l, afu_id_h;

        super.body();
        `uvm_info(get_name(), "Entering mmio_seq...", UVM_LOW)

        //Accessing Scratchpad Registers
        // FME DFH
        addr = `PF0_BAR0+'h00;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 FME Scratchpad Register %0h+'h28////", `PF0_BAR0), UVM_LOW)
        // FME Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h28;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h28+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
 
        // ST2MM DFH
        addr = `PF0_BAR0+'h4_0000;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 ST2MM Scratchpad Register %0h+'h4_0008////", `PF0_BAR0), UVM_LOW)
        // ST2MM Scratchpad - FULL64
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h4_0008;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // ST2MM Scratchpad - LOWER32 + UPPER32
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h4_0008+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr+'h4, wdata[31:0], rdata[31:0]))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata[31:0]), UVM_LOW)
        
       // PCIe DFH
        addr = `PF0_BAR0+'h1_0000;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 PCIE Scratchpad Register %0h+'h1_0008////", `PF0_BAR0), UVM_LOW)
        // PCIe Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h1_0008;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PCIe Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h1_0008+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // HSSI DFH
        addr = `PF0_BAR0+'h6_0000;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 HSSI Scratchpad Register %0h+'h6_0030////", `PF0_BAR0), UVM_LOW)
        // HSSI Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h6_0820;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // HSSI Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h6_0820+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF2 = HELB
        `uvm_info(get_name(), $psprintf("////Accessing PF2 HE-LB Scratchpad Register %0h+'h100////", `PF2_BAR0), UVM_LOW)

        addr = `PF2_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF2 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = `PF2_BAR0+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = `PF2_BAR0+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF3 = Virtio Loopback
        `uvm_info(get_name(), $psprintf("////Accessing PF3 Virtio Loopback Scratchpad Register %0h+'h100////", `PF3_BAR0), UVM_LOW)

        addr = `PF3_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF3 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = `PF3_BAR0+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = `PF3_BAR0+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

     
        // PF4 = HPS Copy Engine
        `uvm_info(get_name(), $psprintf("////Accessing PF4 HPS Copy Engine Scratchpad Register %0h+'h100////", `PF4_BAR0), UVM_LOW)

        addr = `PF4_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF4 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = `PF4_BAR0+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = `PF4_BAR0+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

 
        // PF2 VF0 = HE MEM
        `uvm_info(get_name(), $psprintf("////Accessing PF2 VF0 HE-MEM Scratchpad Register %0h+'h100////", `PF2_VF0_BAR0), UVM_LOW)

        addr = `PF2_VF0_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF2 VF0 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = `PF2_VF0_BAR0+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = `PF2_VF0_BAR0+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF2 VF1 = HE HSSI
        `uvm_info(get_name(), $psprintf("////Accessing PF2 VF1 HE-HSSI Scratchpad Register %0h+'h100////", `PF2_VF1_BAR0), UVM_LOW)

        addr = `PF2_VF1_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF2 VF1 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = `PF2_VF1_BAR0+'h48;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = `PF2_VF1_BAR0+'h48+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

       `uvm_info(get_name(), "Exiting mmio_seq...", UVM_LOW)
    endtask : body

endclass : mmio_seq

`endif // MMIO_SEQ_SVH
