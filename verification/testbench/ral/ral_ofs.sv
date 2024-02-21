// Copyright (C) 2020 Intel Corporation
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
//
// UVM reg block for all IOFS CSR's
//
//-----------------------------------------------------------------------------

`ifndef RAL_OFS
`define RAL_OFS


`ifndef COV

`include "ral_ac_fme.sv"
`include "ral_ac_he_hssi.sv"
`include "ral_ac_hssi.sv"
`include "ral_ac_he_lpbk.sv"
`include "ral_ac_he_mem.sv"
`include "ral_ac_pcie.sv"
`include "ral_ac_st2mm.sv"
`include "ral_pr.sv"
`include "ral_ac_ce.sv"
`include "ral_ac_qsfp.sv"
`include "ac_emif.sv"
`include "ac_mem_tg.sv"
`include "ral_ac_pmci.sv"
`include "ral_ac_AFU_INTF.sv"
`include "ral_ac_msix.sv"
`include "ral_ac_src_port_gasket_agilex_pg.sv"

`else

`include "ral_ac_he_mem_cov.sv"
`include "ral_ac_fme_cov.sv"
`include "ral_ac_he_hssi_cov.sv"
`include "ral_ac_hssi_cov.sv"
`include "ral_ac_he_lpbk_cov.sv"
`include "ral_ac_pcie_cov.sv"
`include "ral_ac_st2mm_cov.sv"
//`include "ral_pr_cov.sv"
`include "ral_pr.sv"
`include "ral_ac_ce_cov.sv"
`include "ral_ac_qsfp_cov.sv"
`include "ac_emif_cov.sv"
`include "ral_ac_mem_tg_cov.sv"
`include "ral_ac_pmci_cov.sv"
`include "ral_ac_AFU_INTF_cov.sv"
`include "ral_ac_msix_cov.sv"
`include "ral_ac_src_port_gasket_agilex_pg_cov.sv"

`endif

class ral_block_ofs extends uvm_reg_block;

//SSS rand ral_block_iofs_port     pr_regs[`PORTS];
rand ral_block_ac_he_mem    mem_regs;
rand ral_block_ac_fme       fme_regs;
rand ral_block_ac_pcie      pcie_regs;
rand ral_block_ac_qsfp      qsfp0_regs;
rand ral_block_ac_qsfp      qsfp1_regs;
rand ral_block_ac_pmci      pmci_regs;
rand ral_block_pr           pr_regs[1];
rand ral_block_ac_st2mm     st2mm_regs;
rand ral_block_ac_he_hssi   he_hssi_regs;
rand ral_block_ac_hssi      hssi_regs;
rand ral_block_ac_he_lpbk   he_lpbk_regs;
rand ral_block_ac_he_lpbk   pr_he_lpbk_regs;
rand ral_block_ac_AFU_INTF  afu_intf_regs;
rand ral_block_ac_msix      msix_regs;
rand ral_block_ac_src_port_gasket_agilex_pg     pr_gasket_regs;
rand ral_block_ac_emif      emif_regs;
rand ral_block_ac_mem_tg    mem_tg_regs;
rand ral_block_ac_ce        ce_regs;

//SSS rand ral_block_iofs_vfme     vfme_regs;
//SSS rand ral_block_iofs_port_user_clock     port_user_clock_regs;

//SSS uvm_reg_map pr_map;
uvm_reg_map fme_map;
//SSS uvm_reg_map vfme_map;
 uvm_reg_map pcie_map;
 uvm_reg_map emif_map;
 uvm_reg_map mem_tg_map;
 uvm_reg_map mem_map;
 uvm_reg_map pr_map;
 uvm_reg_map hssi_map;
 uvm_reg_map he_hssi_map;
 uvm_reg_map st2mm_map;
 uvm_reg_map pmci_map;
 uvm_reg_map he_lpbk_map;
 uvm_reg_map pr_he_lpbk_map;
 uvm_reg_map qsfp0_map;
 uvm_reg_map qsfp1_map;
 uvm_reg_map ce_map;
 uvm_reg_map afu_intf_map;
 uvm_reg_map msix_map;
 uvm_reg_map pr_gasket_map;
