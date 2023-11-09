//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class mmio_flr_pf_vf_seq is executed by afu_mmio_flr_*_test .
 * 
 * This sequence generates the FLR reset depending on PF/VF set in the testcase.
 * The MMIO transcations are initated ,before and after the reset.
 * After reset verified if registers are cleared
 *
 * Sequence is running on virtual_sequencer. 
**/
//===============================================================================================================


`ifndef MMIO_FLR_PF_VF_SEQ_SVH
`define MMIO_FLR_PF_VF_SEQ_SVH

parameter NUM_AFUS = 1;

mmio_seq ac_mmio_seq, ac_mmio_seq_1;

bit[3:0] PF_NUM;
bit[3:0] PF_NUMBER;
bit[63:0] addr, rdata ;


 class mmio_flr_pf_vf_seq extends base_seq;
    `uvm_object_utils(mmio_flr_pf_vf_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)
    enumerate_seq   enumerate_seq2;
    pcie_device_bring_up_link_sequence bring_up_link_seq;
    uvm_status_e    status;
    uvm_reg_data_t  reg_data;
    string msgid;
    rand int test_length;
    rand int loops;

    typedef enum {
    PF = 0,
    VF = 1
    } mode_t;

    rand mode_t afu_mode[NUM_AFUS];
    rand mode_t reset_mode[NUM_AFUS];
    rand bit                length_in_dw;
    bit  [63:0]        BAR_OFFSET ;       
    rand bit  [63:0]        ADDR;
    rand bit  [63:0]        FADDR;
    rand bit  [63:0]        PADDR;
    rand bit  [63:0]        VPADDR;
    rand bit  [63:0]        AADDR;
    string                  msgid;
    bit[31:0]               dev_ctl;
   
    constraint afu_mode_constraint {
        soft test_length inside {[20:25]};
        soft loops       == 0;
        afu_mode[0] == PF;
        reset_mode[0] == PF;

    }

    constraint _pcie_length_c {
    length_in_dw  dist {
     2 := 20,
     1 := 5,
     4 := 1
    
   };

    }

// ---------------------------------------------------------------------------

  function new(string name = "mmio_flr_pf_vf_seq");
    super.new(name); 
    msgid=get_type_name();
  endfunction    


// ---------------------------------------------------------------------------

  task body ();
    super.body();
    BAR_OFFSET = tb_cfg0.PF0_BAR0;
    `uvm_info(msgid, "Entered MMIO test Sequence", UVM_LOW);
    uvm_config_db#( bit[3:0])::get(null,"uvm_test_top.*", "PF_NUMB", PF_NUM);
    test_action();
    #30us;
    `uvm_info(msgid, "Exiting MMIO test  Sequence", UVM_LOW);
  endtask

// ---------------------------------------------------------------------------
  task test_action();
        begin
        `uvm_info(msgid, "Entered test action", UVM_LOW);
     #5us; //Removing fork join as not expecting FLR to happen before the begining of trasactions
     //fork
        `uvm_do_on_with(ac_mmio_seq,p_sequencer,{bypass_config_seq==1;})
        #40us;
        afu_flr_seq(0);
		#10us;
		`uvm_do_on_with(ac_mmio_seq_1,p_sequencer,{bypass_config_seq==1;})
	    end
       //join 

  endtask: test_action

  task afu_flr_seq(int port=0);
    afu_flr_reset(reset_mode[port],port);
  endtask: afu_flr_seq

  task afu_flr_reset(mode_t afu_mode,bit afu_num=0);
  
     PF_NUMBER = PF_NUM;

        `uvm_info(msgid,$sformatf("Entered Primary reset task..."),UVM_LOW);

    //PF0

    if ( PF_NUMBER == 0)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF0 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h0), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h0), .dev_ctl_(dev_ctl)); 
                `uvm_info(msgid,$sformatf("Entering wait statement"),UVM_LOW);
       `ifndef INCLUDE_CVL       
         wait (`PG_AFU_TOP.port_rst_n == '0 );
                `uvm_info(msgid,$sformatf("Exiting wait statement"),UVM_LOW);
        `endif 

                #80us;
                pcie_pf_vf_bar();
                        
        //ST2MM PF0_BAR0
        `uvm_info(msgid,$sformatf("Entering ST2MM scratchpad read"),UVM_LOW);
        addr = tb_cfg0.PF0_BAR0+ST2MM_BASE_ADDR+'h0_0008;
        mmio_read64 (.addr_(addr), .data_(rdata));

     `ifndef INCLUDE_CVL  //Removing HSSI from FIM platforms
        //HE_HSSI PF0_VF1
        addr = tb_cfg0.PF0_VF1_BAR0+HE_HSSI_BASE_ADDR+'h48;
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 64'h0000000045324511)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
      `endif

        //HE_MEM PF0_VF0
        addr = tb_cfg0.PF0_VF0_BAR0+ HE_MEM_BASE_ADDR +'h100;
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))

        //MEM_TG PF0_VF2
	`ifdef INCLUDE_DDR4
         addr = tb_cfg0.PF0_VF2_BAR0+MEM_TG_BASE_ADDR+ 'h0028;
         mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
       `endif

    end
    //PF2

    else if ( PF_NUMBER == 2)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF2 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h2), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h2), .dev_ctl_(dev_ctl));
		wait (`FIM_AFU_INSTANCES.port_rst_n[1] == 0);
               // #4.32us;
                  #80us;
                pcie_pf_vf_bar();
         

         //HE_LPBK PF2
         addr = tb_cfg0.PF2_BAR0+HE_LB_BASE_ADDR +'h100;
         mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
        end
    //PF3

    else if ( PF_NUMBER == 3)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF3 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h3), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h3), .dev_ctl_(dev_ctl));
                wait(`FIM_AFU_INSTANCES.port_rst_n[2] == 0);
                //#4.32us;
                  #80us;
                pcie_pf_vf_bar();
        //Virtio PF3
        addr = tb_cfg0.PF3_BAR0 + VIRTIO_LB_BASE_ADDR + 'h18;
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
        end

    //PF4
  `ifdef INCLUDE_HPS
    else if ( PF_NUMBER == 4)
        begin

                `uvm_info(msgid,$sformatf("Initiating PF4 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h4), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h4), .dev_ctl_(dev_ctl));
                 wait(n6000_tb_top.DUT.afu_top.afu_sr_wrapper_inst.hps_gen.ce_top.rst == 1);
                #4.32us;
	 pcie_pf_vf_bar();
         //CE PF4
         addr = tb_cfg0.PF4_BAR0+'h100;
         mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
        end
    `endif

    //PF0_VF0

    else if ( PF_NUMBER == 5)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF0_VF0 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h5), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h5), .dev_ctl_(dev_ctl));
                wait (`PG_AFU_TOP.port_rst_n[0] == 0);
                //#4.32us;
                  #80us;
                pcie_pf_vf_bar();

                //HE_MEM PF0_VF0
        addr = tb_cfg0.PF0_VF0_BAR0+ HE_MEM_BASE_ADDR+ 'h100;
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))

         end

    //PF0_VF1

    else if ( PF_NUMBER == 6)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF0_VF1 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h6), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h6), .dev_ctl_(dev_ctl));
	      `ifdef INCLUDE_CVL
                wait (`PG_AFU_TOP.port_rst_n[1] == 0 );
	      `endif
                //#4.32us;
                  #80us;
                pcie_pf_vf_bar();

        `ifndef INCLUDE_CVL   //Removing HSSI from FIM platforms
        //HE_HSSI PF0_VF1
        addr = tb_cfg0.PF0_VF1_BAR0+ HE_HSSI_BASE_ADDR +'h48;
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 64'h0000000045324511)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
        
        `endif

        end
       
    //PF0_VF2
   `ifdef INCLUDE_MEM_TG
    else if ( PF_NUMBER == 7)
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF0_VF2 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h7), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h7), .dev_ctl_(dev_ctl));
                 wait (`PG_AFU_TOP.port_rst_n[2] == 0 );
                //#4.32us;
                  #80us;
                pcie_pf_vf_bar();



                //MEM_TG PF0_VF2
         addr = tb_cfg0.PF0_VF2_BAR0+ MEM_TG_BASE_ADDR +'h0028;
         mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata == 0)
            `uvm_info(get_name(), $psprintf("Scratchpad is reset, addr = %0h, data = %0h", addr, rdata), UVM_LOW)
        else
            `uvm_error(get_name(), $psprintf("Scratchpad is not reset Addr = %0h, data = %0h", addr, rdata))
         end
     `endif

    //PF1_VF0

    else  
	     begin

                `uvm_info(msgid,$sformatf("Initiating PF1_VF0 FLR Reset..."),UVM_LOW);
                flr_cfg_rd (.address_('h8), .dev_ctl_(dev_ctl));
                flr_cfg_wr (.address_('h8), .dev_ctl_(dev_ctl));
                //#4.32us;
                  #80us;
                pcie_pf_vf_bar();
         end 


  endtask: afu_flr_reset

 endclass: mmio_flr_pf_vf_seq

`endif

    




    



