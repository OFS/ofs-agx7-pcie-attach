// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

//`ifndef GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV
//`define GUARD_PCIE_DRIVER_TRANSACTION_DIRECTED_SEQUENCE_SV


class enumerate_seq extends `PCIE_DRIVER_TRANSACTION_BASE_SEQ_CLASS; 

 `include "pcie_hip_defines.svh"
   bit[31:0]   dev_ctl_data, dev_ctl2_data, pci_ctl;
   rand bit[63:0]   pf0_bar0, pf0_bar4, pf1_bar0, pf2_bar0, pf2_bar4, pf3_bar0,pf4_bar0, pf0_expansion_rom_bar;
   rand bit[63:0]   pf0_vf0_bar0, pf0_vf0_bar4, pf0_vf1_bar0, pf0_vf2_bar0, pf1_vf0_bar0;
   bit[2:0]    max_rd_req, max_pl_size;
   bit[3:0]    enable_tag_5, enable_tag_8;
   bit[63:0]   root_dma_msi_addr;
   bit[31:0]   msi_msgdata;
   bit[15:0]   num_vfs;
   bit[31:0]   vf_page_size = 32'h1;
   static bit[31:0]   vf_size_index = 32'h0;
   bit[31:0]   pf0_idx = 32'h0;
 
   `PCIE_DEV_CFG_CLASS cfg;

`ifdef FIM_B
   rand bit[63:0]   pf0_vf3_bar0;
`endif     

   //MMIO Address offsets are 20 bits so setting those bits 0
   constraint bar_c {
     pf0_bar0[19:0] == 0;
     pf0_bar4[19:0] == 0;
     pf1_bar0[19:0] == 0;
     pf2_bar0[19:0] == 0;
     pf2_bar4[19:0] == 0;
     pf3_bar0[19:0] == 0;
     pf4_bar0[19:0] == 0;
     pf0_expansion_rom_bar[16:0] == 0;
     pf0_expansion_rom_bar[63:32] == 0; //32 Bit BAR
     pf0_vf0_bar0[19:0] == 0;
     pf0_vf0_bar4[19:0] == 0;
     pf0_vf1_bar0[19:0] == 0;
     pf0_vf2_bar0[19:0] == 0;
     pf1_vf0_bar0[19:0] == 0;
`ifdef FIM_B
     pf0_vf3_bar0[19:0] == 0;
`endif         
  }

  `uvm_object_utils_begin(enumerate_seq)
      `uvm_field_int(dev_ctl_data, UVM_DEFAULT)
      `uvm_field_int(dev_ctl2_data, UVM_DEFAULT)
      `uvm_field_int(pci_ctl, UVM_DEFAULT)
      `uvm_field_int(pf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf0_bar4, UVM_DEFAULT)
      `uvm_field_int(pf0_vf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf0_vf0_bar4, UVM_DEFAULT)
      `uvm_field_int(pf0_vf1_bar0, UVM_DEFAULT)
      `uvm_field_int(pf0_vf2_bar0, UVM_DEFAULT)
      `uvm_field_int(pf1_bar0, UVM_DEFAULT)
      `uvm_field_int(pf1_vf0_bar0, UVM_DEFAULT)
      `uvm_field_int(pf2_bar0, UVM_DEFAULT)
      `uvm_field_int(pf2_bar4, UVM_DEFAULT)
      `uvm_field_int(pf3_bar0, UVM_DEFAULT)
      `uvm_field_int(pf4_bar0, UVM_DEFAULT)
      `uvm_field_int(pf0_expansion_rom_bar, UVM_DEFAULT)
`ifdef FIM_B
      `uvm_field_int(pf0_vf3_bar0, UVM_DEFAULT)
