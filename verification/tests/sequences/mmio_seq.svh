//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
* Abstract:
* class mmio_seq is executed by mmio_test
* 
* This sequence uses the RAL model  for front-door access of registers 
* The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequnce
* Sequence is running on virtual_sequencer .
**/
//===============================================================================================================
//`ifndef MMIO_SEQ_SVH
//`define MMIO_SEQ_SVH

class mmio_seq extends base_seq;
    `uvm_object_utils(mmio_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "mmio_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr,rw_bits,default_value;
        bit [63:0] afu_id_l, afu_id_h;
        uvm_status_e       status;


        super.body();
        `uvm_info(get_name(), "Entering mmio_seq...", UVM_LOW)

        // AFU_INTF_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 AFU_INTF_DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+PROTOCOL_CHECKER_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));

        // AFU_INTF_Scratchpad 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0 AFU_INTF_Scratchpad Register %0h+'h80008////", tb_cfg0.PF0_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+PROTOCOL_CHECKER_BASE_ADDR+'h8;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PMCI_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 PMCI_DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ PMCI_BASE_ADDR;    
        mmio_read64 (.addr_(addr), .data_(rdata));


        // EMIF_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 EMIF_DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+EMIF_BASE_ADDR;       
        mmio_read64 (.addr_(addr), .data_(rdata));

       `ifdef INCLUDE_MEM_TG
        `ifdef INCLUDE_DDR4

         // MEM_TG_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0_VF2 MEM_TG_DFH Register ////", tb_cfg0.PF0_VF2_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR;
        mmio_read64 (.addr_(addr), .data_(rdata));

        // MEM_TG_Scratchpad 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0_VF2 MEM_TG_Scratchpad Register %0h+'h61008////", tb_cfg0.PF0_VF2_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR+'h28;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // MEM_TG_Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR+'h0028+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 
          
        `endif   
      `endif

         // QSFP0_CTRL_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 QSFP0_CTRL_DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP0_BASE_ADDR;
        mmio_read64 (.addr_(addr), .data_(rdata));

        // QSFP0_Scratchpad 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0 QSFP0_Scratchpad Register %0h+'h12030////", tb_cfg0.PF0_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+ QSFP0_BASE_ADDR+'h30;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

          

         // QSFP1_CTRL_DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 QSFP1_CTRL_DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR;
        mmio_read64 (.addr_(addr), .data_(rdata));

        // QSFP1_Scratchpad 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0 QSFP1_Scratchpad Register %0h+'h13030////", tb_cfg0.PF0_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+ QSFP1_BASE_ADDR+'h30;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME DFH
        `uvm_info(get_name(), $psprintf("////Accessing PF0 FME DFH Register ////", tb_cfg0.PF0_BAR0), UVM_LOW)
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));

        // FME Scratchpad 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0 FME Scratchpad Register %0h+'h28////", tb_cfg0.PF0_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR+'h28;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR+'h28+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
 
        // ST2MM DFH
        addr = tb_cfg0.PF0_BAR0+ST2MM_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        tb_env0.st2mm_regs.ST2MM_DFH.read(status,rdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_DFH.cg_vals.sample();`endif

      //==================================================
     // Write and Read 'hFFFFFFFF_FFFFFFFF to ST2MM_SCRATCHPAD
     //==================================================
     wdata='hFFFFFFFF_FFFFFFFF ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&default_value)|rw_bits ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","ST2MM_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "ST2MM_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","ST2MM_SCRATCHPAD",wdata, rdata), UVM_LOW)


     //==================================================
     // Write and Read 'hAAAAAAAA_AAAAAAAA to ST2MM_SCRATCHPAD
     //==================================================
     wdata='hAAAAAAAA_AAAAAAAA ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata&rw_bits)|default_value;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","ST2MM_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "ST2MM_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","ST2MM_SCRATCHPAD",wdata, rdata), UVM_LOW)


     //==================================================
     // Write and Read 'h00000000_00000000 to ST2MM_SCRATCHPAD
     //==================================================
     wdata='h00000000_00000000 ;
     default_value=64'h0000000000000000 ;
     rw_bits = 'hFFFFFFFFFFFFFFFF ;
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.write(status,wdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.read(status,rdata);
      `ifdef COV tb_env0.st2mm_regs.ST2MM_SCRATCHPAD.cg_vals.sample();`endif
     wdata=(wdata|default_value)&(~rw_bits) ;
     `uvm_info(get_name(), $psprintf("Register = %0s, data = %0h rw_bits_data = %h","ST2MM_SCRATCHPAD",wdata , rw_bits), UVM_LOW)
     if(rdata !== wdata )
      `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "ST2MM_SCRATCHPAD",wdata, rdata))
     else
      `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, wdata = %0h rdata = %0h","ST2MM_SCRATCHPAD",wdata, rdata), UVM_LOW)



        // ST2MM Scratchpad - FULL64
        `uvm_info(get_name(), $psprintf("////Accessing PF0 ST2MM Scratchpad Register %0h+'h4_0008////", tb_cfg0.PF0_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+ST2MM_BASE_ADDR+'h0_0008;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // ST2MM Scratchpad - LOWER32 + UPPER32
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+ST2MM_BASE_ADDR+'h0_0008+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata[31:0]), UVM_LOW)
        
       // PCIe DFH
        addr = tb_cfg0.PF0_BAR0+PCIE_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 PCIE Scratchpad Register %0h+'h1_0008////", tb_cfg0.PF0_BAR0), UVM_LOW)
        // PCIe Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+PCIE_BASE_ADDR+'h0_0008;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PCIe Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+PCIE_BASE_ADDR+'h0_0008+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // HSSI DFH
        addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        `uvm_info(get_name(), $psprintf("////Accessing PF0 HSSI Scratchpad Register %0h+'h6_0030////", tb_cfg0.PF0_BAR0), UVM_LOW)
        // HSSI Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h820;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // HSSI Scratchpad 32 bit access
        //assert(std::randomize(wdata));
        wdata = 64'hdeadbeefdeadbeef;
        addr = tb_cfg0.PF0_BAR0+HSSI_BASE_ADDR+'h820+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[63:32] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata[63:32], rdata[31:0]))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata[31:0]), UVM_LOW)

        // PF2 = HELB
       
        addr = tb_cfg0.PF2_BAR0+HE_LB_BASE_ADDR;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF2 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

         `uvm_info(get_name(), $psprintf("////Accessing PF2 HE-LB Scratchpad Register %0h+'h100////", tb_cfg0.PF2_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR0+HE_LB_BASE_ADDR+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR0+HE_LB_BASE_ADDR+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        `uvm_info(get_name(), $psprintf("////Accessing PF3 Virtio Loopback Scratchpad Register %0h+'h100////", tb_cfg0.PF3_BAR0), UVM_LOW)
        // PF3 = Virtio Loopback
        addr = tb_cfg0.PF3_BAR0+VIRTIO_LB_BASE_ADDR;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF3 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        assert(std::randomize(wdata));
        addr = tb_cfg0.PF3_BAR0 + VIRTIO_LB_BASE_ADDR+'h18;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF3_BAR0+VIRTIO_LB_BASE_ADDR+'h18 +'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

     
        // PF4 = HPS Copy Engine
        
`ifdef INCLUDE_HPS
        addr = tb_cfg0.PF4_BAR0;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF4 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)
        
        `uvm_info(get_name(), $psprintf("////Accessing PF4 HPS Copy Engine Scratchpad Register %0h+'h100////", tb_cfg0.PF4_BAR0), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF4_BAR0+'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF4_BAR0+'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    `endif
        
        // PF0 VF0 = HE MEM
        
        addr = tb_cfg0.PF0_VF0_BAR0+HE_MEM_BASE_ADDR ;
        mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF0 VF0 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        `uvm_info(get_name(), $psprintf("////Accessing PF0 VF0 HE-MEM Scratchpad Register %0h+'h100////", tb_cfg0.PF0_VF0_BAR0), UVM_LOW)

        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF0_BAR0+HE_MEM_BASE_ADDR +'h100;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF0_BAR0+HE_MEM_BASE_ADDR +'h100+'h4;
                
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF0 VF1 = HE HSSI
        
       `ifndef INCLUDE_CVL
        addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR;
	mmio_read64 (.addr_(addr), .data_(rdata));
        mmio_read64 (.addr_(addr+'h8), .data_(afu_id_l));
        mmio_read64 (.addr_(addr+'h10), .data_(afu_id_h));
        `uvm_info(get_name(), $psprintf("PF0 VF1 base addr = 0x%0h, afu id = 0x%h 0x%h", addr, afu_id_h, afu_id_l), UVM_LOW)

        `uvm_info(get_name(), $psprintf("////Accessing PF0 VF1 HE-HSSI Scratchpad Register %0h+'h48////", tb_cfg0.PF0_VF1_BAR0), UVM_LOW)

        	
        addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+'h48;
        wdata= 64'h55555555ffffffff;
                
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
       // assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+'h48;
         wdata = 64'h55555555ffffffff;
//	mmio_write32(.addr_(addr), .data_(wdata));
	mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(rdata[31:0] == wdata[31:0])
           	 `uvm_info(get_name(), $psprintf(" Data match 32 !Addr= %0h,  Exp = %0h, Act = %0h", addr, wdata[31:0], rdata[31:0]),UVM_LOW)
           else
            	 `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr= %0h, Exp = %0h, Act = %0h", addr,wdata[31:0], rdata[31:0]))

      	`uvm_info(get_name(), "  Exiting AFU_SCRATCHPAD_seq...", UVM_LOW)

        addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+'h48+'h4;
        wdata= 64'h55555555ffffffff;        
       // mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[63:32] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata[63:32], rdata[31:0]))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata[31:0]), UVM_LOW)

        `endif
`ifndef NO_MSIX
        // PF0_BAR4 FME MSIX Space 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0_BAR4 FME MSIX Space 64 bit Register %0h+20'h0_3060////", tb_cfg0.PF0_BAR4), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR4+FME_MSIX_BASE_ADDR+20'h0_0060;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF0_BAR4 FME MSIX Space 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR4+FME_MSIX_BASE_ADDR+20'h0_0060;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
`ifdef INCLUDE_CVL

      // PF2_BAR4 HE_LB MSIX Space 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF2_BAR4 HE_LB MSIX Space 64 bit Register %0h+20'h0_3000////", tb_cfg0.PF2_BAR4), UVM_LOW)

        assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3000;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3008;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
      
         assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3010;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3018;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3020;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
     
        
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3028;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3030;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3038;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3040;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


       
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3048;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3050;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


    
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3058;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3060;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



    
          assert(std::randomize(wdata));
        addr = tb_cfg0.PF2_BAR4+20'h0_3068;
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
`endif 

        // PF0_VF0_BAR4 User MSIX Space 64 bit access
        `uvm_info(get_name(), $psprintf("////Accessing PF0_VF0_BAR4 User MSIX Space 64 bit Register %0h+20'h0_3000////", tb_cfg0.PF0_VF0_BAR4), UVM_LOW)
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // PF0_BAR4 MSIX Space 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 


         wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)




      wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0008;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0008;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0008;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0010;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0010;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0010;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0018;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0018;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_018;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0020;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0020;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0020;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0028;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0028;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0028;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0030;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0030;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0030;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0038;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0038;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+ USER_MSIX_BASE_ADDR+20'h0_0038;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0040;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0040;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0040;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0048;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0048;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0048;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0050;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0050;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0050;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



    
     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0058;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0058;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0058;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0060;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0060;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0060;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



     wdata=64'hFFFFFFFFFFFFFFFF;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0068;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

      wdata=64'hAAAAAAAAAAAAAAAA;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0068;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


      wdata=64'h0000000000000000;
         addr = tb_cfg0.PF0_VF0_BAR4+USER_MSIX_BASE_ADDR+20'h0_0068;

        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


`endif //`ifndef NO_MSIX 



       `uvm_info(get_name(), "Exiting mmio_seq...", UVM_LOW)

    endtask : body

endclass : mmio_seq

//`endif // MMIO_SEQ_SVH
