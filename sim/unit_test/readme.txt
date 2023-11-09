## Copyright 2021 Intel Corporation
## SPDX-License-Header: MIT
   
#

This directory contains unit tests for the n6001 FIM.

***Running the test***
 In $OFS_ROOTDIR/ofs-common/scripts/common/sim, run the following command. Environment variable OFS_ROOTDIR is set in previous step by setup.sh
	  
      VCS   : sh run_sim.sh TEST=<test name>
	  VCSMX : sh run_sim.sh TEST=<test name> VCSMX=1
	  MSIM  : sh run_sim.sh TEST=<test name> MSIM=1

      where <test name> is the name of the directory containing the test to be ran. 
      
      For example, to run the fme_csr_access test, you would go to $OFS_ROOTDIR/ofs-common/scripts/common/sim and run: 

      VCS   : sh run_sim.sh TEST=fme_csr_access
	  VCSMX : sh run_sim.sh TEST=fme_csr_access VCSMX=1
	  MSIM  : sh run_sim.sh TEST=fme_csr_access MSIM=1
