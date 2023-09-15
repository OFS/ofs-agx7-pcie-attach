// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef FME_CSR_SEQ_SVH
`define FME_CSR_SEQ_SVH

class fme_csr_seq extends base_seq;
    `uvm_object_utils(fme_csr_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

     rand int                pcie_tlp_count;
     rand bit  [63:0]        BAR_OFFSET ;       
     rand bit  [63:0]        ADDR;
       
    rand `PCIE_DRIVER_TRANSACTION_CLASS::transaction_type_enum  pcie_trans_type;
    `PCIE_DEV_CFG_CLASS cfg;
  
    constraint pcie_tlp_count_cons {
      pcie_tlp_count inside {[20:40]}; //FIFO depth is 64 so backpressure will get created for b2b req > 64
    }
    
    constraint pcie_trans_cons {
      pcie_trans_type  inside {
        `PCIE_DRIVER_TRANSACTION_CLASS::MEM_WR,
        `PCIE_DRIVER_TRANSACTION_CLASS::MEM_RD
       };
    }
  
    constraint addr_offset_cons {
      //SSS `BAR_OFFSET inside { `PF0_BAR0, `PF0_BAR2}; // FME, PORT and external FME/PORT CSR slaves
      BAR_OFFSET inside { `PF0_BAR0}; // FME CSR slaves
    }
    
    constraint dcp_addr_cons {
      solve BAR_OFFSET before ADDR; 
      ADDR[63:32] == 32'h0000;
      (BAR_OFFSET == `PF0_BAR0) ->    {ADDR[31:0] inside {'h0000,'h0008,'h0018,'h0028,'h0030,'h0038,'h0040,                                                                    'h0048,'h0050,'h0058,'h0060,'h0068,'h1000,'h1008,
                                                     'h1010,'h1018,'h1020,'h3000,'h3020,'h3028,'h3030,
                                                     'h4000,'h4010,'h4018,'h4020,'h4038,'h4040,'h4048,
                                                     'h4050,'h4058,'h4060,'h4068,'h4070,'h5000,'h5008,
                                                     'h5010,'h5020,'h50B0,'h9000,'h9008,'h9010,'h9018,'h9020,'h9028,'h9030,
                                                     'h9038,'h9040,'h9048,'h9050,'h9058,'h9060,'h9068, 
                                                     'hA000,'hA008 };}
    }



    function new(string name = "fme_csr_seq");
        super.new(name);
    endfunction : new

    task body();
        bit [63:0] wdata, rdata, addr,rw_bits,exp_data;
        `PCIE_DRIVER_TRANSACTION_CLASS pcie_tran;
        uvm_reg_data_t ctl_data;
        uvm_status_e       status;


        
        super.body();
        `uvm_info(get_name(), "Entering fme_csr_seq...", UVM_LOW)
       // starting_phase.raise_objection(this);

        tb_env0.fme_regs.FME_DFH.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_DFH.cg_vals.sample();`endif
        rw_bits = 'h0;


       if(rdata !== 'h4000000010000000)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_DFH", 'h4000000010000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_DFH",'h4000000010000000, rdata), UVM_LOW)
               
     // Write and Read to AFU_ID_L

        tb_env0.fme_regs.FME_AFU_ID_L.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_AFU_ID_L.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_AFU_ID_L.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_AFU_ID_L.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h82FE38F0F9E17764)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_AFU_ID_L", 'h82FE38F0F9E17764 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_AFU_ID_L",'h82FE38F0F9E17764, rdata), UVM_LOW)

     // Write and Read to AFU_ID_H

        tb_env0.fme_regs.FME_AFU_ID_H.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_AFU_ID_H.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_AFU_ID_H.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_AFU_ID_H.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='hBFAF2AE94A5246E3)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_AFU_ID_H", 'hBFAF2AE94A5246E3 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_AFU_ID_H",'hBFAF2AE94A5246E3, rdata), UVM_LOW)


        // Write and Read to FME_NEXT_AFU

        tb_env0.fme_regs.FME_NEXT_AFU.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_NEXT_AFU.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_NEXT_AFU.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_NEXT_AFU.cg_vals.sample();`endif
        rw_bits = 'h0000000000ffffff;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_NEXT_AFU",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_NEXT_AFU",'h0, rdata), UVM_LOW)

     // Write and Read to DUMMY_0020

        tb_env0.fme_regs.DUMMY_0020.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_0020.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_0020.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_0020.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_AFU_ID_L", 'h82FE38F0F9E17764 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_AFU_ID_L",'h0, rdata), UVM_LOW)

        // Write and Read to FME_SCRATCHPAD0

        tb_env0.fme_regs.FME_SCRATCHPAD0.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_SCRATCHPAD0.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_SCRATCHPAD0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_SCRATCHPAD0.cg_vals.sample();`endif
        rw_bits = 'hffffffffffffffff;
        wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_SCRATCHPAD0",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_SCRATCHPAD0",wdata, rdata), UVM_LOW)

        // Write and Read to PORT0_OFFSET

        tb_env0.fme_regs.PORT0_OFFSET.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PORT0_OFFSET.cg_vals.sample();`endif
        tb_env0.fme_regs.PORT0_OFFSET.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PORT0_OFFSET.cg_vals.sample();`endif
        rw_bits = 'heffffff8f0000000;
        wdata[34:32] = 'h2;
        wdata = rw_bits & wdata;
        if(rdata !== 'h1000000700000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PORT0_OFFSET",'h1000000700000000 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PORT0_OFFSET",'h1000000700000000 , rdata), UVM_LOW)


        // Write and Read to PORT1_OFFSET

        tb_env0.fme_regs.PORT1_OFFSET.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PORT1_OFFSET.cg_vals.sample();`endif
        tb_env0.fme_regs.PORT1_OFFSET.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PORT1_OFFSET.cg_vals.sample();`endif
        rw_bits = 'heffffff8f0000000;
        wdata = rw_bits & wdata;
        wdata [19] ='h1;
        if(rdata !== 'h0000000000080000)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PORT1_OFFSET",'h0000000000080000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PORT1_OFFSET",'h0000000000080000, rdata), UVM_LOW)


        // Write and Read to PORT2_OFFSET

        tb_env0.fme_regs.PORT2_OFFSET.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PORT2_OFFSET.cg_vals.sample();`endif
        tb_env0.fme_regs.PORT2_OFFSET.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PORT2_OFFSET.cg_vals.sample();`endif
        rw_bits = 'heffffff8f0000000;
        wdata = rw_bits & wdata;
        wdata[23:16] ='h10;
        if(rdata !== 'h0000000000100000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PORT2_OFFSET",'h0000000000100000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PORT2_OFFSET",'h0000000000100000 , rdata), UVM_LOW)

        // Write and Read to PORT3_OFFSET

        tb_env0.fme_regs.PORT3_OFFSET.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PORT3_OFFSET.cg_vals.sample();`endif
        tb_env0.fme_regs.PORT3_OFFSET.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PORT3_OFFSET.cg_vals.sample();`endif
        rw_bits = 'heffffff8f2000000;
        wdata = rw_bits & wdata;
        wdata[23:16] ='h18;
        if(rdata !== 'h0000000000180000 )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PORT3_OFFSET",'h0000000000180000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PORT3_OFFSET",'h0000000000180000, rdata), UVM_LOW)


        // Write and Read to FAB_STATUS

        tb_env0.fme_regs.FAB_STATUS.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FAB_STATUS.cg_vals.sample();`endif
        tb_env0.fme_regs.FAB_STATUS.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FAB_STATUS.cg_vals.sample();`endif
        rw_bits = 'hfffffffffffffeff;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FAB_STATUS",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FAB_STATUS",'h0, rdata), UVM_LOW)



        // Write and Read to THERM_MNGM_DFH

        tb_env0.fme_regs.THERM_MNGM_DFH.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.THERM_MNGM_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.THERM_MNGM_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.THERM_MNGM_DFH.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if( rdata !== 'h3000000020000001)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "THERM_MNGM_DFH",'h3000000020000001, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","THERM_MNGM_DFH",'h3000000020000001, rdata), UVM_LOW)


        // Write and Read to TMP_THRESHOLD

        tb_env0.fme_regs.TMP_THRESHOLD.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.TMP_THRESHOLD.cg_vals.sample();`endif
        tb_env0.fme_regs.TMP_THRESHOLD.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.TMP_THRESHOLD.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata =='h000000005D005F5A)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "TMP_THRESHOLD",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","TMP_THRESHOLD",'h000000005D005F5A, rdata), UVM_LOW)



        // Write and Read to TMP_RDSENSOR_FMT1

        tb_env0.fme_regs.TMP_RDSENSOR_FMT1.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.TMP_RDSENSOR_FMT1.cg_vals.sample();`endif
        tb_env0.fme_regs.TMP_RDSENSOR_FMT1.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.TMP_RDSENSOR_FMT1.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "TMP_RDSENSOR_FMT1",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","TMP_RDSENSOR_FMT1",'h0, rdata), UVM_LOW)


        // Write and Read to TMP_RDSENSOR_FMT2

        tb_env0.fme_regs.TMP_RDSENSOR_FMT2.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.TMP_RDSENSOR_FMT2.cg_vals.sample();`endif
        tb_env0.fme_regs.TMP_RDSENSOR_FMT2.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.TMP_RDSENSOR_FMT2.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "TMP_RDSENSOR_FMT2",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","TMP_RDSENSOR_FMT2",'h0, rdata), UVM_LOW)


        // Write and Read to TMP_THRESHOLD_CAPABILITY

        tb_env0.fme_regs.TMP_THRESHOLD_CAPABILITY.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.TMP_THRESHOLD_CAPABILITY.cg_vals.sample();`endif
        tb_env0.fme_regs.TMP_THRESHOLD_CAPABILITY.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.TMP_THRESHOLD_CAPABILITY.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 64'h1  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "TMP_THRESHOLD_CAPABILITY",64'h1, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","TMP_THRESHOLD_CAPABILITY",64'h1, rdata), UVM_LOW)



        // Write and Read to GLBL_PERF_DFH

        tb_env0.fme_regs.GLBL_PERF_DFH.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.GLBL_PERF_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.GLBL_PERF_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.GLBL_PERF_DFH.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'h3000000010000007  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "GLBL_PERF_DFH",'h3000000010000007 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","GLBL_PERF_DFH",'h3000000010000007 , rdata), UVM_LOW)
     
       // Write and Read to DUMMY_3008

        tb_env0.fme_regs.DUMMY_3008.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3008.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_3008.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3008.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_3008", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_3008",'h0, rdata), UVM_LOW)
     
       // Write and Read to DUMMY_3010

        tb_env0.fme_regs.DUMMY_3010.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3010.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_3010.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3010.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_3010", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_3010",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_3018

        tb_env0.fme_regs.DUMMY_3018.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3018.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_3018.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3018.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_3018", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_3018",'h0, rdata), UVM_LOW)

       // Write and Read to FPMON_CLK_CTR

        tb_env0.fme_regs.FPMON_CLK_CTR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FPMON_CLK_CTR.cg_vals.sample();`endif
        tb_env0.fme_regs.FPMON_CLK_CTR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FPMON_CLK_CTR.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FPMON_CLK_CTR", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FPMON_CLK_CTR",'h0, rdata), UVM_LOW)



        // Write and Read to GLBL_ERROR_DFH

    //SSS    tb_env0.fme_regs.GLBL_ERROR_DFH.write(status,wdata);
    //SSS    `ifdef COV tb_env0.fme_regs.GLBL_ERROR_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.GLBL_ERROR_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.GLBL_ERROR_DFH.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'h30000000C0001004  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "GLBL_ERROR_DFH",'h30000000C0001004, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","GLBL_ERROR_DFH",'h30000000C0001004, rdata), UVM_LOW)


        // Write and Read to FME_ERROR0_MASK

        tb_env0.fme_regs.FME_ERROR0_MASK.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0_MASK.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_ERROR0_MASK.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0_MASK.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_ERROR0_MASK",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_ERROR0_MASK",'h0, rdata), UVM_LOW)


        // Write and Read to FME_ERROR0

        tb_env0.fme_regs.FME_ERROR0.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_ERROR0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_ERROR0",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_ERROR0",'h0, rdata), UVM_LOW)


        // Write and Read to PCIE0_ERROR

        tb_env0.fme_regs.PCIE0_ERROR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PCIE0_ERROR.cg_vals.sample();`endif
        tb_env0.fme_regs.PCIE0_ERROR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PCIE0_ERROR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE0_ERROR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PCIE0_ERROR",'h0, rdata), UVM_LOW)


       // Write and Read to DUMMY_4028

        tb_env0.fme_regs.DUMMY_4028.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_4028.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_4028.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_4028.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_4028", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_4028",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_4030

        tb_env0.fme_regs.DUMMY_4030.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_4030.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_4030.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_4030.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_4030", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_4030",'h0, rdata), UVM_LOW)





        // Write and Read to PCIE0_ERROR_MASK

        tb_env0.fme_regs.PCIE0_ERROR_MASK.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.PCIE0_ERROR_MASK.cg_vals.sample();`endif
        tb_env0.fme_regs.PCIE0_ERROR_MASK.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.PCIE0_ERROR_MASK.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "PCIE0_ERROR_MASK",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","PCIE0_ERROR_MASK",'h0, rdata), UVM_LOW)


        // Write and Read to FME_FIRST_ERROR

        tb_env0.fme_regs.FME_FIRST_ERROR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_FIRST_ERROR.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_FIRST_ERROR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_FIRST_ERROR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_FIRST_ERROR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_FIRST_ERROR",'h0, rdata), UVM_LOW)


        // Write and Read to FME_NEXT_ERROR

        tb_env0.fme_regs.FME_NEXT_ERROR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_NEXT_ERROR.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_NEXT_ERROR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_NEXT_ERROR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_NEXT_ERROR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_NEXT_ERROR",'h0, rdata), UVM_LOW)


        // Write and Read to RAS_NOFAT_ERROR

        tb_env0.fme_regs.RAS_NOFAT_ERROR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_NOFAT_ERROR.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_NOFAT_ERROR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_NOFAT_ERROR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_NOFAT_ERROR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_NOFAT_ERROR",'h0, rdata), UVM_LOW)


        // Write and Read to RAS_NOFAT_ERROR_MASK

        tb_env0.fme_regs.RAS_NOFAT_ERROR_MASK.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_NOFAT_ERROR_MASK.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_NOFAT_ERROR_MASK.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_NOFAT_ERROR_MASK.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_NOFAT_ERROR_MASK",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_NOFAT_ERROR_MASK",'h0, rdata), UVM_LOW)

        // Write and Read to RAS_CATFAT_ERR

        tb_env0.fme_regs.RAS_CATFAT_ERR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_CATFAT_ERR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_CATFAT_ERR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_CATFAT_ERR",'h0, rdata), UVM_LOW)

        // Write and Read to RAS_CATFAT_ERR

        tb_env0.fme_regs.RAS_CATFAT_ERR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_CATFAT_ERR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_CATFAT_ERR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_CATFAT_ERR",'h0, rdata), UVM_LOW)

        // Write and Read to RAS_ERROR_INJ

        tb_env0.fme_regs.RAS_ERROR_INJ.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_ERROR_INJ.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_ERROR_INJ.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_ERROR_INJ.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_ERROR_INJ",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_ERROR_INJ",'h0, rdata), UVM_LOW)

        // Write and Read to GLBL_ERROR_CAPABILITY

        tb_env0.fme_regs.GLBL_ERROR_CAPABILITY.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.GLBL_ERROR_CAPABILITY.cg_vals.sample();`endif
        tb_env0.fme_regs.GLBL_ERROR_CAPABILITY.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.GLBL_ERROR_CAPABILITY.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'hd  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "GLBL_ERROR_CAPABILITY",'hd, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","GLBL_ERROR_CAPABILITY",'hd, rdata), UVM_LOW)


        // Write and Read to FME_PR_DFH

        tb_env0.fme_regs.FME_PR_DFH.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_PR_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_DFH.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'h30000000B0001005  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_PR_DFH",'h30000000B0001005, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_PR_DFH",'h30000000B0001005, rdata), UVM_LOW)

        // Write and Read to FME_PR_CTRL

        tb_env0.fme_regs.FME_PR_CTRL.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_CTRL.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_PR_CTRL.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_CTRL.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_PR_CTRL",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_PR_CTRL",'h0, rdata), UVM_LOW)

        // Write and Read to FAB_CAPABILITY

        tb_env0.fme_regs.FAB_CAPABILITY.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FAB_CAPABILITY.cg_vals.sample();`endif
        tb_env0.fme_regs.FAB_CAPABILITY.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FAB_CAPABILITY.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'h14021000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FAB_CAPABILITY",'h14021000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FAB_CAPABILITY",'h14021000, rdata), UVM_LOW)

        // Write and Read to FME_PR_STATUS

        tb_env0.fme_regs.FME_PR_STATUS.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_STATUS.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_PR_STATUS.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_STATUS.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_PR_STATUS",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_PR_STATUS",'h0, rdata), UVM_LOW)

       // Write and Read to FME_PR_DATA

       tb_env0.fme_regs.FME_PR_DATA.write(status,wdata);
       `ifdef COV tb_env0.fme_regs.FME_PR_DATA.cg_vals.sample();`endif
       tb_env0.fme_regs.FME_PR_DATA.read(status,rdata);
       `ifdef COV tb_env0.fme_regs.FME_PR_DATA.cg_vals.sample();`endif
     //  rw_bits = 'h00000000ffffC0fB;
     //  wdata = rw_bits & wdata;
       if(rdata !== wdata  )
           `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_PR_DATA",wdata, rdata))
       else
           `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_PR_DATA",wdata, rdata), UVM_LOW)


        // Write and Read to FME_PR_ERROR

        tb_env0.fme_regs.FME_PR_ERROR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_ERROR.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_PR_ERROR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_PR_ERROR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FME_PR_ERROR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FME_PR_ERROR",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5028

        tb_env0.fme_regs.DUMMY_5028.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5028.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5028.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5028.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5028", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5028",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5030

        tb_env0.fme_regs.DUMMY_5030.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5030.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5030.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5030.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5030", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5030",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5038

        tb_env0.fme_regs.DUMMY_5038.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5038.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5038.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5038.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5038", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5038",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5040

        tb_env0.fme_regs.DUMMY_5040.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5040.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5040.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5040.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5040", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5040",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5048

        tb_env0.fme_regs.DUMMY_5048.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5048.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5048.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5048.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5048", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5048",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5050

        tb_env0.fme_regs.DUMMY_5050.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5050.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5050.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5050.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5050", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5050",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5058

        tb_env0.fme_regs.DUMMY_5058.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5058.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5058.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5058.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5058", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5058",'h0, rdata), UVM_LOW)
       // Write and Read to DUMMY_5060

        tb_env0.fme_regs.DUMMY_5060.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5060.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5060.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5060.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5060", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5060",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5068

        tb_env0.fme_regs.DUMMY_5068.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5068.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5068.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5068.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5068", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5068",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5070

        tb_env0.fme_regs.DUMMY_5070.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5070.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5070.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5070.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5070", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5070",'h0, rdata), UVM_LOW)


       // Write and Read to DUMMY_5078

        tb_env0.fme_regs.DUMMY_5078.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5078.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5078.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5078.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5078", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5078",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5080

        tb_env0.fme_regs.DUMMY_5080.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5080.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5080.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5080.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5080", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5080",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5088

        tb_env0.fme_regs.DUMMY_5088.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5088.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5088.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5088.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5088", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5088",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5090

        tb_env0.fme_regs.DUMMY_5090.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5090.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5090.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5090.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5090", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5090",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_5098

        tb_env0.fme_regs.DUMMY_5098.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5098.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_5098.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_5098.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_5098", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5098",'h0, rdata), UVM_LOW)

       // Write and Read to DUMMY_50A0

        tb_env0.fme_regs.DUMMY_50A0.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_50A0.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_50A0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_50A0.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
    //    if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_50A0", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_5070",'h0, rdata), UVM_LOW)

        // Write and Read to MSIX_ADDR0

        tb_env0.fme_regs.MSIX_ADDR0.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR0.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR0.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !==  wdata )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR0",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR0",wdata, rdata), UVM_LOW)


        // Write and Read to MSIX_ADDR1

        tb_env0.fme_regs.MSIX_ADDR1.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR1.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR1.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR1.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR1",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR1",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_ADDR2

        tb_env0.fme_regs.MSIX_ADDR2.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR2.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR2.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR2.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
      //  wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR2",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR2",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_ADDR3

        tb_env0.fme_regs.MSIX_ADDR3.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR3.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR3.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR3.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR3",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR3",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_ADDR4

        tb_env0.fme_regs.MSIX_ADDR4.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR4.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR4.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR4.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
      //  wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR4",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR4",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_ADDR5

        tb_env0.fme_regs.MSIX_ADDR5.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR5.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR5.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR5.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR5",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR5",wdata, rdata), UVM_LOW)


        // Write and Read to MSIX_ADDR6

        tb_env0.fme_regs.MSIX_ADDR6.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR6.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR6.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR6.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR6",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR6",wdata, rdata), UVM_LOW)


        // Write and Read to MSIX_ADDR7

        tb_env0.fme_regs.MSIX_ADDR7.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR7.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_ADDR7.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_ADDR7.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_ADDR7",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_ADDR7",wdata, rdata), UVM_LOW)


        // Write and Read to MSIX_CTLDAT0 default

        tb_env0.fme_regs.MSIX_CTLDAT0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT0.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT0",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT0",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT0

        tb_env0.fme_regs.MSIX_CTLDAT0.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT0.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT0.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT0.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT0",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT0",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT1 default

        tb_env0.fme_regs.MSIX_CTLDAT1.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT1.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT1",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT1",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT1

        tb_env0.fme_regs.MSIX_CTLDAT1.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT1.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT1.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT1.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
      //  wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT1",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT1",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT2 default

        tb_env0.fme_regs.MSIX_CTLDAT2.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT2.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT2",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT2",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT2

        tb_env0.fme_regs.MSIX_CTLDAT2.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT2.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT2.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT2.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
     //   wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT2",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT2",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT3 default

        tb_env0.fme_regs.MSIX_CTLDAT3.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT3.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT3",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT3",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT3

        tb_env0.fme_regs.MSIX_CTLDAT3.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT3.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT3.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT3.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
      //  wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT3",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT3",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT4 default

        tb_env0.fme_regs.MSIX_CTLDAT4.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT4.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT4",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT4",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT4

        tb_env0.fme_regs.MSIX_CTLDAT4.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT4.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT4.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT4.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT4",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT4",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT5 default

        tb_env0.fme_regs.MSIX_CTLDAT5.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT5.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT5",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT5",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT5

        tb_env0.fme_regs.MSIX_CTLDAT5.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT5.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT5.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT5.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT5",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT5",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT6 default

        tb_env0.fme_regs.MSIX_CTLDAT6.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT6.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT6",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT6",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT6

        tb_env0.fme_regs.MSIX_CTLDAT6.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT6.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT6.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT6.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
      //  wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT6",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT6",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_CTLDAT7 default

        tb_env0.fme_regs.MSIX_CTLDAT7.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT7.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        //wdata = rw_bits & wdata;
        if(rdata !== 'h0000000100000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT7",'h0000000100000000, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT7",'h0000000100000000, rdata), UVM_LOW)
        // Write and Read to MSIX_CTLDAT7

        tb_env0.fme_regs.MSIX_CTLDAT7.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT7.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_CTLDAT7.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_CTLDAT7.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
       // wdata = rw_bits & wdata;
        if(rdata !== wdata  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_CTLDAT7",wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_CTLDAT7",wdata, rdata), UVM_LOW)

        // Write and Read to MSIX_PBA

     //   tb_env0.fme_regs.MSIX_PBA.write(status,wdata);
     //   `ifdef COV tb_env0.fme_regs.MSIX_PBA.cg_vals.sample();`endif
        tb_env0.fme_regs.MSIX_PBA.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_PBA.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_PBA",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_PBA",'h0, rdata), UVM_LOW)

        // Write and Read to MSIX_COUNT_CSR

        tb_env0.fme_regs.MSIX_COUNT_CSR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.MSIX_COUNT_CSR.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "MSIX_COUNT_CSR",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","MSIX_COUNT_CSR",'h0, rdata), UVM_LOW)


        

        //Accessing Scratchpad Registers
        // FME DFH
        addr = `PF0_BAR0+'h00;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // FME Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h28;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata !== wdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = `PF0_BAR0+'h28+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        for (int j= 0 ; j < pcie_tlp_count ; j++ )
        begin
          this.randomize();
          
          `uvm_do_on_with(pcie_tran,p_sequencer.root_virt_seqr.driver_transaction_seqr[0],
                         { pcie_tran.transaction_type == pcie_trans_type;
                           pcie_tran.address == (BAR_OFFSET + ADDR );
                           if(pcie_tran.transaction_type == `PCIE_DRIVER_TRANSACTION_CLASS::MEM_RD)
                             pcie_tran.length inside {1,2};
                           else pcie_tran.length inside {1,2};
                           pcie_tran.traffic_class == 0; 
                           pcie_tran.address_translation == 0;
                           pcie_tran.first_dw_be   == 4'b1111;
                           if(pcie_tran.length==1)pcie_tran.last_dw_be    == 4'b0000;
                           else pcie_tran.last_dw_be    == 4'b1111;
                           pcie_tran.ep == 0;
                           pcie_tran.th == 0;
                           pcie_tran.block == 0; });
         `uvm_info("PCIE FIM AFU MMIO ACC",$sformatf("Access on address = %x , BAR = %x , transaction type = %s, packet no. = %d",BAR_OFFSET + ADDR,BAR_OFFSET,pcie_tran.transaction_type,j),UVM_LOW)
        end
        #5us; // Buffer time
   
        `uvm_info(get_name(), "Exiting fme_csr_seq...", UVM_LOW)
    endtask : body

endclass : fme_csr_seq

`endif // FME_CSR_SEQ_SVH

