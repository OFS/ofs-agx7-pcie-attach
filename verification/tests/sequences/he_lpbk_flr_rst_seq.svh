//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class he_lpbk_flr_rst_seq is executed by he_lpbk_flr_rst_test 
 * 
 * This sequence generates the FLR reset for PF2 ,using class pf2_flr_reset
 * The sequence initiates the transcations ,once transactions are over FLR reset is applied
 * And verifies the he_lpbk status registers after reset
 *
 * Sequence is running on virtual_sequencer 
**/
//===============================================================================================================



`ifndef HE_LPBK_FLR_RST_SEQ_SVH
`define HE_LPBK_FLR_RST_SEQ_SVH

class he_lpbk_flr_rst_seq extends base_seq;
    `uvm_object_utils(he_lpbk_flr_rst_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    he_lpbk_seq lpbk_seq;
     bit[31:0]  dev_ctl;

    rand int loop;
    string msgid;

    constraint loop_c { loop inside {[10:20]}; }

    function new(string name = "he_lpbk_flr_rst_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] rdata;
        super.body();
        fork
	        begin
	            `uvm_do_on_with(lpbk_seq, p_sequencer, {
	                mode inside {3'b000, 3'b001, 3'b010, 3'b011};
	                bypass_config_seq == 1;
	            })
	        end
	        begin
		        while(!rdata[1]) begin
	                    mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(rdata));
		        end
	       	#200ns;
	         mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(rdata));//CTL
		       `uvm_info(get_name(), $psprintf("Before FLR HE_LPBK CTL data %h", rdata),UVM_LOW);
	         mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h160), .data_(rdata));//status0
		       `uvm_info(get_name(), $psprintf("Before FLR HE_LPBK_STATUS0  data %h", rdata),UVM_LOW);
	         mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h168), .data_(rdata));//status1
       		`uvm_info(get_name(), $psprintf("Before FLR HE_LPBK_STATUS1  data %h", rdata),UVM_LOW);
	       end
      join
     `uvm_info(msgid,$sformatf("Initiating PF0 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h2), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h2), .dev_ctl_(dev_ctl)); 
	   #80us;
      
       pcie_pf_vf_bar(); //release FLR (enumeration)
     #1us;
     //read status and CFG afetr FLR
     mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(rdata));//CTL
    `uvm_info(get_name(), $psprintf("After FLR HE_LPBK_CTL  data %h", rdata),UVM_LOW);
       if(rdata!='h0) `uvm_error(get_name(), $psprintf("HE_LPBK_CTL is not clear")) //check CTL is 0

     mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h160), .data_(rdata));//status0
    `uvm_info(get_name(), $psprintf("After FLR HE_LPBK_STATUS0  data %h", rdata),UVM_LOW);
       if(rdata!='h0) `uvm_error(get_name(), $psprintf("HE_LPBK_STATUS0 is not clear")) //check STATUS0 is 0
   
     mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h168), .data_(rdata));//status1
    `uvm_info(get_name(), $psprintf("After HE_LPBK_STATUS1  data %h", rdata),UVM_LOW);
       if(rdata!='h0) `uvm_error(get_name(), $psprintf("HE_LPBK_STATUS1 is not clear")) //check STATUS1 is 0
   
     mmio_read64(.addr_(tb_cfg0.HE_LB_BASE+'h140), .data_(rdata));//CFG
    `uvm_info(get_name(), $psprintf("After HE_LPBK_STATUS1  data %h", rdata),UVM_LOW);
       if(rdata!='h0) `uvm_error(get_name(), $psprintf("HE_LPBK Configuration is not clear")) //check CFG is 0
              
        #1us;
	mmio_write64(.addr_(tb_cfg0.HE_LB_BASE+'h138), .data_(64'h1));
	`uvm_do_on_with(lpbk_seq, p_sequencer, {
	    mode inside {3'b000, 3'b001, 3'b010, 3'b011};
	    bypass_config_seq == 1;
	})
    endtask : body

endclass : he_lpbk_flr_rst_seq

`endif // HE_LPBK_FLR_RST_SEQ_SVH
