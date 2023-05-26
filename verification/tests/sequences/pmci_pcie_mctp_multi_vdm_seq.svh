//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pmci_pcie_mctp_multi_vdm_seq is executed by pmci_pcie_mctp_multi_vdm_test .
 * 
 * This sequence generates the multiple VDM MCTP pkts and sends the PKTs to PCIE
 * before sending the pkts the BMC is configured to transfer the VDM pkts 
 * On pmci scoreboard the sent pkts from BMC/PMCI is compared with recived pkts by PCIE
 *
 * Sequence is running on virtual_sequencer .
 *
 */
//===============================================================================================================



`ifndef PMCI_PCIE_MCTP_MULTI_VDM_SEQ_SVH
`define PMCI_PCIE_MCTP_MULTI_VDM_SEQ_SVH

class pmci_pcie_mctp_multi_vdm_seq extends base_seq;
    `uvm_object_utils(pmci_pcie_mctp_multi_vdm_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
     virtual m10_interface m10_intf;
     bit [63:0] wdata,rdata,addr;
     bit nios_rdata,nios_rdvalid;
     logic [31:0] vdm_wdata;
     static logic [7:0] i_temp;
     rand bit [9:0] rx_length;
     logic m10_clk;
     bit [31:0] fd;
     rand bit source_id,routing_id;
     static rand bit [7:0] csr_id;

     constraint rx_pkt_len { rx_length inside {[17:256]};}
     constraint rx_routing_type { routing_id inside {[0:1]};}
     constraint src_id_type  { source_id inside {'h00,'h01};}

     function new(string name = "pmci_pcie_mctp_multi_vdm_seq");
         super.new(name);
     endfunction : new

     task body ();
       super.body();
     `ifdef INCLUDE_PMCI  
       addr  = tb_cfg0.PF0_BAR0+PMCI_BASE_ADDR+'h80;
       wdata = 'h42000;
       mmio_write64(.addr_(addr), .data_(wdata));

       fd = $fopen("bmc_tx_out.txt","w+");
        
       if(!uvm_config_db #(virtual m10_interface)::get(null,"","m10_clk",m10_intf)) begin
         `uvm_error(get_type_name,"config db m10c_clk get failed");
       end 

       //----------------------BMC_COMP TXNS----------------------------//

      //if source_id is set to 0 from test ,PMCI CSR will be configured with a Source ID configured via MNIOS bus
      if (!source_id) begin
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
       end

       begin @(posedge m10_intf.clk);
         uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr",'h4);
         uvm_hdl_force ("tb_top.bmc_m10.avmm_nios_read",'h1);

        
         while(uvm_hdl_read("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_rddata[1]",nios_rdata) && uvm_hdl_read("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_rddvld",nios_rdvalid)) begin
           if(!(nios_rdata==0 && nios_rdvalid ==1)) begin     
             @(posedge m10_intf.clk);
           end
           else begin
             break;
           end
         end
         for (int i=0;i<rx_length;i++)
         begin @(posedge m10_intf.clk);
            i_temp=i;
            uvm_hdl_force ("tb_top.bmc_m10.avmm_nios_read",'h0);
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr",'h300+i_temp);
            uvm_hdl_force ("tb_top.bmc_m10.avmm_nios_write",'h1);
            assert (std::randomize(vdm_wdata));
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",vdm_wdata);
            $fwrite(fd,"%h \n",vdm_wdata);
         end
         $fclose(fd); 
         begin @(posedge m10_intf.clk);
            uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr",'h5);
            uvm_hdl_force("tb_top.bmc_m10.avmm_nios_write",'h1);
            uvm_hdl_force("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",{2'h0,routing_id,source_id,28'h0});
         end
         begin @(posedge m10_intf.clk); 
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_addr",'h4);
            uvm_hdl_force ("tb_top.bmc_m10.avmm_nios_write",'h1);
            uvm_hdl_force ("tb_top.bmc_m10.m10_pcie_vdm.avmm_nios_wrdata",{rx_length,2'h0,3'h0,1'h1});
         end
       end
       @(posedge m10_intf.clk); 
       @(posedge m10_intf.clk); 
       uvm_hdl_force ("tb_top.bmc_m10.avmm_nios_write",'h0);
       #500us;

     `endif
      endtask

endclass : pmci_pcie_mctp_multi_vdm_seq

`endif // PMCI_PCIE_MCTP_MULTI_VDM_SEQ_SVH
