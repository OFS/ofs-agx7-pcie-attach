## Copyright 2021 Intel Corporation
## SPDX-License-Header: MIT
   
#
***Test Description***
This is the unit test for $OFS_ROOTDIR/ofs-common/src/common/fme/fme_csr.sv

It covers the following test scenarios:
   * MMIO reads to FME registers.
   * MMIO writes to FME registers.
   * Test of Register bit attributes.
   * Test of update/status values read from FME inputs through FME registers.
   * Test of update/control values written to FME registers and driven on FME outputs.
   * Test of reads/writes outside of valid register range in valid FME Ranges.

Description of test modules:
   * testbench_top.sv            - Testbench top level module where "test_csr_directed" and DUT are instantiated.
   * test_csr_directed.sv        - Main test module: This particular test drives directed tests to specified registers (not random).
   * csr_transaction_class_pkg.v - Defines the transactor objects consumed by test module.
   * run_sim.sh                  - Script to run the test, where vcs_setup.sh is called
   * vcs_setup.sh                - VCS simulation run script
   * vcs_filelist.sh             - File list


***Running the test***
To run the test:
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
        o.) IMPORT_IP_ROOTDIR:.......Sets the location of the Quartus IP library.  This value is a subdirectory of the Quartus installation.
                                     Example: IMPORT_IP_ROOTDIR=$QUARTUS_ROOTDIR/../ip
        p.) DESIGNWARE_HOME:.........Sets the location of the Synopsys designware library.
                                     Example: DESIGNWARE_HOME="/tools/synopsys/vip_common/vip_Q-2020.03A"
        q.) VCS_HOME:................Sets the location of the Synopsys VCS tool.
                                     Example: VCS_HOME="/tools/synopsys/vcsmx/R-2020.12-SP1-1/linux64/suse"
  2) In current directory, run the following command. Environment variable IOFS_BBS_ROOTDIR is set in previous step by env_vars.sh.  You could also run ". ./go".
        sh run_sim.sh
        MSIM : sh run_sim.sh OFS_ROOTDIR=$OFS_ROOTDIR MSIM=1
