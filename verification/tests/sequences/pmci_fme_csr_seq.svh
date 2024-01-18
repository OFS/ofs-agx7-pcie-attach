//Copyright (C) 2021 Intel Corporation
//SPDX-License-Identifier: MIT
//===============================================================================================================
/**
 * Abstract:
 * class pmci_fme_csr_seq is executed by pmci_fme_csr_test.
 * 
 * This sequence uses the RAL model for front-door access of registers 
 * The sequence also uses mmio_read/write tasks for 32/64bit access (for coverage purpose) defined in base_sequence
 *
 * Sequence is running on virtual_sequencer .
 */
//===============================================================================================================

`ifndef PMCI_FME_CSR_SEQ_SVH
`define PMCI_FME_CSR_SEQ_SVH

class pmci_fme_csr_seq extends base_seq;
  `uvm_object_utils(pmci_fme_csr_seq)
  `uvm_declare_p_sequencer(virtual_sequencer)

  logic [17:0] address;
  logic [63:0] data,exp_data;
  logic [7:0]  wstrb;
  
  function new(string name = "pmci_fme_csr_seq");
    super.new(name);
  endfunction : new

  task body();
    super.body();

    address =  FME_BASE_ADDR;
    exp_data =64'h4000000010000000;
    `uvm_info(get_name(), $psprintf("Reading from DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address =  FME_BASE_ADDR + 18'h8;
    exp_data =64'h82FE38F0F9E17764;
    `uvm_info(get_name(), $psprintf("Reading from FME_AFU_ID_L Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h10;
    exp_data =64'hBFAF2AE94A5246E3;     
    `uvm_info(get_name(), $psprintf("Reading from FME_AFU_ID_H Register"), UVM_LOW)
    rd_tx_register(address,exp_data);

    address =  FME_BASE_ADDR + 18'h0018;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FME_NEXT_AFU Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0020;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_0020 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0028;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FME_SCRATCHPAD0 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
 
    address = FME_BASE_ADDR +18'h0030;
    exp_data =64'h0000000014021000;
    `uvm_info(get_name(), $psprintf("Reading from FAB_CAPABILITY Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0038;
    exp_data =64'h1000000700000000;  //bit 60 is set to 0 as port is not implemented
    `uvm_info(get_name(), $psprintf("Reading from PORT0_OFFSET Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0040;
    exp_data =64'h0000000000080000;
    `uvm_info(get_name(), $psprintf("Reading from PORT1_OFFSET Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0048;
    exp_data =64'h0000000000100000;
    `uvm_info(get_name(), $psprintf("Reading from PORT2_OFFSET Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h0050;
    exp_data =64'h0000000000180000;
    `uvm_info(get_name(), $psprintf("Reading from PORT3_OFFSET Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0058;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FAB_STATUS Register"), UVM_LOW)
    rd_tx_register(address,exp_data);
 
//In Bitstream_id register the field fim_variant[47:40] is given as "45" in expected data.As we are not comparing data here and getting error from AXI VIP. 
    address = FME_BASE_ADDR +  18'h0060;
    exp_data =64'h0123450789ABCDEF; 
    `uvm_info(get_name(), $psprintf("Reading from BITSTREAM_ID Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h0068;
    exp_data =64'h000000000AAAAAAA; 
    `uvm_info(get_name(), $psprintf("Reading from BITSTREAM_MD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address =  FME_BASE_ADDR + 18'h1000;
    exp_data =64'h3000000020000001;
    `uvm_info(get_name(), $psprintf("Reading from THERM_MNGM_DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h1008;
    exp_data =64'h000000005D005F5A;
    `uvm_info(get_name(), $psprintf("Reading from TMP_THRESHOLD Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h1010;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from TMP_RDSENSOR_FMT1 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h1018;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from TMP_RDSENSOR_FMT2 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h1020;
    exp_data =64'h0000000000000001;
    `uvm_info(get_name(), $psprintf("Reading from TMP_THRESHOLD_CAPABILITY Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address =  FME_BASE_ADDR + 18'h3000;
    exp_data =64'h3000000010000000;
    `uvm_info(get_name(), $psprintf("Reading from GLBL_PERF_DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h3008;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_3008 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h3010;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_3010 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h3018;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_3018 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h3020;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FPMON_FAB_CTL Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address = FME_BASE_ADDR +  18'h3028;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FPMON_FAB_CTR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h3030;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FPMON_CLK_CTR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4000;
    exp_data =64'h30000000e0001004;
    `uvm_info(get_name(), $psprintf("Reading from GLBL_ERROR_DFH Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h4008;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FME_ERROR0_MASK Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h4018;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from PCIE0_ERROR_MASK Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address = FME_BASE_ADDR +  18'h4020;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from PCIE0_ERROR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h4028;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_4028 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4030;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from DUMMY_4030 Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4038;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FME_FIRST_ERROR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h4040;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from FME_NEXT_ERROR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address =  FME_BASE_ADDR + 18'h4048;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from RAS_NOFAT_ERROR_MASK Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4050;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from RAS_NOFAT_ERROR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4058;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from RAS_CATFAT_ERR_MASK Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address = FME_BASE_ADDR +  18'h4060;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from RAS_CATFAT_ERR Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address =  FME_BASE_ADDR + 18'h4068;
    exp_data =64'h0000000000000000;
    `uvm_info(get_name(), $psprintf("Reading from RAS_ERROR_INJ Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	
	address =  FME_BASE_ADDR + 18'h4070;
    exp_data =64'h000000000000000D;
    `uvm_info(get_name(), $psprintf("Reading from GLBL_ERROR_CAPABILITY Register"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    address  = FME_BASE_ADDR + 18'h0028;
    data     =64'hffff_ffff_ffff_ffff;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to FME_SCRATCHPAD0"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

    `uvm_info(get_name(), $psprintf("Read and write for FME registers"), UVM_LOW)
                                                                                                
    address  = FME_BASE_ADDR + 18'h0028;
    exp_data =64'hffff_ffff_ffff_ffff;
    `uvm_info(get_name(), $psprintf("Reading from FME_SCRATCHPAD0"), UVM_LOW)
    rd_tx_register(address,exp_data); 

 
    address  = FME_BASE_ADDR + 18'h0038;
    data     =64'h1180_0007_0000_0000;
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PORT0_OFFSET"), UVM_LOW)
    wr_tx_register(address,data,wstrb);
 
 
    address  = FME_BASE_ADDR + 18'h0038;
    exp_data =64'h1180_0007_0000_0000;           
    `uvm_info(get_name(), $psprintf("Reading from PORT0_OFFSET"), UVM_LOW)
    rd_tx_register(address,exp_data);    



    address  = FME_BASE_ADDR + 18'h0040;
    data     =64'h0180_0000_0008_0000;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PORT1_OFFSET"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

  

    address  = FME_BASE_ADDR + 18'h0040;
    exp_data =64'h0180_0000_0008_0000; 
    `uvm_info(get_name(), $psprintf("Reading from PORT1_OFFSET"), UVM_LOW)
    rd_tx_register(address,exp_data); 

    

    address  = FME_BASE_ADDR + 18'h0048;
    data     =64'h0180_0000_0010_0000;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to PORT2_OFFSET"), UVM_LOW)
    wr_tx_register(address,data,wstrb);

 

    address  = FME_BASE_ADDR + 18'h0048;
    exp_data =64'h0180_0000_0010_0000;
    `uvm_info(get_name(), $psprintf("Reading from PORT2_OFFSET"), UVM_LOW)
    rd_tx_register(address,exp_data); 
    

    address  = FME_BASE_ADDR + 18'h0050;
    data     =64'h0180_0000_0018_0000;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to PORT3_OFFSET"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h0050;
    exp_data =64'h0180_0000_0018_0000; 
    `uvm_info(get_name(), $psprintf("Reading from PORT3_OFFSET"), UVM_LOW)
    rd_tx_register(address,exp_data); 


    address  = FME_BASE_ADDR + 18'h1008;
    data     =64'h0000_1200_7f00_ffff;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to TMP_THRESHOLD"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  =FME_BASE_ADDR +18'h1008;
    exp_data =64'h0000_1200_7f00_ffff;  
    `uvm_info(get_name(), $psprintf("Reading from TMP_THRESHOLD"), UVM_LOW)
    rd_tx_register(address,exp_data); 



    address  =FME_BASE_ADDR+ 18'h3020;
    data     =64'h0000_0000_001f_0100;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to FPMON_FAB_CTL"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 'h3020;
    exp_data =64'h0000_0000_001f_0100; 
    `uvm_info(get_name(), $psprintf("Reading from FPMON_FAB_CTL"), UVM_LOW)
    rd_tx_register(address,exp_data); 
	

    address  = FME_BASE_ADDR + 18'h4008;
    data     =64'h0000_0000_0000_0001;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writing to FME_ERROR0_MASK"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4008;
    exp_data =64'h0000_0000_0000_0001; 
    `uvm_info(get_name(), $psprintf("Reading from FME_ERROR0_MASK"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    address  = FME_BASE_ADDR + 18'h4010;
    data     =64'h0000_0000_0000_0023;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to FME_ERROR0"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4010;
    exp_data =64'h0000_0000_0000_0000;  //bits are set to clear
    `uvm_info(get_name(), $psprintf("Reading from FME_ERROR0"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    address  = FME_BASE_ADDR + 18'h4048;
    data     =64'h0000_0000_0000_006c;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to RAS_NOFAT_ERROR_MASK"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4048;
    exp_data =64'h0000_0000_0000_006c; 
    `uvm_info(get_name(), $psprintf("Reading from RAS_NOFAT_ERROR_MASK"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    address  = FME_BASE_ADDR + 18'h4050;
    data     =64'h0000_0000_0000_0078;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to RAS_NOFAT_ERROR"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4050;
    exp_data =64'h0000_0000_0000_0000; //bits are set to clear
    `uvm_info(get_name(), $psprintf("Reading from RAS_NOFAT_ERROR"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    address  = FME_BASE_ADDR + 18'h4058;
    data     =64'h0000_0000_0000_0bc0;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to RAS_CATFAT_ERR_MASK"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4058;
    exp_data =64'h0000_0000_0000_0bc0; 
    `uvm_info(get_name(), $psprintf("Reading from RAS_CATFAT_ERR_MASK"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    address  = FME_BASE_ADDR + 18'h4068;
    data     =64'h0000_0000_0000_0007;     
    wstrb    =8'hFF;
    `uvm_info(get_name(), $psprintf("Writting to RAS_ERROR_INJ"), UVM_LOW)
    wr_tx_register(address,data,wstrb);


    address  = FME_BASE_ADDR + 18'h4068;
    exp_data =64'h0000_0000_0000_0007; 
    `uvm_info(get_name(), $psprintf("Reading from RAS_ERROR_INJ"), UVM_LOW)
    rd_tx_register(address,exp_data);
	

    
  endtask : body

endclass : pmci_fme_csr_seq

`endif // PMCI_FME_CSR_SEQ_SVH
