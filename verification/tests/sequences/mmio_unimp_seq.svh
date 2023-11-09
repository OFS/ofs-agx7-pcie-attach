//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class mmio_unimp_seq is executed by mmio_unimp_test.
 * 
 * This sequence uses the RAL model for front-door access of registers  
 * This sequence verifies unimplimented CSR addresses of the mentioned blocks
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef MMIO_UNIMP_SEQ_SVH
`define MMIO_UNIMP_SEQ_SVH

class mmio_unimp_seq extends base_seq;
    `uvm_object_utils(mmio_unimp_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand bit  [63:0]  l_addr_lpbk,m_addr_lpbk,u_addr_lpbk,l_addr_mem,m_addr_mem,u_addr_mem,l_addr_fme,m_addr_fme,u_addr_fme,l_addr_st2mm,m_addr_st2mm,u_addr_st2mm,l_addr_pcie,m_addr_pcie,u_addr_pcie,l_addr_pmci,m_addr_pmci,u_addr_pmci,l_addr_qsfp,m_addr_qsfp,u_addr_qsfp,l_addr_ce,m_addr_ce,u_addr_ce,l_addr_hssi,m_addr_hssi,u_addr_hssi,l_addr_pg,m_addr_pg,u_addr_pg,l_addr_he_hssi,m_addr_he_hssi,u_addr_he_hssi,l_addr_mem_tg,m_addr_mem_tg,u_addr_mem_tg,l_addr_emif,m_addr_emif,u_addr_emif,l_addr_afu_intf,m_addr_afu_intf,u_addr_afu_intf,l_addr_msix,m_addr_msix,u_addr_msix;

     constraint lower_addr_lpbk {
         l_addr_lpbk[63:32] == 'h0000;
         l_addr_lpbk[31:2] inside {['h62:'h540]};
         l_addr_lpbk[1:0] == 2'h0;
     }
     constraint middle_addr_lpbk {
         m_addr_lpbk[63:32] == 'h0000;
         m_addr_lpbk[31:2] inside {['h542:'hc00]};  
         m_addr_lpbk[1:0] == 2'h0;
     }    
     constraint upper_addr_lpbk {
         u_addr_lpbk[63:32] == 'h0000;
         u_addr_lpbk[31:2] inside {['hc02:'hfff]};
         u_addr_lpbk[1:0] == 2'h0;
     }

     constraint lower_addr_mem {
         l_addr_mem[63:32] == 'h0000;
         l_addr_mem[31:2] inside {['h62:'h540]};
         l_addr_mem[1:0] == 2'h0;
     }
     constraint middle_addr_mem {
         m_addr_mem[63:32] == 'h0000;
         m_addr_mem[31:2] inside {['h542:'hc00]};  
         m_addr_mem[1:0] == 2'h0;
     }    
     constraint upper_addr_mem {
         u_addr_mem[63:32] == 'h0000;
         u_addr_mem[31:2] inside {['hc02:'hfff]};
         u_addr_mem[1:0] == 2'h0;
     }
 
     constraint lower_addr_fme {
         l_addr_fme[63:32] == 'h0000;
         l_addr_fme[31:2] inside {['h101e:'h141e]};
         l_addr_fme[1:0] == 2'h0;
     }
     constraint middle_addr_fme {
         m_addr_fme[63:32] == 'h0000;
         m_addr_fme[31:2] inside {['h1420:'h1c20]};  
         m_addr_fme[1:0] == 2'h0;
     }    
     constraint upper_addr_fme {
         u_addr_fme[63:32] == 'h0000;
         u_addr_fme[31:2] inside {['h2000:'h3fff]};
         u_addr_fme[1:0] == 2'h0;
     }

     constraint lower_addr_st2mm {
         l_addr_st2mm[63:32] == 'h0000;
         l_addr_st2mm[31:2] inside {['h4:'h800]};
         l_addr_st2mm[1:0] == 2'h0;
     }    
     constraint middle_addr_st2mm {
         m_addr_st2mm[63:32] == 'h0000;
         m_addr_st2mm[31:2] inside {['h1002:'h1826]};  
         m_addr_st2mm[1:0] == 2'h0;
     }    
    
     constraint lower_addr_pcie {
         l_addr_pcie[63:32] == 'h0000;
         l_addr_pcie[31:2] inside {['he:'ha6]};
         l_addr_pcie[1:0] == 2'h0;
     }
     constraint middle_addr_pcie {
         m_addr_pcie[63:32] == 'h0000;
         m_addr_pcie[31:2] inside {['h102:'h142]};  
         m_addr_pcie[1:0] == 2'h0;
     }    
     constraint upper_addr_pcie {
         u_addr_pcie[63:32] == 'h0000;
         u_addr_pcie[31:2] inside {['h202:'h3ff]};
         u_addr_pcie[1:0] == 2'h0;
     }    
     
     constraint lower_addr_pmci {
         l_addr_pmci[63:32] == 'h0000;
         l_addr_pmci[31:2] inside {['h42:'ha6]};
         l_addr_pmci[1:0] == 2'h0;
     }    
     constraint middle_addr_pmci {
         m_addr_pmci[63:32] == 'h0000;
         m_addr_pmci[31:2] inside {['hc2:'h142]};  
         m_addr_pmci[1:0] == 2'h0;
     }    
     constraint upper_addr_pmci {
         u_addr_pmci[63:32] == 'h0000;   
         u_addr_pmci[31:2] inside {['h200:'h3ff]};
         u_addr_pmci[1:0] == 2'h0;
     }    

 //pg address range is not changed
 
     constraint lower_addr_pg {
         l_addr_pg[63:32] == 'h0000;
         l_addr_pg[31:2] inside {['h3010:'h4010]};
         l_addr_pg[1:0] == 2'h0;
     }    
     constraint middle_addr_pg {
         m_addr_pg[63:32] == 'h0000;
         m_addr_pg[31:2] inside {['h4010:'h8008]};  
         m_addr_pg[1:0] == 2'h0;
     }    
     constraint upper_addr_pg {
         u_addr_pg[63:32] == 'h0000;
         u_addr_pg[31:2] inside {['h8010:'hffff]};  
         u_addr_pg[1:0] == 2'h0;
     }    

     constraint lower_addr_he_hssi {
         l_addr_he_hssi[63:32] == 'h0000;
         l_addr_he_hssi[31:2] inside {['h16:'h540]};
         l_addr_he_hssi[1:0] == 2'h0;
     }    
     constraint middle_addr_he_hssi {
         m_addr_he_hssi[63:32] == 'h0000;
         m_addr_he_hssi[31:2] inside {['h5402:'h5c02]}; 
         m_addr_he_hssi[1:0] == 2'h0;
     }    
     constraint upper_addr_he_hssi {
         u_addr_he_hssi[63:32] == 'h0000;
         u_addr_he_hssi[31:2] inside {['hc002:'hffff]};
         u_addr_he_hssi[1:0] == 2'h0;
     }  

     constraint lower_addr_qsfp {
         l_addr_qsfp[63:32] == 'h0000;
         l_addr_qsfp[31:2] inside {['h40:'ha6]};
         l_addr_qsfp[1:0] == 2'h0;
     }    
     constraint middle_addr_qsfp {
         m_addr_qsfp[63:32] == 'h0000;
         m_addr_qsfp[31:2] inside {['hc2:'h166]}; 
         m_addr_qsfp[1:0] == 2'h0;
     }    
     constraint upper_addr_qsfp {
         u_addr_qsfp[63:32] == 'h0000;
         u_addr_qsfp[31:2] inside {['h200:'h3ff]};
         u_addr_qsfp[1:0] == 2'h0;
     }

      constraint lower_addr_hssi {
         l_addr_hssi[63:32] == 'h0000;
         l_addr_hssi[31:2] inside {['h60:'he0]};
         l_addr_hssi[1:0] == 2'h0;
     }    
     constraint middle_addr_hssi {
         m_addr_hssi[63:32] == 'h0000;
         m_addr_hssi[31:2] inside {['he2:'h166]}; 
         m_addr_hssi[1:0] == 2'h0;
     }    
     constraint upper_addr_hssi {
         u_addr_hssi[63:32] == 'h0000;
         u_addr_hssi[31:2] inside {['h1c2:'h3ff]};
         u_addr_hssi[1:0] == 2'h0;
     }    

     constraint lower_addr_ce {
         l_addr_ce[63:32] == 'h0000;
         l_addr_ce[31:2] inside {['h58:'he0]};
         l_addr_ce[1:0] == 2'h0;
     }    
     constraint middle_addr_ce {
         m_addr_ce[63:32] == 'h0000;
         m_addr_ce[31:2] inside {['he2:'h166]}; 
         m_addr_ce[1:0] == 2'h0;
     }    
     constraint upper_addr_ce {
         u_addr_ce[63:32] == 'h0000;
         u_addr_ce[31:2] inside {['h1c2:'h3ff]};
         u_addr_ce[1:0] == 2'h0;
     }

     constraint lower_addr_emif {
         l_addr_emif[63:32] == 'h0000;
         l_addr_emif[31:2] inside {['h6:'h540]};
         l_addr_emif[1:0] == 2'h0;
     }    
     constraint middle_addr_emif {
         m_addr_emif[63:32] == 'h0000;
         m_addr_emif[31:2] inside {['h542:'hc00]}; 
         m_addr_emif[1:0] == 2'h0;
     }    
     constraint upper_addr_emif {
         u_addr_emif[63:32] == 'h0000;
         u_addr_emif[31:2] inside {['hc02:'h1000]};
         u_addr_emif[1:0] == 2'h0;
     }

  
     constraint lower_addr_afu_intf {
         l_addr_afu_intf[63:32] == 'h0000;
         l_addr_afu_intf[31:2] inside {['hc:'h540]};
         l_addr_afu_intf[1:0] == 2'h0;
     }    
     constraint middle_addr_afu_intf {
         m_addr_afu_intf[63:32] == 'h0000;
         m_addr_afu_intf[31:2] inside {['h542:'hc00]}; 
         m_addr_afu_intf[1:0] == 2'h0;
     }    
     constraint upper_addr_afu_intf {
         u_addr_afu_intf[63:32] == 'h0000;
         u_addr_afu_intf[31:2] inside {['hc02:'h1000]};
         u_addr_afu_intf[1:0] == 2'h0;
     }

      constraint lower_addr_msix {
         l_addr_msix[63:32] == 'h0000;
         l_addr_msix[31:2] inside {['h20:'he0]};
         l_addr_msix[1:0] == 2'h0;
     }    
     constraint middle_addr_msix {
         m_addr_msix[63:32] == 'h0000;
         m_addr_msix[31:2] inside {['h32:'h140]}; 
         m_addr_msix[1:0] == 2'h0;
     }    
     constraint upper_addr_msix {
         u_addr_msix[63:32] == 'h0000;
         u_addr_msix[31:2] inside {['h142:'h200]};
         u_addr_msix[1:0] == 2'h0;
     } 


    function new(string name = "mmio_unimp_seq");
        super.new(name);
    endfunction : new

    task body();
     begin
	bit [63:0] wdata, rdata,addr;

        super.body();
        `uvm_info(get_name(), "Entering mmio_unimp_seq...", UVM_LOW)


/*********************CE-CSR***************************/

`ifdef INCLUDE_HPS

    wdata = 64'hffff_ffff_ffff_ffff;
    addr = tb_cfg0.PF4_BAR0 + 64'h100;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	
	// CE-CSR unimplemented CSR access
		
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF4_BAR0 + l_addr_ce;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'hffff_ffff_ffff_ffff)
            `uvm_error(get_name(), $psprintf("CE_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("CE_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)   

    assert(std::randomize(wdata));
	addr = tb_cfg0.PF4_BAR0 + m_addr_ce + 'h4;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'hffff_ffff_ffff_ffff)
            `uvm_error(get_name(), $psprintf("CE_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("CE_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)   
    
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF4_BAR0 + u_addr_ce + 'h4;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata)); 

     if(rdata !== 64'hffff_ffff_ffff_ffff)
            `uvm_error(get_name(), $psprintf("CE_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("CE_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

`endif

/*********************HE-LPBK***************************/

    assert(std::randomize(wdata));
	addr = tb_cfg0.PF2_BAR0 +HE_LB_BASE_ADDR +64'h100;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
 
    if(wdata !== rdata)
           `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
           `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	// HE-LB unimplemented CSR access
   

	assert(std::randomize(wdata));
	addr =  tb_cfg0.PF2_BAR0 + HE_LB_BASE_ADDR + l_addr_lpbk;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

    assert(std::randomize(wdata));
	addr =  tb_cfg0.PF2_BAR0 +HE_LB_BASE_ADDR + m_addr_lpbk;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

    assert(std::randomize(wdata));
	addr =  tb_cfg0.PF2_BAR0 +HE_LB_BASE_ADDR+ u_addr_lpbk;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));        
	
    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_LB unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_LB unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)


