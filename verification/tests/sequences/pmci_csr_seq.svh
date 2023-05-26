//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pmci_csr_seq is executed by pmci_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 *  Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PMCI_CSR_SEQ_SVH
`define PMCI_CSR_SEQ_SVH

class pmci_csr_seq extends base_seq;
    `uvm_object_utils(pmci_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
     uvm_reg m_regs[$];
     uvm_reg m_regs_m[$];
     uvm_reg m_regs_e[$];
     string m_regs_a[string],m_regs_b[string],m_regs_c[string] ;
     bit [63:0] r_array[string],r_a_array[string], r_e_array[string] ;
     bit [63:0] w_array[string], w_a_array[string], w_e_array[string];

     function new(string name = "pmci_csr_seq");
        super.new(name);
     endfunction : new

     task body();
       uvm_status_e   status;
       bit [63:0]  wdata, rdata;
       super.body();
       `uvm_info(get_name(), "Entering pmci_csr_seq...", UVM_LOW)
        m_regs_a["FBM_CSR"] = "FBM_CSR_REG";
        m_regs_a["FBM_AR"] = "FBM_AR_REG";
        m_regs_a["PMCI_ERR_IND"] = "PMCI_ERR_IND_REG";
        m_regs_a["SPI_CSR"] = "SPI_CSR_REG";
        m_regs_a["SPI_AR"] = "SPI_AR_REG";
        m_regs_a["SPI_RD_DR"] = "SPI_RD_DR_REG";
        m_regs_a["SPI_WR_DR"] = "SPI_WR_DR_REG";
        m_regs_a["FBM_FIFO"] = "FBM_FIFO_REG";

        tb_env0.pmci_regs.get_registers(m_regs);
	check_reset_value(m_regs,m_regs_a,r_array);
       	wr_rd_cmp(m_regs,m_regs_a,w_array);
        
	// PMCI_ERR_IND
      `ifdef INCLUDE_PMCI
 	force `PMCI_WRAPPER.m10_gpio_fpga_usr_100m = 'h0;
	force `PMCI_WRAPPER.m10_gpio_fpga_m10_hb = 'h0;
	force `PMCI_WRAPPER.m10_gpio_m10_seu_error = 'h0;
       `endif  

	m_regs_m[0] = tb_env0.pmci_regs.get_reg_by_name("PMCI_ERR_IND");
       	check_reset_value(m_regs_m,m_regs_b,r_a_array);
        wr_rd_cmp(m_regs_m,m_regs_b,w_a_array);
             
        // For covering PMCI-ERR registers
     `ifdef INCLUDE_PMCI
 	force `PMCI_WRAPPER.m10_gpio_fpga_usr_100m = 'h1;
	force `PMCI_WRAPPER.m10_gpio_fpga_m10_hb = 'h1;
 	force `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.seu_avst_sink_vld = 'h1;//fpga_seu_error
 	force `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.m10_nhb_timer[9] = 'h1; //m10_nios_stuck_error
 	force `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.pmci_nhb_timer[7] = 'h1;//pmci_nios_stuck_error
	force `PMCI_WRAPPER.m10_gpio_m10_seu_error = 'h1;

       	m_regs_e[0] = tb_env0.pmci_regs.get_reg_by_name("PMCI_ERR_IND");
	r_e_array["PMCI_ERR_IND"] = 64'h0000_0000_0000_000f;
       	check_reset_value(m_regs_e,m_regs_c,r_e_array);
        wr_rd_cmp(m_regs_e,m_regs_c,w_e_array);

        release `PMCI_WRAPPER.m10_gpio_fpga_usr_100m;
	release `PMCI_WRAPPER.m10_gpio_fpga_m10_hb;
	release `PMCI_WRAPPER.m10_gpio_m10_seu_error;
 	release `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.seu_avst_sink_vld; 
 	release `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.m10_nhb_timer[9]; 
 	release `PMCI_WRAPPER.pmci_ss.pmci_csr.pmci_csr_0.pmci_nhb_timer[7];
      `endif
       
        wdata = 64'hffff_ffff_ffff_ffff;
        tb_env0.pmci_regs.PCIE_VDM_FCR.write(status,wdata);
       `ifdef COV tb_env0.pmci_regs.PCIE_VDM_FCR.cg_vals.sample();`endif
       `uvm_info(get_name(), $psprintf("The value of wdata Register = %0s, data = %0h","PCIE_VDM_FCR", wdata), UVM_LOW)
	
        tb_env0.pmci_regs.PCIE_VDM_PDR.write(status,wdata);
       `ifdef COV tb_env0.pmci_regs.PCIE_VDM_PDR.cg_vals.sample();`endif
       `uvm_info(get_name(), $psprintf("The value of wdata Register = %0s, data = %0h","PCIE_VDM_PDR", wdata), UVM_LOW)
        #5us; 

       `uvm_info(get_name(), "Exiting pmci_csr_seq...", UVM_LOW)
     endtask : body
endclass :pmci_csr_seq 
`endif

