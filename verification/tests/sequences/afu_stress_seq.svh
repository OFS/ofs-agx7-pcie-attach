//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 *
 * class afu_stress_seq is executed by afu_stress_test
 * Also afu_stress_seq is executed by afu_stress_5bit_tag_test; 5bit tag is enabled in the test 
 * Also afu_stress_seq is executed by afu_stress_8bit_tag_test ; 8bit tag is enabled in the test
 * Below mentioned csr sequence is accessed simultaneosly to generate the stress                               
 * */
//===============================================================================================================

`ifndef AFU_STRESS_SEQ_SVH
`define AFU_STRESS_SEQ_SVH

class afu_stress_seq extends base_seq;
    `uvm_object_utils(afu_stress_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    rand int loop;
    he_random_stress_seq        he_random_seq;  
    fme_csr_stress_seq          fme_csr_seq;
    qsfp_csr_stress_seq         qsfp_csr_seq;
    he_hssi_rw_seq             he_hssi_csr_seq;
    hssi_ss_rw_seq              hssi_ss_seq;

    constraint loop_c { soft loop inside {[5:10]}; }

    function new(string name = "afu_stress_seq");
        super.new(name);
    endfunction : new

    task body();
    bit [63:0] wdata, rdata, addr;
        super.body();
        `uvm_info(get_name(), "Entering afu_stress_seq...", UVM_LOW)

	this.randomize();

        fork
	    begin // HE_RANDOM SEQ
	        for(int i = 0; i < loop; i++) begin
                 `uvm_do_on_with(he_random_seq,p_sequencer,{bypass_config_seq==1;})
          	end
	    end
	    begin // FME_CSR access
	        for(int i = 0; i < loop; i++) begin
                 `uvm_do_on_with(fme_csr_seq,p_sequencer,{bypass_config_seq==1;})
	        end
            end
	    begin // QSFP-CSR access
	        for(int i = 0; i < loop; i++) begin
                 `uvm_do_on_with(qsfp_csr_seq,p_sequencer,{bypass_config_seq==1;})
		end
	    end
            
          `ifndef INCLUDE_CVL
	    begin // HE-HSSI CSR access
	        for(int i = 0; i < loop; i++) begin
                   `uvm_do_on_with(he_hssi_csr_seq,p_sequencer,{bypass_config_seq==1;})
	     	end
	    end
          `endif

	    begin // HSSI_SS access
	        for(int i = 0; i < loop; i++) begin
                 `uvm_do_on_with(hssi_ss_seq,p_sequencer,{bypass_config_seq==1;})
		end
	    end
	    begin // CE-CSR access
        `ifdef INCLUDE_HPS
	//        for(int i = 0; i < loop; i++) begin
        //         `uvm_do_on_with(ce_csr_seq,p_sequencer,{bypass_config_seq==1;})
	//	end
    `endif
	    end

	join

        `uvm_info(get_name(), "Exiting afu_stress_seq...", UVM_LOW)
    endtask : body

endclass : afu_stress_seq

`endif // MMIO_STRESS_SEQ_SVH