/*********************HE-MEM***************************/
  

	assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_VF0_BAR0 +HE_MEM_BASE_ADDR+  64'h100;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	
	// HE-MEM unimplemented CSR access


    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF0_BAR0+ HE_MEM_BASE_ADDR+l_addr_mem;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_MEM unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_MEM unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 
    
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF0_BAR0 +HE_MEM_BASE_ADDR+ m_addr_mem;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_MEM unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_MEM unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_VF0_BAR0 +HE_MEM_BASE_ADDR+ u_addr_mem;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    
    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_MEM unimplemented CSR returning incorrect rdata ! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_MEM unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    

/*********************PCIE_CSR***************************/

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PCIE_BASE_ADDR +'h8;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
 
    if(wdata !== rdata)
        `uvm_error(get_name(), $psprintf("Data mismatch pcie_SCRATCHPAD! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("Data match pcie_SCRATCHPAD! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    //pcie unmp CSR


    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 +PCIE_BASE_ADDR + l_addr_pcie;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
   
   if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pcie unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pcie unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PCIE_BASE_ADDR + m_addr_pcie;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pcie unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pcie unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)  

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PCIE_BASE_ADDR + u_addr_pcie;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pcie unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pcie unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

/*********************PMCI_CSR***************************/
 `ifndef bypass_address
    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 +PMCI_BASE_ADDR +'h58;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    
    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pmci unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pmci unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PMCI_BASE_ADDR+'h70;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pmci unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pmci unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PMCI_BASE_ADDR + l_addr_pmci;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
   
   if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pmci unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pmci unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PMCI_BASE_ADDR + m_addr_pmci;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pmci unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pmci unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)  

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PMCI_BASE_ADDR + u_addr_pmci;        
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("pmci unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
    else
        `uvm_info(get_name(), $psprintf("pmci unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

 `endif

/*********************HE-HSSI***************************/
`ifndef INCLUDE_CVL

	wdata = 64'h1000010000001000;
	addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+64'h0;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
           `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata , rdata))
    else
           `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	
	// HE-HSSI unimplemented CSR access
		
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+l_addr_he_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+m_addr_he_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+u_addr_he_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));  
  
    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("HE_HSSI unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("HE_HSSI unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
    
`endif 
/*********************HSSI-SS***************************/
 
    wdata = 64'h00000000ffffffff;
    addr = tb_cfg0.PF0_BAR0+ HSSI_BASE_ADDR +64'h00808;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
        `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	// HSSI-SS unimplemented CSR access
    

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + HSSI_BASE_ADDR + l_addr_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("HSSI_SS unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("HSSI_SS unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 +  HSSI_BASE_ADDR + m_addr_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    
    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("HSSI_SS unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("HSSI_SS unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 +  HSSI_BASE_ADDR + u_addr_hssi;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata)); 
   
   if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("HSSI_SS unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("HSSI_SS unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)
	
 
/*********************FME-CSR***************************/

    wdata = 64'hbfaf2ae94a5246e3;
    addr = tb_cfg0.PF0_BAR0 +FME_BASE_ADDR + 64'h10;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if( wdata !== rdata)
       `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

