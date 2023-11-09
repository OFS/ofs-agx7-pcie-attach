## Copyright 2021 Intel Corporation
## SPDX-License-Header: MIT

***Test Description***
This is the unit test for pg_csr block and it's connectivity to fabric. The
test issues mmio Rd/Wr requests targetting the csrs in port_gasket. This test
does not do any functional testing of partial reconfiguration, user clock or
remote stp.

Description of test modules:
   * test_csr_defs.sv   - Defines CSR addresses used in the test. 
   * unit_test.sv       - Defines the unit test procedure for the respective test.
   * set_params.sh      - Defines to run the test.

***Running the test***
To run the test:
 >>> For External Customers:
       Follow steps in $OFS_ROOTDIR/sim/readme.txt
 >>> For Internal Customers:
  1.) The following list of environment variables should be set up in the user's shell prior to running this test:
        a.) OFS_ROOTDIR:.............Root directory of the OFS code repo.
                                     Example:  export OFS_ROOTDIR="$(git rev-parse --show-toplevel)"
        b.) PYTHON:..................Sets the location of the Python interpreter.  Currently the repo uses Python Version 3.7.7.
                                     Example:  export PYTHON="/tools/python/3.7.7/1/linux64/suse12/bin/python"
        c.) PERL:....................Sets the location of the Perl interpreter.  Currently the repo uses Perl 5.8.8.
                                     Example:  export PERL="/tools/perl/5.8.8"
        d.) CMAKE:...................Sets the location of cmake used in the build.  Currently the repo uses cmake 3.11.4.
                                     Example:  CMAKE="/tools/cmake/3.11.4"
        e.) GCC:.....................Sets the location of gcc used during build.  Currently the repo uses gcc version 7.2.0.
                                     Example: GCC="/tools/gcc/7.2.0"
        f.) QUARTUS_VER_AC:..........Sets the location of Quartus used during build.  The current version used is Quartus 21.3, Build 170.
                                     Example: QUARTUS_VER_AC="/tools/acds_ac/quartus_21.3_b170/acds"
        g.) VCS_AC:..................Sets the location of the VCS license needed for this tool.
                                     Example: VCS_AC="/tools/licenses/synopsys/vcs/R-2020.12-SP1-1 vcs-vcsmx-lic"
        h.) QUARTUS_ROOTDIR:.........This is used as a separate reference to the Quartus location.  Set this variable to the same location as $QUARTUS_VER_AC.  
                                     Example: QUARTUS_ROOTDIR=$QUARTUS_VER_AC
        i.) WORKDIR:.................This is used as a separate reference to the repo location.  Set this variable to the same location as $OFS_ROOTDIR.
                                     Example: WORKDIR=$OFS_ROOTDIR
        j.) VERDIR:..................This is a path to the n6001 verification base directory.
                                     Example: VERDIR=$OFS_ROOTDIR/verification
        k.) VIPDIR:..................This is a path set to the VIP simulation library location.  This is will likely be the same location as the verification directory.
                                     Example: VIPDIR=$VERDIR
        l.) QUARTUS_HOME:............This is used as a separate reference to the Quartus location.  Set this variable to the same location as $QUARTUS_ROOTDIR.
                                     Example: QUARTUS_HOME=$QUARTUS_ROOTDIR
        m.) QUARTUS_INSTALL_DIR:.....This is used as a separate reference to the Quartus location.  Set this variable to the same location as $QUARTUS_ROOTDIR.
                                     Example: QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
        n.) QUARTUS_ROOTDIR_OVERRIDE:This is used as a separate reference to the Quartus location.  Set this variable to the same location as $QUARTUS_ROOTDIR.
                                     Example: QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
        o.) DESIGNWARE_HOME:.........Sets the location of the Synopsys designware library.
                                     Example: DESIGNWARE_HOME="/tools/synopsys/vip_common/vip_Q-2020.03A"
        p.) VCS_HOME:................Sets the location of the Synopsys VCS tool.
                                     Example: VCS_HOME="/tools/synopsys/vcsmx/R-2020.12-SP1-1/linux64/suse"
  2.) In $OFS_ROOTDIR/ofs-common/scripts/common/sim, run the following command. Environment variable OFS_ROOTDIR is set in previous step by setup.sh
	  VCS   : sh run_sim.sh TEST=port_gasket_test
	  VCSMX : sh run_sim.sh TEST=port_gasket_test VCSMX=1
	  MSIM  : sh run_sim.sh TEST=port_gasket_test MSIM=1
         
        
        
