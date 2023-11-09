// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef TB_CONFIG_SVH
`define TB_CONFIG_SVH

`include "pcie_shared_cfg.sv"

class tb_config extends uvm_object;

    // address map 
    rand bit [63:0] bfm_mem_start;
    rand bit [63:0] bfm_mem_end;
    rand bit [63:0] dut_mem_start;
    rand bit [63:0] dut_mem_end;
    bit has_tx_sb;
    bit has_rx_sb;

    rand bit [63:0] PF0_BAR0    ; 
    rand bit [63:0] PF0_BAR4    ; 
    rand bit [63:0] PF0_VF0_BAR0; //Page Size 1MB 
    rand bit [63:0] PF0_VF0_BAR4; //Page Size 1MB 
    rand bit [63:0] PF0_VF1_BAR0; //Page Size 1MB 
    rand bit [63:0] PF0_VF2_BAR0; //Page Size 1MB 
    rand bit [63:0] PF1_BAR0    ; //Page Size 1MB 
    rand bit [63:0] PF1_VF0_BAR0; //Page Size 1MB 
    rand bit [63:0] PF2_BAR0    ; //Page Size 1MB 
    rand bit [63:0] PF2_BAR4    ; //Page Size 1MB 
    rand bit [63:0] PF3_BAR0    ; 
    rand bit [63:0] PF4_BAR0    ; 
    rand bit [63:0] PF0_EXP_ROM_BAR0    ; 
    rand bit [63:0] HE_HSSI_BASE; 
    rand bit [63:0] HE_LB_BASE  ; 
    rand bit [63:0] HE_MEM_BASE ; 
    rand bit [63:0] HE_MEM_TG_BASE ;
