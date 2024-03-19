#//Copyright 2022 Intel Corporation.
#// SPDX-License-Identifier: MIT
# ***Following instructions are for External customers only****
# ***Unit tests under this folder structure are for faster simulation of AFU Blocks and other downstream logic***
# ***This simulation uses simple pcie bfm, and will avoid enumeration sequence waiting time***

Initial Setup:
1)  Get a "bash" shell (e.g. xterm)
2)  Go to the OFS Repo root directory.
3)  Set all tool paths vcs, questasim, python etc. 
4)	Set the required environment and directory Structure variables (as shown below)
    export OFS_ROOTDIR=<FIM's root directory>
    export WORKDIR=<FIM's root directory>
5) Generate the sim files. 
   The sim files are not checked in and are generated on the fly. These files need to be generated before a simulation can be run successfully.
   In order to do this, run the following steps
    a. Got to $OFS_ROOTDIR/ofs-common/scripts/common/sim
    b  Run the script "sh gen_sim_files.sh <target>" 
	for n6001 8x25G default configuration 	-"gen_sim_files.sh --ofss $OFS_ROOTDIR/tools/ofss_config/n6001.ofss,tools/ofss_config/hssi/hssi_8x25.ofss n6001"

        for fseries-dk 8x25G configuration	- "gen_sim_files.sh --ofss $OFS_ROOTDIR/tools/ofss_config/fseries-dk.ofss fseries-dk"
	
        for iseries-dk 8x25G configuration	- "gen_sim_files.sh --ofss $OFS_ROOTDIR/tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_8x25_ftile.ofss iseries-dk"
    	for iseries-dk 200G congifuration	- "gen_sim_files.sh --ofss $OFS_ROOTDIR/tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_2x200_ftile.ofss iseries-dk"
	for iseries-dk 400G congifuration	- "gen_sim_files.sh --ofss $OFS_ROOTDIR/tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_1x400_ftile.ofss iseries-dk"
             
        for n6000 10G 8x10 configuration        - "gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_8x10.ofss n6000"
        for n6000 25G 16x25 configuration       - "gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_16x25.ofss n6000"
        for n6000 100G congifuration 		- "gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_4x100.ofss n6000"
 

6) **Running Test******
    Unit tests are placed under $OFS_ROOTDIR/sim/unit_test, for example $OFS_ROOTDIR/sim/unit_test/he_lb_test
    To run the simulation for each test: 
    Go to $OFS_ROOTDIR/ofs-common/scripts/common/sim, run the following command
	  VCS        : sh run_sim.sh TEST=<test_name>
	  VCSMX      : sh run_sim.sh TEST=<test_name> VCSMX=1
	  QuestaSim  : sh run_sim.sh TEST=<test_name> MSIM=1
    Please refer readme under respective testcase for more info.

*****How to Run Unit tests Regressions?******

** usage : python regress_run.py --help

 -l, --local Run regression locally, or run it on Farm. (Default:False)
 -n[N], --n_procs [N] Maximum number of processes/UVM tests to run in parallel when run locally. This has no effect on Farm run. (Default #CPUs-1: 11)
 -k, --pack [{'all','fme','he','hssi','list','mem','pmci'}] Test package to run during regression (Default: %(default)s)')
 -s [{vcs,msim,vcsmx}], --sim [{vcs,msim,vcsmx}] Simulator used for regression test. (Default: vcs)
 -g, --gen_sim_files, Generate IP simulation files. This should only be done once per repo update.  (Default: %(default)s)
 -e, --email_list Sends the regression results on email provided in list (Default : It will send it to regression Owner)
 -b, --board_name, optional [{n6001,fseries-dk}] (Default: n6001)
 -o, --ofss, optional

1)  cd $VERDIR/../sim/unit_test/scripts 

###run locally, with 8 processes, for adp platform, using test_pkg set of tests, using VCS with code coverage, to generate IP simulation files.  
python regress_run.py -l -n 8 -k all -s vcs -g

###Same as above, but run on Intel Farm (no --local):   
python regress_run.py --local --n_procs 8 --pack all --sim vcs -g

###Running script using defaults: run on Farm, adp platform, using test_pkg set of pmci tests, to generate IP simulation files using VCS with code coverage and sends result to owner 
python regress_run.py -g

2)  Results are created in individual testcase log dir


7)*******To exclude tests in the regression*********
  Go to $OFS_ROOTDIR/sim/unit_test/scripts, update skip_list.txt file with the tests need to be excluded as shown below
  for ftile,  FTILE:<test_name>
  for n6001,  n6001:<test_name>
