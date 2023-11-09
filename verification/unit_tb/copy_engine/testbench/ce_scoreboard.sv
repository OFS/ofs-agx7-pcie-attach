// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef CE_SCOREBOARD
`define CE_SCOREBOARD

`uvm_analysis_imp_decl(_pcie_port_tx)
`uvm_analysis_imp_decl(_pcie_port_rx)
`uvm_analysis_imp_decl(_axi_port_rx)

class ce_scoreboard extends uvm_scoreboard;

`PCIE_DL_TLP_MON_TRANSACTION pcie_tx_pkt; 
`PCIE_DL_TLP_MON_TRANSACTION pcie_mwr_pkt; 
`PCIE_DL_TLP_MON_TRANSACTION pcie_rx_pkt; 
`AXI_TRANSACTION_CLASS axi_trans;

bit [31:0] obs_addr_q[$];
bit [31:0] exp_addr_q[$];
bit [31:0] dst_addr;
bit [31:0] drl_limt;
bit [31:0] desc_size;
bit[511:0] axi_payload_q[$];
bit[511:0] pci_payload_q[$];
bit[511:0] axi_payload1;
bit[511:0] axi_payload2;
bit[31:0] awlength;
bit [1:0] cnt= 1;

   `uvm_component_utils(ce_scoreboard)
   //port from pcie vip
   uvm_analysis_imp_pcie_port_tx#(`PCIE_DL_TLP_MON_TRANSACTION, ce_scoreboard) pcie_port_tx;
   uvm_analysis_imp_pcie_port_rx#(`PCIE_DL_TLP_MON_TRANSACTION, ce_scoreboard) pcie_port_rx;
   //port from ACE LITE ENV
   uvm_analysis_imp_axi_port_rx#(`AXI_TRANSACTION_CLASS, ce_scoreboard) axi_port_rx;

   //TLM FIFO for pcie and axi

   uvm_tlm_analysis_fifo #(`PCIE_DL_TLP_MON_TRANSACTION) pcie_tx_fifo;
   uvm_tlm_analysis_fifo #(`PCIE_DL_TLP_MON_TRANSACTION) pcie_rx_fifo;
   uvm_tlm_analysis_fifo #(`AXI_TRANSACTION_CLASS) axi_fifo;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      pcie_port_tx = new("pcie_port_tx", this);
      pcie_port_rx = new("pcie_port_rx", this);
      axi_port_rx  = new("axi_port_rx", this);
      pcie_rx_fifo = new("pcie_rx_fifo", this);
      pcie_tx_fifo = new("pcie_tx_fifo", this);
      axi_fifo     = new("axi_fifo", this);
   endfunction : build_phase


   virtual function void write_pcie_port_tx(`PCIE_DL_TLP_MON_TRANSACTION trans);
   $cast(pcie_tx_pkt,trans.clone());   
   //check whether it is a comletion. TX mode check for that only.
   if (pcie_tx_pkt.tlp.fmt == 3'b010 && pcie_tx_pkt.tlp.tlp_type == 5'b0_1010)
   begin
     pcie_tx_fifo.write(pcie_tx_pkt); 
    `uvm_info(get_type_name(),$sformatf(" SCB::  Completion Pkt transmitted by PCIe VIP \n %s",pcie_tx_pkt.sprint()),UVM_LOW)
   end
   else if(pcie_tx_pkt.tlp.tlp_type == 5'b0_0000 && pcie_tx_pkt.tlp.fmt != 3'b000 && pcie_tx_pkt.tlp.fmt != 3'b001 ) begin
      if (pcie_tx_pkt.tlp.address[31:0] == 'he0000108) begin
         `uvm_info(get_type_name(),$sformatf(" SCB:: MWR Pkt transmitted by PCIe VIP for DRL LIMT \n %s",pcie_tx_pkt.sprint()),UVM_LOW)
         drl_limt = changeEndian(pcie_tx_pkt.tlp.payload[0]);
      end
      else if (pcie_tx_pkt.tlp.address[31:0] == 'he0000118) begin
         `uvm_info(get_type_name(),$sformatf(" SCB:: MWR Pkt transmitted by PCIe VIP for DST ADDR \n %s",pcie_tx_pkt.sprint()),UVM_LOW)
         dst_addr = changeEndian(pcie_tx_pkt.tlp.payload[0]);
      end
      else if (pcie_tx_pkt.tlp.address[31:0] == 'he0000120) begin
         `uvm_info(get_type_name(),$sformatf(" SCB:: MWR Pkt transmitted by PCIe VIP for DESC SIZE \n %s",pcie_tx_pkt.sprint()),UVM_LOW)
         desc_size = changeEndian(pcie_tx_pkt.tlp.payload[0]);
         calc_exp_addr (dst_addr, desc_size, drl_limt);
      end
   end
   endfunction :write_pcie_port_tx

   // Not used
   virtual function void write_pcie_port_rx(`PCIE_DL_TLP_MON_TRANSACTION trans);
   $cast(pcie_rx_pkt,trans.clone());   
   if (pcie_rx_pkt.tlp.fmt == 3'b010 && pcie_rx_pkt.tlp.tlp_type == 5'b0_1010)
   begin
    pcie_rx_fifo.write(pcie_rx_pkt); 
    //`uvm_info(get_type_name(),$sformatf(" SCB::  Completion Pkt by PCIe VIP \n %s",pcie_rx_pkt.sprint()),UVM_LOW)
    end 
  endfunction :write_pcie_port_rx

  virtual function void write_axi_port_rx(`AXI_TRANSACTION_CLASS trans);
    $cast(axi_trans , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from ACE Lite slave ENV \n %s",axi_trans.sprint()),UVM_LOW)
    
    if((axi_trans.xact_type == (`AXI_TRANSACTION_CLASS::COHERENT)) && (axi_trans.transmitted_channel == (`AXI_TRANSACTION_CLASS::WRITE)))begin
      axi_fifo.write(axi_trans); 
    end
  endfunction :write_axi_port_rx

   function calc_exp_addr ( logic [31:0] dst_addr, logic [31:0] desc_size, logic [31:0] drl_limt ); 
      bit [31:0] size;
      bit [31:0] addr;
      bit [31:0] addr_cnt;
      bit [1:0]  drl;
      size = desc_size;
      addr = dst_addr;
      drl = drl_limt[1:0];
      case(drl) 
         'b01 : begin
                  if(size%128==0)
                  addr_cnt = size/128;
                  else
                  addr_cnt=(size/128)+1;
                end  
         'b10 : begin
                  if(size%512==0)
                  addr_cnt = size/512;
                  else
                  addr_cnt=(size/512)+1;
                end  
         'b11 : begin
                  if(size%1024==0)
                  addr_cnt = size/1024;
                  else
                  addr_cnt=(size/1024)+1;
                end  
          default : begin
                      if(size%1024==0)
                      addr_cnt = size/1024;
                      else
                      addr_cnt = (size/1024)+1;
                    end
      endcase
      //size = desc_size/64;    
      `uvm_info(get_type_name(),$sformatf(" SIZE OF DESC\n %h",size),UVM_LOW)
      `uvm_info(get_type_name(),$sformatf(" DRL LIMIT\n %h",drl),UVM_LOW)
      `uvm_info(get_type_name(),$sformatf(" DEST_ADDR\n %h",addr),UVM_LOW)
      `uvm_info(get_type_name(),$sformatf(" ADDR_CNT\n %h",addr_cnt),UVM_LOW)

      for (int i=0; i< addr_cnt; i=i+1) begin
         if (i == 0 ) begin
           exp_addr_q.push_back(addr);
         end
         else begin
            case (drl)
             2'b01  : begin
                        addr = addr + 'h80; 
                        exp_addr_q.push_back(addr);
                      end
             2'b10  : begin
                        addr = addr + 'h200; 
                        exp_addr_q.push_back(addr);
                      end
             2'b11  : begin
                        addr = addr + 'h400; 
                        exp_addr_q.push_back(addr);
                      end
             default  : begin
                        addr = addr + 'h400; 
                        exp_addr_q.push_back(addr);
                      end
            endcase
         end
      end
   endfunction : calc_exp_addr

  task run_phase(uvm_phase phase);
     `PCIE_DL_TLP_MON_TRANSACTION pcie_cmp_pkt; 
     `AXI_TRANSACTION_CLASS axi_cmp_pkt;

     //bit[1023:0] payload;
     bit[511:0] payload;
     int i, j, tx_fifo_size,ax_fifo;
     bit [31:0] header;
     super.run_phase(phase);

     forever begin
        pcie_tx_fifo.get(pcie_cmp_pkt);
        if((pcie_cmp_pkt.tlp.fmt == `PCIE_TLP_CLASS::WITH_DATA_3_DWORD) || (pcie_cmp_pkt.tlp.fmt == `PCIE_TLP_CLASS::WITH_DATA_4_DWORD)) 
        begin
             header = pcie_cmp_pkt.tlp.tlp_dword_array[0];
             `uvm_info("ce_scoreboard", $sformatf("HEADER: `h%h", header), UVM_LOW);
             case(header[7:0])
             'h10 : begin // Length  64B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 
                    end
             'h20 : begin // Length  128B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;   
                      for (i=16; i<=31; i= i+1) begin
                        j = i-16;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 
                    end
             'h30 : begin // Length  192B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;   
                      for (i=16; i<=31; i= i+1) begin
                        j = i-16;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=32; i<=47; i= i+1) begin
                        j = i-32;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 
                    end
             'h40 : begin // Length  256B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;   
                      for (i=16; i<=31; i= i+1) begin
                        j = i-16;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=32; i<=47; i= i+1) begin
                        j = i-32;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=48; i<=63; i= i+1) begin
                        j = i-48;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 
                    end
             'h80 : begin // Length 512B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;   
                      for (i=16; i<=31; i= i+1) begin
                        j = i-16;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=32; i<=47; i= i+1) begin
                        j = i-32;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=48; i<=63; i= i+1) begin
                        j = i-48;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=64; i<=79; i= i+1) begin
                        j = i-64;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=80; i<=95; i= i+1) begin
                        j = i-80;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=96; i<=111; i= i+1) begin
                        j = i-96;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=112; i<=127; i= i+1) begin
                        j = i-112;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                    end
             'h100 : begin // Length 1024B
                      for (i=0; i<=15; i= i+1) begin
                        payload[i*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;   
                      for (i=16; i<=31; i= i+1) begin
                        j = i-16;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=32; i<=47; i= i+1) begin
                        j = i-32;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=48; i<=63; i= i+1) begin
                        j = i-48;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=64; i<=79; i= i+1) begin
                        j = i-64;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=80; i<=95; i= i+1) begin
                        j = i-80;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=96; i<=111; i= i+1) begin
                        j = i-96;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=112; i<=127; i= i+1) begin
                        j = i-112;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=128; i<=143; i= i+1) begin
                        j = i-128;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 


                      j=0;     
                      for (i=144; i<=159; i= i+1) begin
                        j = i-144;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 


                      j=0;     
                      for (i=160; i<=175; i= i+1) begin
                        j = i-160;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=176; i<=191; i= i+1) begin
                        j = i-176;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=192; i<=207; i= i+1) begin
                        j = i-192;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=208; i<=223; i= i+1) begin
                        j = i-208;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 


                      j=0;     
                      for (i=224; i<=239; i= i+1) begin
                        j = i-224;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 

                      j=0;     
                      for (i=240; i<=255; i= i+1) begin
                        j = i-240;
                        payload[j*32+:32] = changeEndian(pcie_cmp_pkt.tlp.payload[i]);
                      end
                      pci_payload_q.push_back(payload);
                      `uvm_info("ce_scoreboard", $sformatf("PAYLOAD: `h%h", payload), UVM_LOW); 
                    end
             endcase
        end

        // For Non burst mode
        //if (cnt == 1 ) begin
        //   axi_fifo.get(axi_cmp_pkt);
        //   if(axi_cmp_pkt.transmitted_channel == (`AXI_TRANSACTION_CLASS::WRITE)) begin
        //       axi_payload1 = axi_cmp_pkt.data[0];
        //       `uvm_info("ce_scoreboard", $sformatf("AXI FIRST PAYLOAD: `h%h", axi_payload1), UVM_LOW); 
        //       cnt = cnt +1;
        //       obs_addr_q.push_back(axi_cmp_pkt.addr); 
        //       compare_addr();
        //    end
        //end
        //else if (cnt == 2) begin
        //   axi_fifo.get(axi_cmp_pkt);
        //   if(axi_cmp_pkt.transmitted_channel == (`AXI_TRANSACTION_CLASS::WRITE)) begin
        //       axi_payload2 = axi_cmp_pkt.data[0];
        //       `uvm_info("ce_scoreboard", $sformatf("AXI SECON PAYLOAD: `h%h", axi_payload2), UVM_LOW); 
        //       axi_payload_q.push_back({axi_payload2,axi_payload1});
        //       `uvm_info("ce_scoreboard", $sformatf("AXI PAYLOAD: `h%h", {axi_payload2,axi_payload1}), UVM_LOW); 
        //       compare_data();
        //       cnt = 1; 
        //       obs_addr_q.push_back(axi_cmp_pkt.addr); 
        //       compare_addr();
        //    end
        //end

        
        // For Burst mode
        axi_fifo.get(axi_cmp_pkt);
        if(axi_cmp_pkt.transmitted_channel == (`AXI_TRANSACTION_CLASS::WRITE)) begin
          awlength = axi_cmp_pkt.burst_length;
          for (i=0; i<=awlength-1; i= i+1) begin
            axi_payload_q.push_back(axi_cmp_pkt.data[i]);
           `uvm_info("ce_scoreboard", $sformatf("AXI PAYLOAD: `h%h", axi_cmp_pkt.data[i]), UVM_LOW); 
          end
          compare_data();
          obs_addr_q.push_back(axi_cmp_pkt.addr); 
          compare_addr();
         end
     end
  endtask : run_phase


  //Change endianless of payload 
  function [31:0] changeEndian;   //transform data from the memory to big-endian form
    input [31:0] value;
    changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
  endfunction

   // Compare PCIE DATA with AXI DATA
   function compare_data;
     bit [511:0] exp_data, obs_data;     
       if (pci_payload_q.size()!=0 && axi_payload_q.size()!=0) begin
          `uvm_info(get_type_name(),$sformatf(" PCI DATA SIZE = \n %h",pci_payload_q.size()),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf(" AXI DATA SIZE = \n %h",axi_payload_q.size()),UVM_LOW)
          exp_data = pci_payload_q.pop_front();
          obs_data = axi_payload_q.pop_front();
          if (exp_data == obs_data) begin
             `uvm_info(get_type_name(),$sformatf("HPS DATA MATCHED EXP_DATA = 'h%h: OBS_DATA = `h%h", exp_data, obs_data),UVM_LOW);
          end 
          else begin
             `uvm_error("ce_scoreboard", $sformatf("HPS DATA MISMATCHED EXP_DATA = `h%h, OBS_DATA = `h%h ",exp_data, obs_data));
          end
       end
   endfunction : compare_data

   // Compare AXI ADDR
   function compare_addr;
     bit [31:0] exp_addr, obs_addr;     
       if (exp_addr_q.size()!=0 && obs_addr_q.size()!=0) begin
          `uvm_info(get_type_name(),$sformatf(" EXP ADDR SIZE = \n %h",exp_addr_q.size()),UVM_LOW)
          `uvm_info(get_type_name(),$sformatf(" OBS ADDR SIZE = \n %h",obs_addr_q.size()),UVM_LOW)
          exp_addr = exp_addr_q.pop_front();
          obs_addr = obs_addr_q.pop_front();
          if (exp_addr == obs_addr) begin
             `uvm_info(get_type_name(),$sformatf("HPS ADDR MATCHED EXP_ADDR = 'h%h: OBS_ADDR = `h%h", exp_addr, obs_addr),UVM_LOW);
          end 
          else begin
             `uvm_error("ce_scoreboard", $sformatf("HPS ADDR MISMATCHED EXP_ADDR = `h%h, OBS_ADDR = `h%h ",exp_addr, obs_addr));
          end
       end
   endfunction : compare_addr



endclass : ce_scoreboard


`endif // CE_SCOREBOARD
