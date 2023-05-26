//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class fme_intr_seq.svh is executed by fme_intr_test .
 * 
 * This sequnce verifies the functionality of the inturrputs  
 * The intruppt is generated by forcing / writing the error register .
 * PBA mechanism is verified using masking and un-masking the intruppt vector
 * Sequnce is running on virtual_sequencer .
 *
 *
 */
//===============================================================================================================


`ifndef FME_INTR_SEQ_SVH
`define FME_INTR_SEQ_SVH

class fme_intr_seq extends base_seq;
    `uvm_object_utils(fme_intr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

  rand bit[63:0]    intr_addr;
  rand bit[63:0]    intr_wr_data;
  rand bit[63:0]    ras_err_code;//1:CatastError, 2:FatalError, 4:NoFatalError
  rand bit[63:0]    fme_err_code;//1:PartialReconfigFIFOParityErr, 2:RemoteSTPParityErr, 32:AfuAccessModeErr
  rand bit inj_ras_err; 
  rand bit inj_fme_err; 
  static int e_set;

  rand bit [63:0] dut_mem_start;
  rand bit [63:0] dut_mem_end;

  constraint addr_cons {
     dut_mem_end > dut_mem_start;
     intr_addr[7:0] == 0;
     intr_addr   >= dut_mem_start;
     intr_addr    < dut_mem_end;
     intr_addr[63:32] == 32'b0;
  }
    
  constraint wr_dat_cons {
     !(intr_wr_data inside {64'h0});
      intr_wr_data[63:32] == 32'b0; 
  }

  constraint ras_err_code_cons {
     ras_err_code inside {64'h1, 64'h2, 64'h4};//1:CatastError, 2:FatalError, 4:NoFatalError
  }

  constraint fme_err_code_cons {
     fme_err_code inside {64'h1};//1:PartialReconfigFIFOParityErr
  }

  constraint err_type_cons{
    soft inj_ras_err==1;
    soft inj_fme_err==0;
  }
 
    function new(string name = "fme_intr_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr, intr_masked_data;
	bit [31:0] host_intr_rdata[16];
        bit [63:0] afu_id_l, afu_id_h;
        bit msix_req_set;


        super.body();
        `uvm_info(get_name(), "Entering fme_intr_seq...", UVM_LOW)

        repeat(3)begin

  	  this.randomize() with{dut_mem_start == tb_cfg0.dut_mem_start && dut_mem_end == tb_cfg0.dut_mem_end;};
          `uvm_info(get_name(), $psprintf("TEST: inj_ras_err=%0d, inj_fme_err=%0d dut_mem_start=%0h dut_mem_end=%0h", inj_ras_err, inj_fme_err, dut_mem_start, dut_mem_end), UVM_LOW)

          if(fme_err_code == 20'h00001) e_set = 0;

          `uvm_info(get_name(), $psprintf("TEST: Configure MSIX Table BAR0 MSIX_ADDR6/MSIX_CTLDAT6"), UVM_LOW)
          `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE to MSIX_ADDR6"), UVM_LOW)
          mmio_write64(.addr_(tb_cfg0.PF0_BAR4+ FME_MSIX_BASE_ADDR+20'h0_0060), .data_(intr_addr));
          #1us;

          `uvm_info(get_name(), $psprintf("TEST: MMIO WRITE to MSIX_CTLDAT6 with masked Interrupt"), UVM_LOW)
          intr_masked_data[31:0] = intr_wr_data[31:0];
          intr_masked_data[63:32] = 32'b1; 
          mmio_write64(.addr_(tb_cfg0.PF0_BAR4+ FME_MSIX_BASE_ADDR+ 20'h0_0068), .data_(intr_masked_data));
          #25us;
 
	  if(inj_ras_err)begin
            `uvm_info(get_name(), $psprintf("TEST: Inject RAS ERROR ras_err_code=%0x",ras_err_code), UVM_LOW)
            mmio_write64(.addr_(tb_cfg0.PF0_BAR0+RAS_ERROR_INJ_VERIF), .data_(ras_err_code));
	  end
	  if(inj_fme_err)begin
            `uvm_info(get_name(), $psprintf("TEST: Inject FME ERROR fme_err_code=%0x", fme_err_code), UVM_LOW)
	    force `FME_CSR_TOP.inp2cr_fme_error[63:0] = 1'b1 << e_set;
	  end

          #1us;
          `uvm_info(get_name(), $psprintf("TEST: Check MSIX_PBA[6] is set for masked FME interrupt"), UVM_LOW)
          for(int i=0;i<200;i++) begin
             mmio_read64(.addr_(tb_cfg0.PF0_BAR4+ FME_MSIX_BASE_ADDR+20'h0_0070),.data_(rdata));
            if(rdata[6]) break;
            #1ns;
          end
          assert(rdata[6]) else 
            `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[6] not set post masked interrupt"))

          `uvm_info(get_name(), $psprintf("TEST: Unmasked FME interrupt by writing on MSIX_CTLDAT6[63:32]"), UVM_LOW)
          mmio_write64(.addr_(tb_cfg0.PF0_BAR4+ FME_MSIX_BASE_ADDR+20'h0_0068), .data_(intr_wr_data));

	
          #1us;
          `uvm_info(get_name(), $psprintf("TEST: Check MSIX_PBA[6] is clear after asserting pending FME interrupt"), UVM_LOW)
          mmio_read64(.addr_(tb_cfg0.PF0_BAR4+ FME_MSIX_BASE_ADDR+20'h0_0070),.data_(rdata));
          assert(rdata[6]==0) else 
            `uvm_error(get_type_name(),$sformatf("TEST : MSIX_PBA[6] is not clear after asserting pending FME interrupt"));

          `uvm_info(get_name(), $psprintf("TEST: Read Host memory"), UVM_LOW)
   	  host_mem_read( .addr_(intr_addr) , .data_(host_intr_rdata) , .len('d16) );

          if(changeEndian(host_intr_rdata[0]) !== intr_wr_data)
              `uvm_error(get_name(), $psprintf("Interrupt write data mismatch exp = %0h act = %0h", intr_wr_data, changeEndian(host_intr_rdata[0])))
          else
              `uvm_info(get_name(), $psprintf("TEST: Interrupt data match intr_addr=%0h intr_wr_data = %0h", intr_addr, intr_wr_data), UVM_LOW)

	  if(inj_ras_err)begin
            `uvm_info(get_name(), $psprintf("TEST: Clear RAS ERROR and msix_req_set"), UVM_LOW)
             mmio_write64(.addr_(tb_cfg0.PF0_BAR0+RAS_ERROR_INJ_VERIF), .data_(64'h0));
             mmio_write64(.addr_(tb_cfg0.PF0_BAR0+RAS_NOFAT_ERROR_VERIF), .data_('h40));
	  end
	  if(inj_fme_err)begin
            uvm_reg_data_t    ctl_data;
            uvm_status_e      status;
           release `FME_CSR_TOP.inp2cr_fme_error[63:0]; 
            tb_env0.fme_regs.FME_ERROR0.read(status,ctl_data);
            `uvm_info(get_type_name(),$sformatf("FME Error read ctl_data: %x",ctl_data ),UVM_MEDIUM)
            if(ctl_data != fme_err_code)
     	      `uvm_error(get_type_name(), $psprintf("FME ERROR mismatch ctl_data=%0x fme_err_code=%0x", ctl_data, fme_err_code))
            tb_env0.fme_regs.FME_ERROR0.write(status,'1);
	  end

          msix_req_set = 0;
          #1us;
        end

       `uvm_info(get_name(), "Exiting fme_intr_seq...", UVM_LOW)

    endtask : body

endclass : fme_intr_seq

`endif // FME_INTR_SEQ_SVH