// FME-CSR unimplemented CSR access

   assert(std::randomize(wdata));		
   addr = tb_cfg0.PF0_BAR0 +FME_BASE_ADDR+ l_addr_fme;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata));
  
  if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf("FME_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr,rdata))
   else
       `uvm_info(get_name(), $psprintf("FME_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)     

   assert(std::randomize(wdata));
   addr = tb_cfg0.PF0_BAR0 +FME_BASE_ADDR+ m_addr_fme;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata));
  
  if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf("FME_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
   else
       `uvm_info(get_name(), $psprintf("FME_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

   assert(std::randomize(wdata));
   addr = tb_cfg0.PF0_BAR0 +FME_BASE_ADDR+ u_addr_fme;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata)); 
   
   if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf("FME_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
   else
       `uvm_info(get_name(), $psprintf("FME_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)										


  /*********************ST2MM-CSR***************************/
   
    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + ST2MM_BASE_ADDR + 64'h8;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if( wdata !== rdata)
       `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
       `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

// ST2MM-CSR unimplemented CSR access
  

   assert(std::randomize(wdata));		
   addr = tb_cfg0.PF0_BAR0 + ST2MM_BASE_ADDR + l_addr_st2mm;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata));

   if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf("ST2MM_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr,rdata))
   else
       `uvm_info(get_name(), $psprintf("ST2MM_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)     

   assert(std::randomize(wdata));
   addr = tb_cfg0.PF0_BAR0 + ST2MM_BASE_ADDR + m_addr_st2mm;
   mmio_write64(.addr_(addr), .data_(wdata));
   mmio_read64 (.addr_(addr), .data_(rdata));
  
  if(rdata !== 64'h0)
       `uvm_error(get_name(), $psprintf("ST2MM_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, Act = %0h", addr, rdata))
   else
       `uvm_info(get_name(), $psprintf("ST2MM_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

  
   /*********************QSFP-CSR***************************/

	wdata = 64'h0000000000000008;
    addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+64'h20;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
        `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	// QSFP-CSR unimplemented CSR access


    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+l_addr_qsfp;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    
    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+m_addr_qsfp;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));
    
    if(rdata !== 64'h0)
        `uvm_error(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
        `uvm_info(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_BAR0+QSFP0_BASE_ADDR+u_addr_qsfp;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata)); 
   
   if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("QSFP_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)



    /*********************EMIF_CSR***************************/

	wdata = 64'h000000000000000F;
    addr = tb_cfg0.PF0_BAR0 + EMIF_BASE_ADDR +64'h10;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	
	// EMIF_CSR unimplemented CSR access
		
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_BAR0 + EMIF_BASE_ADDR +64'h50;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)    
  
    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + EMIF_BASE_ADDR +64'h80;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 
        
    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + EMIF_BASE_ADDR +64'hFF0;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("EMIF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 



  /*********************AFU_INTF_CSR***************************/

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 +PROTOCOL_CHECKER_BASE_ADDR+64'h8;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

	if(wdata !== rdata)
            `uvm_error(get_name(), $psprintf("Data mismatch! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("Data match! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

	
	// AFU_INTF_CSR unimplemented CSR access
		
    assert(std::randomize(wdata));
	addr = tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR+ l_addr_afu_intf;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)   

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR+ m_addr_afu_intf;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW) 

    assert(std::randomize(wdata));
    addr = tb_cfg0.PF0_BAR0 + PROTOCOL_CHECKER_BASE_ADDR+ u_addr_afu_intf;
    mmio_write64(.addr_(addr), .data_(wdata));
    mmio_read64 (.addr_(addr), .data_(rdata));

    if(rdata !== 64'h0)
            `uvm_error(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning incorrect rdata! Addr = %0h, wdata = %0h, Act = %0h", addr, wdata, rdata))
    else
            `uvm_info(get_name(), $psprintf("AFU_INTF_CSR unimplemented CSR returning correct rdata! addr = %0h, data = %0h", addr, rdata), UVM_LOW)        
            
    end
    endtask : body

endclass : mmio_unimp_seq

`endif // MMIO_UNIMP_SEQ_SVH