`endif       
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
     int vf_num_start;

     `uvm_info("body", "SDEBUG enum: Entered Enumerating...", UVM_LOW)

     super.body();

     //Obtain a handle to the port configuration 
     p_sequencer.get_cfg(get_cfg);
     if (!$cast(cfg, get_cfg)) begin
        `uvm_fatal("body", "Unable to $cast the configuration class");
     end

	if(uvm_config_db #(int unsigned)::get(null, " ", "max_rd_req", max_rd_req)) begin
	 	`uvm_info("body", $sformatf("ENV_SEQ: max_rd_req %d ", max_rd_req), UVM_LOW);
	end
	else begin
	max_rd_req   = 3'b010;  // Default to 512 bytes
	end
      max_pl_size  = 3'b010;    // Setting to 512 as DUT supports 512 as max. MAke this part of CONFIG class. 'b010 - 512 'b000 - 128 'b001 - 256
     
        if(uvm_config_db #(int unsigned)::get(null, " ", "enable_tag_5", enable_tag_5)) begin
        dev_ctl_data = {16'h0, 0, max_rd_req, 3'h0, 1'b0, max_pl_size, 5'b01111}; // Ext tag disable bit 8
        `uvm_info("TAG_INFO",$sformatf("5 bit tag enabled"), UVM_LOW)
	end
	else begin
        dev_ctl_data = {16'h0, 0, max_rd_req, 3'h0, 1'b1, max_pl_size, 5'b01111}; // Ext tag enable bit 8
    end

      pci_ctl      = 32'h0506; //disable legacy interrupt, enable Mem space and bus master Enable SERR

      ////////////////////////////////////////////////////////



      for(int pf_no=0;pf_no<`NUM_PFS;pf_no++)begin
        `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring PF = %0d",pf_no),UVM_LOW)
        cfg_wr(pf_no, 'h078, dev_ctl_data);
        cfg_rd(pf_no, 'h078, rdata);
        `uvm_info(get_name(), $psprintf("SDEBUG enum: dev_ctl_data = %0h PF = %0d",rdata, pf_no),UVM_LOW)

	//Enable 10bit Extended tag
        cfg_rd(pf_no, 'h098, rdata);
         if(uvm_config_db #(int unsigned)::get(null, " ", "enable_tag_8", enable_tag_8)) begin
          dev_ctl2_data =  rdata | 'h0000_0000; //12th bit set to 0 for enabling 8 bit tag
          `uvm_info("TAG_INFO",$sformatf("8 bit tag enabled"), UVM_LOW)
        end
        else begin
           dev_ctl2_data =  rdata | 'h0000_1000; //12th bit set to 1 for 10bit extended tag
       end
 
        cfg_wr(pf_no, 'h098, dev_ctl2_data);        
        cfg_rd(pf_no, 'h098, rdata);
        `uvm_info(get_name(), $psprintf("SDEBUG enum: dev_ctl2_data = %0h PF = %0d",rdata, pf_no),UVM_LOW)

        if(pf_no==0) cfg_wr(0, 'h010, pf0_bar0[31:0]);
        if(pf_no==0 && pf0_bar0[63:32]!=0) cfg_wr(0, 'h014, pf0_bar0[63:32]);

        if(pf_no==0) cfg_wr(0, 'h020, pf0_bar4[31:0]);
        if(pf_no==0 && pf0_bar4[63:32]!=0) cfg_wr(0, 'h024, pf0_bar4[63:32]);

        if(pf_no==1) cfg_wr(pf_no, 'h010, pf1_bar0[31:0]);
        if(pf_no==1 && pf1_bar0[63:32]!=0) cfg_wr(pf_no, 'h014, pf1_bar0[63:32]);

        if(pf_no==2) cfg_wr(pf_no, 'h010, pf2_bar0[31:0]);
        if(pf_no==2 && pf2_bar0[63:32]!=0) cfg_wr(pf_no, 'h014, pf2_bar0[63:32]);

        if(pf_no==2) cfg_wr(pf_no, 'h020, pf2_bar4[31:0]);
        if(pf_no==2 && pf2_bar4[63:32]!=0) cfg_wr(pf_no, 'h024, pf2_bar4[63:32]);

        if(pf_no==3) cfg_wr(pf_no, 'h010, pf3_bar0[31:0]);
        if(pf_no==3 && pf3_bar0[63:32]!=0) cfg_wr(pf_no, 'h014, pf3_bar0[63:32]);

        if(pf_no==4) cfg_wr(pf_no, 'h010, pf4_bar0[31:0]);
        if(pf_no==4 && pf4_bar0[63:32]!=0) cfg_wr(pf_no, 'h014, pf4_bar0[63:32]);

        if(pf_no==0) cfg_wr(0, 'h038, pf0_expansion_rom_bar[31:0]);//32 Bit BAR

        cfg_wr(pf_no, 'h054, root_dma_msi_addr[31:0]);
        cfg_wr(pf_no, 'h0B0, 32'h8000_0000);// Enable MSI-X Cap
        cfg_wr(pf_no, 'h058, msi_msgdata);
        if(pf_no == 0)begin
           cfg_rd(0, 'h050, rdata);
           msi_ctl = rdata;
           msi_ctl[16] = (pci_ctl[10] == 1'b1)? 1 : 0;
        end
        cfg_wr(pf_no, 'h050, msi_ctl);
        cfg_wr(pf_no, 'h004, pci_ctl);
        if(pf_no == 0)begin
          cfg_rd(0, 'h078, rdata);
          dev_ctl = rdata;
          dev_ctl =  dev_ctl | 'h0000_000f;
          cfg_wr(0, 'h078, dev_ctl);        
        end     

        if(pf_no inside {0,1})begin
          `ifdef FTILE_SIM   
            bit[15:0] sriov_offset = 'h22c;
           `else
            bit[15:0] sriov_offset = 'h230;
          `endif
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
          `uvm_info(get_name(), $psprintf("SDEBUG enum: VF Supported_PAGE_SIZE =%d  for PF = %0d",rdata, pf_no),UVM_LOW)
          cfg_rd(pf_no, (sriov_offset+'h20), rdata); // System Page Size
          `uvm_info(get_name(), $psprintf("SDEBUG enum: VFSYSTEAM_PAGE_SIZE =%d  for PF = %0d",rdata, pf_no),UVM_LOW)

          //Set VFs
          cfg_rd(pf_no, (sriov_offset+'h10), rdata); // Num VF
	   
	`ifdef FIM_B
           if(pf_no==0)num_vfs = 'h4;
	`else	   
           if(pf_no==0)num_vfs = 'h3;
	`endif
	   
           if(pf_no==1)num_vfs = 'h1;
          `uvm_info(get_name(), $psprintf("SDEBUG enum: Configuring num_vfs=%0d VFs for PF = %0d",num_vfs, pf_no),UVM_LOW)
          rdata = {rdata[31:16], num_vfs};
          cfg_wr(pf_no, (sriov_offset+'h10), rdata); // Configure Num VF
          cfg_rd(pf_no, (sriov_offset+'h10), rdata); // Num VF

         if(pf_no == 0) begin
          cfg_wr(pf_no, (sriov_offset+'h24), 32'hffff_ffff);
          cfg_rd(pf_no, (sriov_offset+'h24), rdata);
          `uvm_info(get_name(), $psprintf("SDEBUG enum:RDATA VF_BAR0 =%d  for PF = %0d",rdata, pf_no),UVM_LOW)
          for(int i = 31; i >= 0; i--) begin
              if(!rdata[i]) begin
                  pf0_idx = i + 1;
                  break;
              end
          end
          //$display("Yang vf size = %0h", 2**pf0_idx);
          //if(pf0_idx == 12) vf_page_size = 32'h1;
          vf_size_index = pf0_idx;
          `uvm_info(get_name(), $psprintf("SDEBUG enum: CALCULATED_PAGE_SIZE =%d  for PF = %0d",pf0_idx, pf_no),UVM_LOW)

        
         end

      

          // Set VF0 Bar0
          if(pf_no == 0) begin
            cfg_wr(pf_no, (sriov_offset+'h24), pf0_vf0_bar0[31:0]);//VF0 BAR0
            if(pf0_vf0_bar0[63:32]!=0)cfg_wr(pf_no, (sriov_offset+'h24+4), pf0_vf0_bar0[63:32]);//VF0 BAR0

            cfg_wr(pf_no, (sriov_offset+'h34), pf0_vf0_bar4[31:0]);//VF0 BAR4
            if(pf0_vf0_bar4[63:32]!=0)cfg_wr(pf_no, (sriov_offset+'h34+4), pf0_vf0_bar4[63:32]);//VF0 BAR4

            cfg_rd(pf_no, (sriov_offset+'h24), rdata);
            `uvm_info(get_name(), $psprintf("SDEBUG enum: pf0_vf0_bar0=%0h rdata=%0h",pf0_vf0_bar0,rdata),UVM_LOW)
            cfg_rd(pf_no, (sriov_offset+'h34), rdata);
            `uvm_info(get_name(), $psprintf("SDEBUG enum: pf0_vf0_bar4=%0h rdata=%0h",pf0_vf0_bar4,rdata),UVM_LOW)
          end
          else if(pf_no == 1) begin
            cfg_wr(pf_no, (sriov_offset+'h24), pf1_vf0_bar0[31:0]);//VF0 BAR0
            if(pf1_vf0_bar0[63:32]!=0)cfg_wr(pf_no, (sriov_offset+'h24+4), pf1_vf0_bar0[63:32]);//VF0 BAR0

            cfg_rd(pf_no, (sriov_offset+'h24), rdata);
            `uvm_info(get_name(), $psprintf("SDEBUG enum: pf1_vf0_bar0=%0h rdata=%0h",pf1_vf0_bar0,rdata),UVM_LOW)
          end

          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          rdata[0] = 1;//Enable VF
          rdata[3] = 1;//Enable MSE
          rdata[4] = 1;//??
          cfg_wr(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control
          `uvm_info(get_name(), $psprintf("SDEBUG enum: Enable VF in SRIOV Control Status Reg rdata=%0h VF Enable=%0d MSE Enable=%0d",rdata,rdata[0],rdata[3]),UVM_LOW)
          cfg_rd(pf_no, (sriov_offset+'h8), rdata); // SRIOV Status and Control

	  if(pf_no==0) begin
	    int vf_bdf = `NUM_PFS;
            `uvm_info(get_name(), $psprintf("SDEBUG enum: Enable Bus Master for PF%0d VF with BDF=%0d",pf_no,vf_bdf),UVM_LOW)
            cfg_wr(vf_bdf, 'h004, pci_ctl);// disable legacy interrupt, enable Mem space and bus master Enable SERR
            `uvm_info(get_name(), $psprintf("SDEBUG enum: Enable PF%0d VF with BDF=%0d MSIX Capability",pf_no,vf_bdf),UVM_LOW)
            cfg_wr(vf_bdf, 'h0B0, 32'h8000_0000);// Enable MSI-X Cap
          end
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