//SSS uvm_reg_map port_user_clock_map;

    `uvm_object_utils(ral_block_ofs)

function new(string name = "ofs");
`ifndef COV
    super.new(name, build_coverage(UVM_NO_COVERAGE));
`else
    super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
`endif
endfunction: new 

virtual function void build();
    this.fme_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.pr_map   = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.pcie_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.pmci_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.qsfp0_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.qsfp1_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.st2mm_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.pr_gasket_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.he_hssi_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.hssi_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.emif_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.mem_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.mem_tg_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.he_lpbk_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.pr_he_lpbk_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.ce_map      = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.afu_intf_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
    this.msix_map     = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
 //SSS   this.vfme_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
 //SSS   this.port_user_clock_map    = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);

`ifdef COV
    uvm_reg::include_coverage("*", UVM_CVR_FIELD_VALS);
`endif

    fme_regs =ral_block_ac_fme::type_id::create("fme");
    fme_regs.configure(this);
    fme_regs.build();
    fme_map.add_submap(this.fme_regs.default_map,FME_BASE_ADDR);
    fme_regs.lock_model();

 //SSS   vfme_regs =ral_block_iofs_vfme::type_id::create("vfme");
 //SSS   vfme_regs.configure(this);
 //SSS   vfme_regs.build();
 //SSS   vfme_map.add_submap(this.vfme_regs.default_map,'h0);
 //SSS   vfme_regs.lock_model();

   pcie_regs =ral_block_ac_pcie::type_id::create("pcie");
   pcie_regs.configure(this);
   pcie_regs.build();
  //  pcie_map.add_submap(this.pcie_regs.default_map,'h10000);
   pcie_map.add_submap(this.pcie_regs.default_map,PCIE_BASE_ADDR);
   pcie_regs.lock_model();

   pmci_regs =ral_block_ac_pmci::type_id::create("pmci");
   pmci_regs.configure(this);
   pmci_regs.build();
   pmci_map.add_submap(this.pmci_regs.default_map, PMCI_BASE_ADDR);
   pmci_regs.lock_model();

   qsfp0_regs =ral_block_ac_qsfp::type_id::create("qsfp0");
   qsfp0_regs.configure(this);
   qsfp0_regs.build();
   qsfp0_map.add_submap(this.qsfp0_regs.default_map, QSFP0_BASE_ADDR);
   qsfp0_regs.lock_model();


   qsfp1_regs =ral_block_ac_qsfp::type_id::create("qsfp1");
   qsfp1_regs.configure(this);
   qsfp1_regs.build();
   qsfp1_map.add_submap(this.qsfp1_regs.default_map,QSFP1_BASE_ADDR);
   qsfp1_regs.lock_model();


    st2mm_regs =ral_block_ac_st2mm::type_id::create("st2mm");
    st2mm_regs.configure(this);
    st2mm_regs.build();
  //  st2mm_map.add_submap(this.st2mm_regs.default_map,'h40000);
    st2mm_map.add_submap(this.st2mm_regs.default_map, ST2MM_BASE_ADDR);
    st2mm_regs.lock_model();
   
    afu_intf_regs =ral_block_ac_AFU_INTF::type_id::create("afu_intf");
    afu_intf_regs.configure(this);
    afu_intf_regs.build();
    afu_intf_map.add_submap(this.afu_intf_regs.default_map,PROTOCOL_CHECKER_BASE_ADDR);
    afu_intf_regs.lock_model();

    msix_regs =ral_block_ac_msix::type_id::create("msix");
    msix_regs.configure(this);
    msix_regs.build();
    msix_map.add_submap(this.msix_regs.default_map,'h0);
    msix_regs.lock_model();

 

    pr_gasket_regs =ral_block_ac_src_port_gasket_agilex_pg::type_id::create("pg");
    pr_gasket_regs.configure(this);
    pr_gasket_regs.build();
    pr_gasket_map.add_submap(this.pr_gasket_regs.default_map,PORT_GASKET_BASE_ADDR);
    pr_gasket_regs.lock_model();


    he_hssi_regs =ral_block_ac_he_hssi::type_id::create("he_hssi");
    he_hssi_regs.configure(this);
    he_hssi_regs.build();
    he_hssi_map.add_submap(this.he_hssi_regs.default_map,HE_HSSI_BASE_ADDR);
  //  he_hssi_map.add_submap(this.he_hssi_regs.default_map,'h0);
    he_hssi_regs.lock_model();


    hssi_regs =ral_block_ac_hssi::type_id::create("hssi");
    hssi_regs.configure(this);
    hssi_regs.build();
    hssi_map.add_submap(this.hssi_regs.default_map,HSSI_BASE_ADDR);
   // hssi_map.add_submap(this.hssi_regs.default_map,'h0);
    hssi_regs.lock_model();


    emif_regs =ral_block_ac_emif::type_id::create("emif");
    emif_regs.configure(this);
    emif_regs.build();
  //  emif_map.add_submap(this.he_emif_regs.default_map,'h61000);
    emif_map.add_submap(this.emif_regs.default_map, EMIF_BASE_ADDR);
    emif_regs.lock_model();


     mem_tg_regs =ral_block_ac_mem_tg::type_id::create("mem_tg");
     mem_tg_regs.configure(this);
     mem_tg_regs.build();
     mem_tg_map.add_submap(this.mem_tg_regs.default_map,MEM_TG_BASE_ADDR);
     mem_tg_regs.lock_model();

    

    
    mem_regs =ral_block_ac_he_mem::type_id::create("mem");
    mem_regs.configure(this);
    mem_regs.build();
  //  mem_map.add_submap(this.mem_regs.default_map,'h61000);
    mem_map.add_submap(this.mem_regs.default_map, HE_MEM_BASE_ADDR);
    mem_regs.lock_model();


    he_lpbk_regs =ral_block_ac_he_lpbk::type_id::create("he_lbk");
    he_lpbk_regs.configure(this);
    he_lpbk_regs.build();
    he_lpbk_map.add_submap(this.he_lpbk_regs.default_map, HE_LB_BASE_ADDR);
    he_lpbk_regs.lock_model();


    pr_he_lpbk_regs =ral_block_ac_he_lpbk::type_id::create("he_lbk");
    pr_he_lpbk_regs.configure(this);
    pr_he_lpbk_regs.build();
    pr_he_lpbk_map.add_submap(this.pr_he_lpbk_regs.default_map, HE_LB_BASE_ADDR);
    pr_he_lpbk_regs.lock_model();


    ce_regs =ral_block_ac_ce::type_id::create("ce");
    ce_regs.configure(this);
    ce_regs.build();
    ce_map.add_submap(this.ce_regs.default_map,'h0);
    ce_regs.lock_model();



   //SSS TODO hps_ce_lbk_regs =ral_block_ac_hps_ce_lbk::type_id::create("he_lbk");
   //SSS TODO hps_ce_lbk_regs.configure(this);
   //SSS TODO hps_ce_lbk_regs.build();
   //SSS TODO hps_ce_lbk_map.add_submap(this.emif_regs.default_map,'h0);
   //SSS TODO hps_ce_lbk_regs.lock_model();





    foreach(pr_regs[i]) begin
        pr_regs[i] =ral_block_pr::type_id::create($sformatf("pr"));
        pr_regs[i].configure(this);
        pr_regs[i].build();
        pr_map.add_submap(this.pr_regs[i].default_map,i*'h50000);
        pr_regs[i].lock_model();
    end 

 //SSS   port_user_clock_regs =ral_block_iofs_port_user_clock::type_id::create("port_user_clock");
 //SSS   port_user_clock_regs.configure(this);
 //SSS   port_user_clock_regs.build();
 //SSS   //port_user_clock_map.add_submap(this.port_user_clock_regs.default_map,'h20000);
 //SSS   port_user_clock_map.add_submap(this.port_user_clock_regs.default_map,'h0);
 //SSS   port_user_clock_regs.lock_model();

endfunction: build

endclass: ral_block_ofs

`endif