`ifdef FIM_B
    rand bit [63:0] PF0_VF3_BAR0; //Page Size 1MB
`endif

    pcie_shared_cfg pcie_cfg;

    `uvm_object_utils_begin(tb_config)
        `uvm_field_int  (PF0_BAR0    , UVM_DEFAULT )
        `uvm_field_int  (PF0_BAR4    , UVM_DEFAULT )
        `uvm_field_int  (PF0_VF0_BAR0, UVM_DEFAULT )
        `uvm_field_int  (PF0_VF1_BAR0, UVM_DEFAULT )
        `uvm_field_int  (PF0_VF2_BAR0, UVM_DEFAULT )
        `uvm_field_int  (PF0_VF0_BAR4, UVM_DEFAULT )
        `uvm_field_int  (PF1_BAR0    , UVM_DEFAULT )
        `uvm_field_int  (PF1_VF0_BAR0, UVM_DEFAULT )
        `uvm_field_int  (PF2_BAR0    , UVM_DEFAULT )
        `uvm_field_int  (PF2_BAR4    , UVM_DEFAULT )
        `uvm_field_int  (PF3_BAR0    , UVM_DEFAULT )
        `uvm_field_int  (PF4_BAR0    , UVM_DEFAULT )
        `uvm_field_int  (HE_LB_BASE  , UVM_DEFAULT )
        `uvm_field_int  (HE_MEM_BASE , UVM_DEFAULT )
        `uvm_field_int  (HE_HSSI_BASE, UVM_DEFAULT )
        `uvm_field_int  (HE_MEM_TG_BASE , UVM_DEFAULT )
`ifdef FIM_B
        `uvm_field_int  (PF0_VF3_BAR0, UVM_DEFAULT )       
`endif       
    `uvm_object_utils_end

    constraint bfm_mem_c {
        bfm_mem_start   == 64'h0_0000_0000_0000;
        bfm_mem_end     == 64'h0_3fff_ffff_ffff; // 46-bit HPA
    };
    //Supported Memory Range in SKX-P
    //48-bit GPA - Sim with IOMMU
    //46-bit HPA - Sim without IOMMU
    //TODO: Change constraint once IOMMU support enabled
    constraint dut_mem_c {
        dut_mem_start   == 64'h0_0000_1000_0000;
        dut_mem_end     == 64'h0_3fff_ffff_ffff; 
    };

   `ifndef INCLUDE_CVL
    constraint bar_c {
      PF0_BAR0 inside {'h0000_0000_8000_0000, 'h8000_0000_0000_0000};
      PF0_BAR4 inside {'h0000_0000_8020_0000, 'h8020_0000_0000_0000};
      PF0_VF0_BAR0 inside {'h0000_0000_9000_0000, 'h9000_0000_0000_0000};
      PF0_VF1_BAR0 == PF0_VF0_BAR0 + 'h10_0000; //Page Size is 1MB
      PF0_VF2_BAR0 == PF0_VF1_BAR0 + 'h10_0000; //Page Size is 1MB
      PF0_VF0_BAR4 inside {'h0000_0000_9080_0000, 'h9080_0000_0000_0000};
      PF1_BAR0 inside {'h0000_0000_A000_0000, 'hA000_0000_0000_0000};
      PF1_VF0_BAR0 inside {'h0000_0000_B000_0000, 'hB000_0000_0000_0000};
      PF2_BAR0 inside {'h0000_0000_C000_0000, 'hC000_0000_0000_0000};
      PF2_BAR4 inside {'h0000_0000_C020_0000, 'hC020_0000_0000_0000};
      PF3_BAR0 inside {'h0000_0000_D000_0000, 'hD000_0000_0000_0000};
      PF4_BAR0 inside {'h0000_0000_E000_0000, 'hE000_0000_0000_0000};
      PF0_EXP_ROM_BAR0 inside {'h0000_0000_F000_0000};//32 Bit BAR only
      HE_MEM_BASE == PF0_VF0_BAR0; 
      HE_HSSI_BASE == PF0_VF1_BAR0;
      HE_MEM_TG_BASE == PF0_VF2_BAR0;
      HE_LB_BASE == PF2_BAR0;
   `else
      /* VF0:- {0000_0000 to 3FFF_FFFF} 1GB
     VF1:- {4000_0000 to 7FFF_FFFF}
     VF2:- {8000_0000 to BFFF_FFFF}*/
    constraint bar_c {
      PF0_BAR0 == 'h8000_0000_0000_0000;
      PF0_BAR4 == 'h8020_0000_0000_0000;
      PF0_VF0_BAR0 == 'h0000_0000;
      PF0_VF1_BAR0 == 'h4000_0000; //Page Size is 1GB
      PF0_VF2_BAR0 == 'h8000_0000; //Page Size is 1GB
      PF0_VF0_BAR4 == 'h9080_0000_0000_0000; //address width 14bit
      PF1_BAR0     == 'hA000_0000_0000_0000;
      PF1_VF0_BAR0 == 'hB000_0000_0000_0000; //address width 12bit
      PF2_BAR0     == 'hC000_0000_0000_0000;
      PF2_BAR4     =='hC020_0000_0000_0000;
      PF3_BAR0     =='hD000_0000_0000_0000;
      PF4_BAR0     =='hE000_0000_0000_0000;
      PF0_EXP_ROM_BAR0 == 'h0000_0000_F000_0000;//32 Bit BAR only
      HE_MEM_BASE == PF0_VF0_BAR0; 
      HE_HSSI_BASE == PF0_VF1_BAR0;
      HE_MEM_TG_BASE == PF0_VF2_BAR0;
      HE_LB_BASE == PF2_BAR0;
    `endif
`ifdef FIM_B
     PF0_VF3_BAR0 == PF0_VF2_BAR0 + 'h10_0000; //Page Size is 1MB
`endif       
    };

    function new(string name = "tb_config");
        super.new(name);
	pcie_cfg = pcie_shared_cfg::type_id::create("pcie_cfg");
    endfunction : new

endclass : tb_config

`endif // TB_CONFIG_SVH
