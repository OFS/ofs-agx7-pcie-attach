//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class fme_csr_stress_seq is executed by afu_stress_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef FME_CSR_STRESS_SEQ_SVH
`define FME_CSR_STRESS_SEQ_SVH

class fme_csr_stress_seq extends base_seq;
    `uvm_object_utils(fme_csr_stress_seq)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name = "fme_csr_stress_seq");
        super.new(name);
    endfunction : new

    task body();
       bit [63:0]        wdata, rdata, addr,rw_bits,exp_data;
        uvm_reg_data_t   ctl_data;
        uvm_status_e     status;

        super.body();
        `uvm_info(get_name(), "Entering fme_csr_stress_seq...", UVM_LOW)
        tb_env0.fme_regs.FME_DFH.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_DFH.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_DFH.cg_vals.sample();`endif
        rw_bits = 'h0;
       if(rdata !== 'h4000000010000000)
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

      // Write and Read to BITSTREAM_ID

        tb_env0.fme_regs.BITSTREAM_ID.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.BITSTREAM_ID.cg_vals.sample();`endif
        tb_env0.fme_regs.BITSTREAM_ID.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.BITSTREAM_ID.cg_vals.sample();`endif
        rw_bits = 'hfffffffffffffeff;
        wdata = rw_bits & wdata;
        if(rdata[63:48] !== 'h0123)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "BITSTREAM_ID",'h0123, rdata[63:48]))
        else if(rdata[39:0] !== 'h0789ABCDEF)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "BITSTREAM_ID",'h0789ABCDEF, rdata[39:0]))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","BITSTREAM_ID",'h0123000789ABCDEF, rdata), UVM_LOW)
   
     // Write and Read to BITSTREAM_MD

        tb_env0.fme_regs.BITSTREAM_MD.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.BITSTREAM_MD.cg_vals.sample();`endif
        tb_env0.fme_regs.BITSTREAM_MD.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.BITSTREAM_MD.cg_vals.sample();`endif
        rw_bits = 'hfffffffffffffeff;
        wdata = rw_bits & wdata;
        if(rdata !== 'h000000000AAAAAAA)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "BITSTREAM_MD",'h000000000AAAAAAA, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","BITSTREAM_MD",'h000000000AAAAAAA, rdata), UVM_LOW)

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
        tb_env0.fme_regs.TMP_RDSENSOR_FMT2.read(status,rdata);
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
        if(rdata !== 'h3000000010000000  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "GLBL_PERF_DFH",'h3000000010000000 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","GLBL_PERF_DFH",'h3000000010000000 , rdata), UVM_LOW)
     
       // Write and Read to DUMMY_3008

        tb_env0.fme_regs.DUMMY_3008.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3008.cg_vals.sample();`endif
        tb_env0.fme_regs.DUMMY_3008.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.DUMMY_3008.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
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
               `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_3018", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_3018",'h0, rdata), UVM_LOW)

    
        // Write and Read to FPMON_FAB_CTR

           tb_env0.fme_regs.FPMON_FAB_CTR.write(status,wdata);
          `ifdef COV tb_env0.fme_regs.FPMON_FAB_CTR.cg_vals.sample();`endif
           tb_env0.fme_regs.FPMON_FAB_CTR.read(status,rdata);
          `ifdef COV tb_env0.fme_regs.FPMON_FAB_CTR.cg_vals.sample();`endif
           rw_bits = 'h0;

           if(rdata !=='h0)
        //    if(rdata !== 0  )
                `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FPMON_FAB_CTR", 'h0 , rdata))
           else
                `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FPMON_FAB_CTR",'h0, rdata), UVM_LOW)


       // Write and Read to FPMON_CLK_CTR

        tb_env0.fme_regs.FPMON_CLK_CTR.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FPMON_CLK_CTR.cg_vals.sample();`endif
        tb_env0.fme_regs.FPMON_CLK_CTR.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FPMON_CLK_CTR.cg_vals.sample();`endif
        rw_bits = 'h0;

       if(rdata !=='h0)
                `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "FPMON_CLK_CTR", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","FPMON_CLK_CTR",'h0, rdata), UVM_LOW)



        tb_env0.fme_regs.GLBL_ERROR_DFH.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.GLBL_ERROR_DFH.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 'h30000000E0001004  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "GLBL_ERROR_DFH",'h30000000E0001004, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","GLBL_ERROR_DFH",'h30000000E0001004, rdata), UVM_LOW)


        // Write and Read to FME_ERROR0_MASK

        tb_env0.fme_regs.FME_ERROR0_MASK.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0_MASK.cg_vals.sample();`endif
        tb_env0.fme_regs.FME_ERROR0_MASK.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.FME_ERROR0_MASK.cg_vals.sample();`endif
        rw_bits = 'h0000000000000001;
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
         tb_env0.fme_regs.PCIE0_ERROR.read(status,rdata);
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
              `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "DUMMY_4030", 'h0 , rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","DUMMY_4030",'h0, rdata), UVM_LOW)


        // Write and Read to PCIE0_ERROR_MASK

        tb_env0.fme_regs.PCIE0_ERROR_MASK.write(status,wdata);
         tb_env0.fme_regs.PCIE0_ERROR_MASK.read(status,rdata);
         rw_bits = 'h00000000ffffC0fB;
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

        // Write and Read to RAS_CATFAT_ERR_MASK

        tb_env0.fme_regs.RAS_CATFAT_ERR_MASK.write(status,wdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR_MASK.cg_vals.sample();`endif
        tb_env0.fme_regs.RAS_CATFAT_ERR_MASK.read(status,rdata);
        `ifdef COV tb_env0.fme_regs.RAS_CATFAT_ERR_MASK.cg_vals.sample();`endif
        rw_bits = 'h00000000ffffC0fB;
        wdata = rw_bits & wdata;
        if(rdata !== 0  )
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Register = %0s, Exp = %0h, Act = %0h", "RAS_CATFAT_ERR_MASK",'h0, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! Register = %0s, data = %0h","RAS_CATFAT_ERR_MASK",'h0, rdata), UVM_LOW)

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

   
        //Accessing Scratchpad Registers
        // FME DFH
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR;        
        mmio_read64 (.addr_(addr), .data_(rdata));
        
        // FME Scratchpad 64 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR+'h28;
        
        mmio_write64(.addr_(addr), .data_(wdata));
        mmio_read64 (.addr_(addr), .data_(rdata));
 
        if(rdata !== wdata)
            `uvm_error(get_name(), $psprintf("Data mismatch 64! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 64! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

        // FME Scratchpad 32 bit access
        assert(std::randomize(wdata));
        addr = tb_cfg0.PF0_BAR0+FME_BASE_ADDR+'h28+'h4;
        
        mmio_write32(.addr_(addr), .data_(wdata));
        mmio_read32 (.addr_(addr), .data_(rdata));
 
        if(wdata[31:0] !== rdata[31:0])
            `uvm_error(get_name(), $psprintf("Data mismatch 32! Addr = %0h, Exp = %0h, Act = %0h", addr, wdata, rdata))
        else
            `uvm_info(get_name(), $psprintf("Data match 32! addr = %0h, data = %0h", addr, rdata), UVM_LOW)

         #5us; // Buffer time
              
        `uvm_info(get_name(), "Exiting fme_csr_stress_seq...", UVM_LOW)
    endtask : body

endclass : fme_csr_stress_seq

`endif // FME_CSR_STRESS_SEQ_SVH

