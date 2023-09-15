//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pcie_pmci_mctp_multi_vdm_seq is executed by pcie_pmci_mctp_multi_vdm_test .
 * 
 * This sequence generates the VDM MCTP pkts using vdm_random_multi_msg task (declared in base_sequnce).
 * before sending the pkts the BMC is configured to recive the VDM pkts 
 * On pmci scoreboard the sent pkts from PCIE is compared with recived pkts by BMC
 *
 * Sequence is running on virtual_sequencer .
 *
 */
//===============================================================================================================

`ifndef PCIE_PMCI_MCTP_MULTI_VDM_SEQ_SVH
`define PCIE_PMCI_MCTP_MULTI_VDM_SEQ_SVH

class pcie_pmci_mctp_multi_vdm_seq extends base_seq;
    `uvm_object_utils(pcie_pmci_mctp_multi_vdm_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
     virtual m10_interface m10_intf;
    logic [31:0] vdm_wdata,mctp_header,vdm_pkt_length,bmc_data,bmc_pkt,vdm_pkt;
    bit [31:0] pkt_cnt,mod_cnt;
    static logic [7:0] j_temp;
    logic [31:0] bmc_vdm_pld[$];
    bit [7:0] valid_cnt;
    bit rddvld_nios;
    rand bit routing_id;
    int status;
    reg[31:0] pcie_pkt[255:0];
    rand bit [9:0] tx_length;
    rand bit csr_cfg;
    rand bit[7:0] dest_eid;
    static rand bit [7:0] csr_id; 

    constraint tx_pkt_len { tx_length inside {[17:256]};}
    constraint routing_type { routing_id inside {[0:1]};}
    constraint dest_id_type  { dest_eid inside {'h00,'hFF};}

    function new(string name = "pcie_pmci_mctp_multi_vdm_seq");
        super.new(name);
    endfunction : new


    task body();
      bit [63:0] length,wdata,addr;
      logic wait_req;
      super.body();
   `ifdef INCLUDE_PMCI
      `uvm_info(get_name(), "Entering pcie_pmci_mctp_multi_vdm_seq...", UVM_LOW)
      if(!uvm_config_db #(virtual m10_interface)::get(null,"","m10_clk",m10_intf)) begin
        `uvm_error(get_type_name,"config db m10c_clk get failed");
      end
      //Logic to calculate the number of packets in multi packet scenario
      if(tx_length%'d16==0) begin
        pkt_cnt= tx_length/'d16;
      end
      else begin
        pkt_cnt= tx_length/'d16;
        mod_cnt= tx_length%'d16; 
      end

      //csr_cfg if enabled will set the EID value to PMCI CSR via MNIOS bus
      if (csr_cfg) begin
        begin @(negedge m10_intf.clk);
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_addr ='h3;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_write ='h1;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_wrdata =csr_id;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_byteen ='hf;
        end  
        begin @(negedge m10_intf.clk);
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_addr ='h1;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_write ='h1;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_wrdata ='h08;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_byteen ='hf;
        end  
        begin @(negedge m10_intf.clk);
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_addr ='h0;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_write ='h1;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_wrdata ='h002;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_byteen ='hf;
        end
        @(negedge m10_intf.clk);
        force tb_top.bmc_m10.egrs_spi_master.avmm_csr_write ='h0;
        while(!tb_top.bmc_m10.egrs_spi_master.ack_trans) begin
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_addr ='h0;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_read ='h1;
            @(posedge m10_intf.clk);
        end
        @(negedge m10_intf.clk);
        force tb_top.bmc_m10.egrs_spi_master.avmm_csr_read ='h0;
        begin @(negedge m10_intf.clk);
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_addr ='h0;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_write ='h1;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_wrdata ='h000;
          force tb_top.bmc_m10.egrs_spi_master.avmm_csr_byteen ='hf;
        end
        create_multi_pkt(csr_id,mod_cnt,pkt_cnt);
      end

      else begin
        create_multi_pkt(dest_eid,mod_cnt,pkt_cnt);
      end

       #10000ns; 
      `uvm_info(get_name(), "Exiting pcie_pmci_mctp_multi_vdm_seq...", UVM_LOW)
      #5us;

      //----------------BMC TXNS---------------------------//
       begin @(negedge m10_intf.clk);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr" ,'h0);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_write",'h1);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",{28'h0,2'h0,1'h1,1'h0});
       end
       @(negedge m10_intf.clk);
       @(negedge m10_intf.clk);
       @(negedge m10_intf.clk);

       begin @(negedge m10_intf.clk); 
          uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h0);
          uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_write",'h1);
          uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",{27'h0,1'h1,3'h0,1'h1});
       end
       @(negedge m10_intf.clk);
       @(negedge m10_intf.clk);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_write", 'h0);
       @(negedge m10_intf.clk);
       @(negedge m10_intf.clk);
       @(negedge m10_intf.clk);
       begin @(negedge m10_intf.clk);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h0);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h1);
       end 
       begin @(negedge m10_intf.clk);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h1);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h1);
       end 
       begin @(negedge m10_intf.clk);
          uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h200);
          uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h1);
       end 
        @(negedge m10_intf.clk); 
        @(negedge m10_intf.clk); 
       begin @(negedge m10_intf.clk); 
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h0);
       end
       begin @(negedge m10_intf.clk); 
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h0);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_write", 'h1);
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",{28'h0,2'h0,1'h0,1'h0});
       end
       begin @(negedge m10_intf.clk); 
          uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_write",'h0);
       end
       #1ms;
       fork begin
       for ( int j=0;j<tx_length;j++) begin
       begin @(negedge m10_intf.clk);
          uvm_hdl_read("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_waitreq",wait_req); 
          if(!wait_req) begin
            j_temp=j;
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr", 'h200+j_temp);
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h1);
            @(negedge m10_intf.clk);
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_read",'h0);
            
          end
          else begin
             j=j-1;
          end 
       end
       end
       end
       //Compare data obtained in BMC with PCIE_VIP SB data//
       begin
         while (valid_cnt<tx_length) begin
          uvm_hdl_read("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld",rddvld_nios);
          if(!rddvld_nios)begin 
            @(posedge m10_intf.clk);
          end
          else begin//if rddvld_nios is present
            uvm_hdl_read("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_rddata",vdm_pkt);
            bmc_vdm_pld.push_back(vdm_pkt);
            valid_cnt=valid_cnt+1;
            @(posedge m10_intf.clk);
          end
         end
       end
       join

    
       for(int i=0;i<tx_length;i++) begin
          $readmemh("pcie_tx_out.txt",pcie_pkt);
          bmc_pkt=bmc_vdm_pld.pop_front();
          if(bmc_pkt !== changeEndian(pcie_pkt[i])) begin
            `uvm_error("pmci_scoreboard",$sformatf("Payloads dont match on PCIe Side =  %h and BMC = %h",changeEndian(pcie_pkt[i]),bmc_pkt));
          end 
          else begin
            `uvm_info(get_type_name(),$sformatf("Payloads match on PCIe Side=%h and BMC side=%h",changeEndian(pcie_pkt[i]),bmc_pkt),UVM_LOW);
          end   
       end
       #200ns;
      
       
    `endif 
    endtask : body


   task create_multi_pkt (input bit [7:0] dest_id,input bit [31:0] mod_cnt_temp,input bit [31:0] pkt_cnt_temp);
   begin

     bit [1:0] pkt_seq;

     vdm_random_multi_msg(.length_('d16),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b10),.num_ctr(0)); //First 16DW of multi packet
     if((mod_cnt_temp!==0) && pkt_cnt_temp==1) begin
       vdm_random_multi_msg(.length_(mod_cnt_temp),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b01),.num_ctr(1)); //17-31 DW packets
     end 
     else if ((mod_cnt_temp==0) && (pkt_cnt_temp==2) )begin
       vdm_random_multi_msg(.length_('d16),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b01),.num_ctr(1)); //32 DW packet
     end
     else if ((mod_cnt_temp==0) && (pkt_cnt_temp > 2)) begin
       for(int i=0;i<pkt_cnt_temp-2;i++)begin
         pkt_seq=pkt_seq+1;
         vdm_random_multi_msg(.length_('d16),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b00),.num_ctr(pkt_seq));//Packets greater than 32DW length which are divisible by 16 like 64,96 etc
       end
       vdm_random_multi_msg(.length_('d16),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b01),.num_ctr(pkt_seq+1)); //Last 16DW of multi packet
     end   
     else begin      //Packets greater than 32DW length which are not divisble by 16 like 63,107,255 etc
       for(int i=0;i<pkt_cnt_temp-1;i++)begin
         pkt_seq=pkt_seq+1;
         vdm_random_multi_msg(.length_('d16),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b00),.num_ctr(pkt_seq));
       end
       vdm_random_multi_msg(.length_(mod_cnt_temp),.routing_type_(routing_id),.dest_id(dest_id),.pos_pkt(2'b01),.num_ctr(pkt_seq+1)); //Last 16DW of multi packet
     end

   end
   endtask
 
endclass : pcie_pmci_mctp_multi_vdm_seq

`endif // PCIE_PMCI_MCTP_MULTI_VDM_SEQ_SVH
