// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//`ifndef GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV
//`define GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV


class enumerate_seq extends `PCIE_DRIVER_TRANSACTION_BASE_SEQ_CLASS; 

 `include "pcie_hip_defines.svh"
   bit[31:0]   dev_ctl_data, pci_ctl;
   bit[31:0]   pf0_bar0, pf1_bar0, pf2_bar0, pf3_bar0, pf4_bar0;
   bit[31:0]   pf1_vf0_bar0, pf2_vf0_bar0, pf2_vf1_bar0;
   bit[2:0]    max_rd_req, max_pl_size;
   bit[63:0]   root_dma_msi_addr;
   bit[31:0]   msi_msgdata;
   bit[15:0]   num_vfs;
   bit[31:0]   vf_page_size = 32'h1;
   `PCIE_DEV_CFG_CLASS cfg;


  `uvm_object_utils_begin(enumerate_seq)
      `uvm_field_int(dev_ctl_data, UVM_DEFAULT)
      `uvm_field_int(pci_ctl, UVM_DEFAULT)
      `uvm_field_int(pf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf1_bar0, UVM_DEFAULT)
      `uvm_field_int(pf1_vf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf2_bar0, UVM_DEFAULT)
      `uvm_field_int(pf2_vf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf2_vf1_bar0, UVM_DEFAULT)
      `uvm_field_int(pf3_bar0, UVM_DEFAULT)
      `uvm_field_int(pf4_bar0, UVM_DEFAULT)
  `uvm_object_utils_end


  function new(string name="enumerate_seq");
    super.new(name);
  endfunction

  virtual task body();
     `PCIE_DRIVER_TRANSACTION_CLASS write_tran, read_tran;
     `VIP_CFG get_cfg;
     bit status1;
     bit[31:0]  msi_ctl;
     bit[31:0]  dev_ctl;
     bit[31:0]  rdata;

     `uvm_info("body", "SDEBUG enum: Entered Enumerating...", UVM_LOW)

     super.body();

     //Obtain a handle to the port configuration 
     p_sequencer.get_cfg(get_cfg);
     if (!$cast(cfg, get_cfg)) begin
        `uvm_fatal("body", "Unable to $cast the configuration");
     end

     if(uvm_config_db #(int unsigned)::get(null, " ", "max_rd_req", max_rd_req)) begin
       `uvm_info("body", $sformatf("ENV_SEQ: max_rd_req %d ", max_rd_req), UVM_LOW);
     end
     else begin
        max_rd_req   = 3'b000;
     end

     if(uvm_config_db #(int unsigned)::get(null, " ", "max_pl_size", max_pl_size)) begin
        `uvm_info("body", $sformatf("ENV_SEQ: max_pl_size %d ", max_pl_size), UVM_LOW);
     end
     else begin
        max_pl_size  = 3'b001;    // Setting to 512 as DUT supports 512 as max. MAke this part of CONFIG class. 'b010 - 512 'b000 - 128 'b001 - 256
     end
      
      //SSS  max_pl_size  = 3'b010;    // Setting to 512 as DUT supports 512 as max. MAke this part of CONFIG class. 'b010 - 512 'b000 - 128 'b001 - 256
      dev_ctl_data = {16'h0, 0, max_rd_req, 4'h0, max_pl_size, 5'b01111};

      pf0_bar0     = `PF0_BAR0;  
      pf1_bar0     = `PF1_BAR0;
      pf2_bar0     = `PF2_BAR0;
      pf3_bar0     = `PF3_BAR0;
      pf4_bar0     = `PF4_BAR0;
      pf1_vf0_bar0 = `PF1_VF0_BAR0;
      pf2_vf0_bar0 = `PF2_VF0_BAR0;
      pf2_vf1_bar0 = `PF2_VF1_BAR0;

      pci_ctl      = 32'h0506; //disable legacy interrupt, enable Mem space and bus master Enable SERR

      ////////////////////////////////////////////////////////

      `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring PF = 0"),UVM_LOW)
      cfg_wr(0, 'h078, dev_ctl_data);
      cfg_wr(0, 'h010, pf0_bar0);
      cfg_wr(0, 'h054, root_dma_msi_addr[31:0]);
      cfg_wr(0, 'h0B0, 32'h8000_0000);
      cfg_wr(0, 'h058, msi_msgdata);
      cfg_rd(0, 'h050, rdata);
      msi_ctl = rdata;
      msi_ctl[16] = (pci_ctl[10] == 1'b1)? 1 : 0;
      cfg_wr(0, 'h050, msi_ctl);
      cfg_wr(0, 'h004, pci_ctl);
      cfg_rd(0, 'h078, rdata);
      dev_ctl = rdata;
      dev_ctl =  dev_ctl | 'h0000_000f;
      cfg_wr(0, 'h078, dev_ctl);


// PF1

      for(int pf_no=1;pf_no<`NUM_PFS;pf_no++)begin
        `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring PF = %0d",pf_no),UVM_LOW)
        cfg_wr(pf_no, 'h078, dev_ctl_data);
        if(pf_no==1) cfg_wr(pf_no, 'h010, pf1_bar0);
        if(pf_no==2) cfg_wr(pf_no, 'h010, pf2_bar0);
        if(pf_no==3) cfg_wr(pf_no, 'h010, pf3_bar0);
        if(pf_no==4) cfg_wr(pf_no, 'h010, pf4_bar0);
        cfg_wr(pf_no, 'h054, root_dma_msi_addr[31:0]);
        cfg_wr(pf_no, 'h0B0, 32'h8000_0000);
        cfg_wr(pf_no, 'h058, msi_msgdata);
        cfg_wr(pf_no, 'h050, msi_ctl);
        cfg_wr(pf_no, 'h004, pci_ctl);
     
        if(pf_no inside {1,2})begin   
          bit[15:0] sriov_offset = 'h230;
          `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring VFs for PF = %0d",pf_no),UVM_LOW)
          cfg_rd(pf_no, (sriov_offset+'h4), rdata); //Read SRIOV Cap register
          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          //rdata[0] = 1;//Enable VF
          //rdata[3] = 1;//Enable MSE
          rdata[4] = 1;//Enable ARI
          cfg_wr(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control

          cfg_rd(pf_no, (sriov_offset+'hC), rdata); // Total VF
          cfg_rd(pf_no, (sriov_offset+'h10), rdata); // Num VF
          cfg_rd(pf_no, (sriov_offset+'h14), rdata); // VF Stride and First Offset
          cfg_rd(pf_no, (sriov_offset+'h18), rdata); // VF Device ID
          cfg_rd(pf_no, (sriov_offset+'h1C), rdata); // Supported Page Size
          cfg_rd(pf_no, (sriov_offset+'h20), rdata); // System Page Size

          //Set VFs
          cfg_rd(pf_no, (sriov_offset+'h10), rdata); // Num VF
           if(pf_no==1)num_vfs = 'h1;
           if(pf_no==2)num_vfs = 'h2;
          `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring num_vfs=%0d VFs for PF = %0d",num_vfs, pf_no),UVM_LOW)
          rdata = {rdata[31:16], num_vfs};
          cfg_wr(pf_no, (sriov_offset+'h10), rdata); // Configure Num VF
          cfg_rd(pf_no, (sriov_offset+'h10), rdata); // Num VF

          // Set VF0 Bar0
          if(pf_no == 1)cfg_wr(pf_no, (sriov_offset+'h24), pf1_vf0_bar0);//VF0 BAR0
          if(pf_no == 2)cfg_wr(pf_no, (sriov_offset+'h24), pf2_vf0_bar0);//VF0 BAR0
          cfg_rd(pf_no, (sriov_offset+'h24), rdata);
          if(pf_no==1)`uvm_info(get_name(), $psprintf("SDEBUG enum: pf1_vf0_bar0=%0h rdata=%0h",pf1_vf0_bar0,rdata),UVM_LOW)
          if(pf_no==2)`uvm_info(get_name(), $psprintf("SDEBUG enum: pf2_vf0_bar0=%0h rdata=%0h",pf2_vf0_bar0,rdata),UVM_LOW)

          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          rdata[0] = 1;//Enable VF
          rdata[3] = 1;//Enable MSE
          cfg_wr(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          `uvm_info(get_name(), $psprintf("SDEBUG enum: Enable VF in SRIOV Control Status Reg rdata=%0h VF Enable=%0d MSE Enable=%0d",rdata,rdata[0],rdata[3]),UVM_LOW)
          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control

        end

        // Enable bus master
        cfg_wr(pf_no, 'h004, pci_ctl);
      end



      ////////////////////////////////////////////////////////

    `uvm_info("body", "SDEBUG enum: Exiting Enumerating...", UVM_LOW)
  endtask: body

  task cfg_rd(input int addr, input int reg_num, output bit [31:0] data);
      `PCIE_DRIVER_TRANSACTION_CLASS cfg_seq;

      `uvm_create(cfg_seq)
      cfg_seq.cfg                 = cfg;
      cfg_seq.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_RD;
      cfg_seq.address             = addr;
      cfg_seq.register_number     = reg_num/4;
      cfg_seq.length              = 1;
      cfg_seq.traffic_class       = 0;
      cfg_seq.address_translation = 0;
      cfg_seq.first_dw_be         = 4'b1111;
      cfg_seq.last_dw_be          = 4'b0000;
      cfg_seq.ep                  = 0;
      cfg_seq.block               = 1;
      cfg_seq.payload             = new[cfg_seq.length];
      `uvm_send(cfg_seq)
      get_response(cfg_seq);

      data = cfg_seq.payload[0];

      `uvm_info("ENUM", $sformatf("Read from addr %0h reg_num = %0h data = %8h", addr, reg_num, cfg_seq.payload[0]), UVM_LOW);

  endtask : cfg_rd

  task cfg_wr(input int addr, input int reg_num, input bit [31:0] data);
      `PCIE_DRIVER_TRANSACTION_CLASS cfg_seq;
      `uvm_create(cfg_seq)
      cfg_seq.cfg                 = cfg;
      cfg_seq.transaction_type    = `PCIE_DRIVER_TRANSACTION_CLASS::CFG_WR;
      cfg_seq.address             = addr;
      cfg_seq.register_number     = reg_num/4;
      cfg_seq.length              = 1;
      cfg_seq.traffic_class       = 0;
      cfg_seq.address_translation = 0;
      cfg_seq.first_dw_be         = 4'b1111;
      cfg_seq.last_dw_be          = 4'b0000;
      cfg_seq.ep                  = 0;
      cfg_seq.block               = 1;
      cfg_seq.payload             = new[cfg_seq.length];
      foreach (cfg_seq.payload[i]) begin
         cfg_seq.payload[i]        = data;
      end
      `uvm_send(cfg_seq)
      get_response(cfg_seq);
      `uvm_info("ENUM", $sformatf("Write to addr %0h reg_num = %0h data = %8h", addr, reg_num, data), UVM_LOW);

  endtask : cfg_wr

endclass: enumerate_seq

//`endif //GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV

