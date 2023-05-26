// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef PMCI_SCOREBOARD
`define PMCI_SCOREBOARD

`uvm_analysis_imp_decl(_pcie_port_tx)
`uvm_analysis_imp_decl(_pcie_port_rx)
`uvm_analysis_imp_decl(_axi_port_rx)

class pmci_scoreboard extends uvm_scoreboard;

   `PCIE_DL_TLP_MON_TRANSACTION pcie_tx_pkt; 
   `PCIE_DL_TLP_MON_TRANSACTION pcie_mwr_pkt; 
   `PCIE_DL_TLP_MON_TRANSACTION pcie_rx_pkt; 
   `AXI_TRANSACTION_CLASS axi_trans;
   tb_config      tb_cfg0;
   
   
   bit [31:0] pldm_pcie_queue [$];
   bit [63:0] axi_cmp_data [$];
   bit [1:0] cnt= 1;
   bit [127:0] vdm_tx_header,vdm_rx_header;
   bit [31:0] vdm_tx_hdr1,vdm_tx_hdr2,vdm_tx_hdr3,vdm_tx_hdr4;
   bit [31:0] vdm_rx_hdr1,vdm_rx_hdr2,vdm_rx_hdr3,vdm_rx_hdr4;
   bit [31:0]  pkt_count,bmc_cnt;
   bit last_pkt_avl,odd_dw_set;
   reg [31:0] bmc_pld [255:0];
   bit [31:0] rem_len_ctr,len_ctr,fd,pcie_length;
   int pkt_mon_axi,pkt_mon_pcie_tx,pkt_mon_pcie_rx; 
   int axi_pkt_cnt,vdm_rx_cnt,vdm_tx_cnt;
   `uvm_component_utils(pmci_scoreboard)

   //port from pcie vip
   uvm_analysis_imp_pcie_port_tx#(`PCIE_DL_TLP_MON_TRANSACTION, pmci_scoreboard) pcie_port_tx;
   uvm_analysis_imp_pcie_port_rx#(`PCIE_DL_TLP_MON_TRANSACTION, pmci_scoreboard) pcie_port_rx;
   //port from AXI LITE ENV
   uvm_analysis_imp_axi_port_rx#(`AXI_TRANSACTION_CLASS, pmci_scoreboard) axi_port_rx;

   //TLM FIFO for pcie and axi
   uvm_tlm_analysis_fifo #(`PCIE_DL_TLP_MON_TRANSACTION) pcie_tx_fifo;
   uvm_tlm_analysis_fifo #(`PCIE_DL_TLP_MON_TRANSACTION) pcie_rx_fifo;
   uvm_tlm_analysis_fifo #(`AXI_TRANSACTION_CLASS) axi_fifo;

   function new(string name, uvm_component parent);
      super.new(name, parent);
      axi_pkt_cnt = 0;
      vdm_rx_cnt = 0;
      vdm_tx_cnt = 0;
      pkt_mon_axi = 0;
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      pcie_port_tx = new("pcie_port_tx", this);
      pcie_port_rx = new("pcie_port_rx", this);
      axi_port_rx = new("axi_port_rx", this);
      pcie_rx_fifo= new("pcie_rx_fifo", this);
      pcie_tx_fifo= new("pcie_tx_fifo", this);
      axi_fifo= new("axi_fifo", this);
   endfunction : build_phase


   virtual function void write_pcie_port_tx(`PCIE_DL_TLP_MON_TRANSACTION trans);
   $cast(pcie_tx_pkt,trans.clone());   
    if(pcie_tx_pkt.tlp.message_code==`PCIE_TLP_CLASS::VENDOR_DEFINED_1) begin
      pcie_tx_fifo.write(pcie_tx_pkt); 
      `uvm_info(get_type_name(),$sformatf(" SCB::  VDM Pkt transmitted by PCIe VIP \n %s",pcie_tx_pkt.sprint()),UVM_LOW)
    end
   endfunction :write_pcie_port_tx

   virtual function void write_pcie_port_rx(`PCIE_DL_TLP_MON_TRANSACTION trans);
   $cast(pcie_rx_pkt,trans.clone());   
    if(pcie_rx_pkt.tlp.message_code==`PCIE_TLP_CLASS::VENDOR_DEFINED_1) begin
      pcie_rx_fifo.write(pcie_rx_pkt);
      `uvm_info(get_type_name(),$sformatf(" SCB::  VDM Pkt recieved by PCIe VIP \n %s",pcie_rx_pkt.sprint()),UVM_LOW)
    end 
  endfunction :write_pcie_port_rx

  virtual function void write_axi_port_rx(`AXI_TRANSACTION_CLASS trans);
    $cast(axi_trans , trans.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from AXI Lite slave ENV \n %s",axi_trans.sprint()),UVM_LOW)
    axi_fifo.write(axi_trans); 
    pkt_mon_axi = pkt_mon_axi +1 ;
  endfunction :write_axi_port_rx
  
  
  task run_phase(uvm_phase phase);
     `PCIE_DL_TLP_MON_TRANSACTION pcie_tx_pkt_rcvd_temp; 
     `PCIE_DL_TLP_MON_TRANSACTION pcie_rx_pkt_rcvd_temp; 
     `AXI_TRANSACTION_CLASS axi_pkt_temp;

     super.run_phase(phase);
     forever begin  //two tasks one for RX and another for TX comparison
        if(tb_cfg0.has_tx_sb)begin
         mctp_tx_cmp_task(pcie_tx_pkt_rcvd_temp,axi_pkt_temp);
        end
        if(tb_cfg0.has_rx_sb)begin
         mctp_rx_cmp_task(pcie_rx_pkt_rcvd_temp,axi_pkt_temp);
        end
     end


   endtask:run_phase

   task mctp_tx_cmp_task(`PCIE_DL_TLP_MON_TRANSACTION pcie_tx_pkt_rcvd,`AXI_TRANSACTION_CLASS axi_pkt);
   begin
     

       if(pkt_count==0) begin
        //fd = $fopen("pcie_tx_out.txt","w+");
        pcie_tx_fifo.get(pcie_tx_pkt_rcvd);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3]),UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][7]),UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][6]),UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][5]),UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][4]),UVM_LOW);
        `uvm_info(get_type_name(),$sformatf("dword aryya for fd is %h",pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][3]),UVM_LOW);
        if(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][7]==1) begin
          fd = $fopen("pcie_tx_out.txt","w+");
        end


        if(pcie_tx_pkt_rcvd.tlp.message_code == `PCIE_TLP_CLASS::VENDOR_DEFINED_1) begin
          vdm_tx_cnt = vdm_tx_cnt +1;
          vdm_tx_hdr1=changeEndian(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[0]);
          vdm_tx_hdr2=changeEndian(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[1]);
          vdm_tx_hdr3=changeEndian(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[2]);
          vdm_tx_hdr4=changeEndian(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3]);
          vdm_tx_header= {vdm_tx_hdr4,vdm_tx_hdr3,vdm_tx_hdr2,vdm_tx_hdr1};
          pcie_length=pcie_tx_pkt_rcvd.tlp.length;
          for (int i =0;i<pcie_tx_pkt_rcvd.tlp.length;i++) begin
            pldm_pcie_queue.push_back(pcie_tx_pkt_rcvd.tlp.payload[i]);
            $fwrite(fd,"%h \n",pcie_tx_pkt_rcvd.tlp.payload[i]);
          end
        end
        if(pcie_tx_pkt_rcvd.tlp.tlp_dword_array[3][6]==1) begin
          $fclose(fd);
        end
       
       end


       axi_fifo.get(axi_pkt);
       if(pkt_count==0) begin   //First pkt indicates SOP
         `uvm_info(get_full_name(),$sformatf("SOP detected at BPF-PMCI I/F side.SOP is %h",axi_pkt.data[0]),UVM_LOW);
          axi_pkt_cnt = axi_pkt_cnt+1;
       end

       
       if(pkt_count>'h0 && axi_pkt.data[0]!==64'h0000_0000_0000_0002)begin //Data to be pushed into queue starting from Header(EOP is not considered).
         if(axi_pkt.wstrb[0]==8'hFF)begin
          axi_cmp_data.push_back(axi_pkt.data[0]);
         end
         else begin
            axi_cmp_data.push_back(32'(axi_pkt.data[0]));
         end
       end
       pkt_count=pkt_count+1;
       
       //-------Header Comparison---------------//
       if(pkt_count==3) begin
         hdr_cmp_pkt(); 
       end

       //--------PLDM Comparison----------------//
        if(pkt_count>3 && pkt_count<=3+((pcie_length+1)/2)) begin  //Total of 14 DW's 1-SOP+2-Header+8-PLDM+1-EOP
          pld_cmp_pkt();                                                         //Comparison not needed for SOP,EOP.
        end
       
       if(pkt_count==4+((pcie_length+1)/2)) begin   //Last pkt indicates EOP
         `uvm_info(get_full_name(),$sformatf("EOP detected at BPF-PMCI I/F side is %h",axi_pkt.data[0]),UVM_LOW);
          pkt_count='h0; //Pkt count cleared for multi packet
       end
       
   end
   endtask : mctp_tx_cmp_task
   
   task mctp_rx_cmp_task(`PCIE_DL_TLP_MON_TRANSACTION pcie_rx_pkt_rcvd,`AXI_TRANSACTION_CLASS axi_pkt);
   begin
     if(!last_pkt_avl) begin
       axi_fifo.get(axi_pkt);
       if(pkt_count==1) begin   //First pkt indicates SOP
         `uvm_info(get_full_name(),$sformatf("SOP detected at BPF-PMCI I/F side.SOP is %h",axi_pkt.data[0]),UVM_LOW);
          axi_pkt_cnt = axi_pkt_cnt +1;
       end

       
       if(pkt_count>'h1)begin //Data to be pushed into queue starting from Header.
         if(axi_pkt.data[0]==64'h0000_0000_0000_0002)begin //Indicates AXI received EOP 
           last_pkt_avl=1'h1;
           `uvm_info(get_full_name(),$sformatf("EOP detected at BPF-PMCI I/F side.EOP is %h",axi_pkt.data[0]),UVM_LOW);
         end
         else begin
           axi_cmp_data.push_back(axi_pkt.data[0]);
         end
       end
       pkt_count=pkt_count+1;

     end  
     if(last_pkt_avl) begin

        pcie_rx_fifo.get(pcie_rx_pkt_rcvd);


        if(pcie_rx_pkt_rcvd.tlp.message_code == `PCIE_TLP_CLASS::VENDOR_DEFINED_1) begin
          vdm_rx_cnt = vdm_rx_cnt + 1;
          vdm_rx_hdr1=changeEndian(pcie_rx_pkt_rcvd.tlp.tlp_dword_array[0]);
          vdm_rx_hdr2=changeEndian(pcie_rx_pkt_rcvd.tlp.tlp_dword_array[1]);
          vdm_rx_hdr3=changeEndian(pcie_rx_pkt_rcvd.tlp.tlp_dword_array[2]);
          vdm_rx_hdr4=changeEndian(pcie_rx_pkt_rcvd.tlp.tlp_dword_array[3]);
          vdm_rx_header= {vdm_rx_hdr4,vdm_rx_hdr3,vdm_rx_hdr2,vdm_rx_hdr1};
          pcie_length=pcie_rx_pkt_rcvd.tlp.length;
          for (int i =0;i<pcie_rx_pkt_rcvd.tlp.length;i++) begin
            pldm_pcie_queue.push_back(pcie_rx_pkt_rcvd.tlp.payload[i]);
          end
        end
       
        //-------Header Comparison---------------//
          hdr_cmp_pkt(); 
       
        //--------PLDM Comparison----------------//
         for(int i=0;i<(pcie_rx_pkt_rcvd.tlp.length+1)/2;i++)begin
           pld_cmp_pkt();                                                         //Comparison not needed for SOP,EOP.
         end

         last_pkt_avl=1'h0;   //Cleared for multi packet VDM messages
         pkt_count=1'h0;      //Cleared for multi packet VDM messages
       end
       
   end
   endtask : mctp_rx_cmp_task

 function hdr_cmp_pkt();
  bit [127:0] exp_data,act_data;
  bit [63:0] act_data1,act_data2;
   if(tb_cfg0.has_tx_sb) begin
     exp_data=vdm_tx_header;
   end
   if(tb_cfg0.has_rx_sb) begin
     exp_data=vdm_rx_header;
   end
   act_data1=axi_cmp_data.pop_front();
   act_data2=axi_cmp_data.pop_front();
   
   act_data={act_data2,act_data1};
   if(act_data!=exp_data)begin
     `uvm_error("pmci_scoreboard",$sformatf("HEADERS dont match on PCIe Side =  %h and BPF-PMCI IF = %h",exp_data,act_data));
   end
   else begin
     `uvm_info(get_type_name(),$sformatf("HEADERS match on PCIe Side=%h and BPF-PMCI I/F side=%h",exp_data,act_data),UVM_LOW);
   end
  

 endfunction

 function pld_cmp_pkt();
   bit [63:0] exp_data,act_data;
   bit [31:0] exp_data1,exp_data2;
  
   if(!rem_len_ctr)begin
    rem_len_ctr=pcie_length;
   end

   if(tb_cfg0.has_tx_sb==1) begin
     if(rem_len_ctr==32'd1) begin 
       exp_data1=changeEndian(pldm_pcie_queue.pop_front());
       exp_data=exp_data1;
     end
     else begin
       exp_data1=changeEndian(pldm_pcie_queue.pop_front());
       exp_data2=changeEndian(pldm_pcie_queue.pop_front());
       exp_data={exp_data2,exp_data1};
       rem_len_ctr=rem_len_ctr-2;
     end
   end
   if(tb_cfg0.has_rx_sb==1) begin
     if(rem_len_ctr==32'd1) begin 
       exp_data1=changeEndian(pldm_pcie_queue.pop_front());
       exp_data=exp_data1;
       odd_dw_set=1;
     end
     else begin
       exp_data1=changeEndian(pldm_pcie_queue.pop_front());
       exp_data2=changeEndian(pldm_pcie_queue.pop_front());
       exp_data={exp_data2,exp_data1};
       rem_len_ctr=rem_len_ctr-2;
     end
   end

   act_data=axi_cmp_data.pop_front();
   //--------PCIe Comparison with AXI comparison-------//
   if(act_data!=exp_data)begin
     `uvm_error("pmci_scoreboard",$sformatf("Payloads dont match on PCIe Side =  %h and BPF-PMCI IF = %h",exp_data,act_data));
   end
   else begin
     `uvm_info(get_type_name(),$sformatf("Payloads match on PCIe Side=%h and BPF-PMCI I/F side=%h",exp_data,act_data),UVM_LOW);
   end


   if(tb_cfg0.has_rx_sb) begin
     //---------BMC Comparison with PCIe packets--------//
     $readmemh("bmc_tx_out.txt",bmc_pld);
     if(odd_dw_set) begin
       if(bmc_pld[len_ctr]!==exp_data1)begin
         `uvm_error("pmci_scoreboard",$sformatf("Payloads dont match on PCIe Side =  %h and BMC side = %h",exp_data1,bmc_pld[len_ctr]));
       end
       else begin
         `uvm_info(get_type_name(),$sformatf("Payloads match on PCIe Side=%h and BMC side=%h",exp_data1,bmc_pld[len_ctr]),UVM_LOW);
       end
     end
     else begin
       if(bmc_pld[len_ctr]!==exp_data1)begin
         `uvm_error("pmci_scoreboard",$sformatf("Payloads dont match on PCIe Side =  %h and BMC side = %h",exp_data1,bmc_pld[len_ctr]));
       end
       else begin
         `uvm_info(get_type_name(),$sformatf("Payloads match on PCIe Side=%h and BMC side=%h",exp_data1,bmc_pld[len_ctr]),UVM_LOW);
       end
       if(bmc_pld[len_ctr+1]!==exp_data2)begin
         `uvm_error("pmci_scoreboard",$sformatf("Payloads dont match on PCIe Side =  %h and BMC side = %h",exp_data2,bmc_pld[len_ctr+1]));
       end
       else begin
         `uvm_info(get_type_name(),$sformatf("Payloads match on PCIe Side=%h and BMC side=%h",exp_data2,bmc_pld[len_ctr+1]),UVM_LOW);
       end
     end

   end

   len_ctr=len_ctr+2; //Incrementing the index for BMC comparison

 endfunction

  //Change endianless of payload 
  function [31:0] changeEndian;   //transform data from the memory to big-endian form
    input [31:0] value;
    changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
  endfunction

  virtual function void check_phase (uvm_phase phase);
      
    super.check_phase(phase);
    
   if(tb_cfg0.has_rx_sb ==1'b1)
    begin
      if (pkt_mon_axi > 0)begin
        `uvm_info(get_type_name(),$sformatf(" SCB::  PMCI SENDING VDM PKTs"),UVM_LOW);
      end
      else `uvm_error(get_type_name(),"PMCI IS NOT SENDING ANY PKTs");

      if(axi_pkt_cnt == vdm_rx_cnt)begin 
         `uvm_info(get_type_name(),$sformatf(" SCB::  VDM Pkt transmitted by PMCI %d  VDM PKT Recived by PCIE %d",axi_pkt_cnt,vdm_rx_cnt),UVM_LOW);
      end
     else begin `uvm_error(get_type_name(),$sformatf("Number of Sent PKTS by PMCI %d is not Matched with Number of Recived Pkt at PCIE",axi_pkt_cnt,vdm_rx_cnt));
      end
    end

  if(tb_cfg0.has_tx_sb ==1'b1)
    begin
       if(pkt_mon_axi > 0)begin
       `uvm_info(get_type_name(),$sformatf(" SCB::  PCIE SENDING VDM PKTs"),UVM_LOW);
       end
       else `uvm_error(get_type_name(),"PMCI IS NOT RECIVEING  ANY PKTs");

      if(axi_pkt_cnt == vdm_tx_cnt) begin
       `uvm_info(get_type_name(),$sformatf(" SCB::  VDM Pkt transmitted by PMCI %d  VDM PKT Recived by PCIE %d",axi_pkt_cnt,vdm_tx_cnt),UVM_LOW);
      end
      else begin `uvm_error(get_type_name(),$sformatf("Number of Sent PKTS by PMCI %d is not Matched with Number of Recived Pkt at PCIE",axi_pkt_cnt,vdm_tx_cnt));
      end
   end

  endfunction


endclass : pmci_scoreboard


`endif // pmci_scoreboard
