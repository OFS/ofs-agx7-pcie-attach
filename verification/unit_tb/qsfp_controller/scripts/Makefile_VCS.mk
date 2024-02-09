# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# Description:
#  	Makefile for VCS

ifdef CFG_RAND
  CFG_SW = +CONFIG_RAND=1
endif

ifndef WORKDIR
  WORKDIR := $(OFS_ROOTDIR)
endif

#ifndef UVM_HOME
#    $(error undefined UVM_HOME)
#endif 

#ifndef TESTNAME
#    $(error undefined TESTNAME)
#endif  

  
TEST_DIR :=  $(shell ./create_dir.pl $(VERDIR)/unit_tb/qsfp_controller/sim/$(TESTNAME) )

QSFP_SCRIPTS_DIR = $(VERDIR)/unit_tb/qsfp_controller/scripts

VCDFILE = $(QSFP_SCRIPTS_DIR)/vpd_dump.key

VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -l vlog.log -assert enable_diag -ignore unique_checks 
VLOG_OPT += -Mdir=./csrc +warn=noBCNACMBP -CFLAGS -notice -work work +incdir+./ 
VLOG_OPT += +define+SIM_MODE 
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SYNOPSYS_SV
VLOG_OPT += +incdir+$(WORKDIR)/src/includes

VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue +vcs+lic+wait -l vcs.log  

SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
#SIMV_OPT += +UVM_NO_RELNOTES
SIMV_OPT += -l runsim.log 
SIMV_OPT += +ntb_disable_cnst_null_object_warning=1 -assert nopostproc +vcs+lic+wait +vcs+initreg+0 
SIMV_OPT += +UVM_PHASE_TRACE
SIMV_OPT +=  +vcs+lic+wait 
VLOG_OPT += -debug_all 
VCS_OPT += -debug_all 

ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif

#Suppress unique/priority case/if warnings
ifdef NORT_WARN
    VCS_OPT += -ignore all
endif

ifndef MSG
    SIMV_OPT += +UVM_VERBOSITY=LOW
else
    SIMV_OPT += +UVM_VERBOSITY=$(MSG)
endif

ifdef DUMP
    SIMV_OPT += -ucli -i $(VCDFILE)
endif

ifdef GUI
    VCS_OPT += -debug_all +memcbk
    SIMV_OPT += -gui
endif
ifdef SIMV_PLUSARGS
SIMV_OPT += $(SIMV_PLUSARGS)
endif

ifdef QUIT
    SIMV_OPT_EXTRA = +UVM_MAX_QUIT_COUNT=1
else
   SIMV_OPT_EXTRA = ""
endif

ifdef COV
		
    ##VLOG_OPT += +define+ENABLE_COVERAGE -cm line+cond+fsm+tgl+branch -cm_dir simv.vdb
    VLOG_OPT += +define+ENABLE_COVERAGE 
    VCS_OPT += -cm line+cond+fsm+tgl+branch -cm_dir simv.vdb 
    #SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name $(TESTNAME) -cm_dir ../regression.vdb -cm_test qsfp
    #SIMV_OPT += +define+ENABLE_COVERAGE -cm line+cond+fsm+tgl+branch -cm_name $(TESTNAME) -cm_test qsfp 
    SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name $(TESTNAME) -cm_test qsfp -cm_dir ../regression.vdb 

endif


batch: vcs
	./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)

dump:
	make DUMP=1

clean:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml *.mif DVEfiles;
	@rm -rf $(VERDIR)/unit_tb/qsfp_controller/sim;
	@rm -rf $(VERDIR)/unit_tb/qsfp_controller/vip;
clean_dve:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml *.mif;
             
setup: clean_dve
	@echo WORK \> DEFAULT > synopsys_sim.setup
	@echo DEFAULT \: worklib >> synopsys_sim.setup              
	@mkdir worklib
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
	#test -s $(VERDIR)/sim || mkdir $(VERDIR)/sim
	#test -s $(VERDIR)/vip || mkdir $(VERDIR)/vip
	test -s $(VERDIR)/unit_tb/qsfp_controller/vip || mkdir $(VERDIR)/unit_tb/qsfp_controller/vip
	#test -s $(VERDIR)/vip/axi_vip || mkdir $(VERDIR)/vip/axi_vip
	test -s $(VERDIR)/unit_tb/qsfp_controller/vip/axi_vip || mkdir $(VERDIR)/unit_tb/qsfp_controller/vip/axi_vip
	test -s $(VERDIR)/unit_tb/qsfp_controller/sim || mkdir $(VERDIR)/unit_tb/qsfp_controller/sim
	@echo ''
	@echo VCS_HOME: $(VCS_HOME)
	#@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path $(VERDIR)/vip/axi_vip -add axi_system_env_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path $(VERDIR)/unit_tb/qsfp_controller/vip/axi_vip -add axi_system_env_svt -svlog
	# Generate On-the-fly IP Sim files for the target platform
ifeq ($(n6000_10G),1)
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files_top.sh n6000_10G 
else ifeq ($(n6000_25G),1)
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files_top.sh n6000_25G 
else ifeq ($(n6000_100G),1)
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss n6000
else
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh n6001 #Default
endif
	@echo ''  


#Added for QSFP env

 
qsfp_build_all: qsfp_vcs


qsfp_vcs: qsfp_vlog
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vcs $(VCS_OPT) qsfp_tb_top 

qsfp_vlog: setup 
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ns -l vlog_uvm.log
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlogan $(VLOG_OPT)  -f $(QSFP_SCRIPTS_DIR)/../qsfp_rtl.f  -f $(QSFP_SCRIPTS_DIR)/../qsfp_ver_list.f

qsfp_run:    
ifndef TEST_DIR
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && mkdir $(TEST_DIR) && cd $(TEST_DIR) &&  cp $(WORKDIR)/sim/scripts/qip_gen/ipss/qsfp/ip/qsfp_ctrl/sim/../../qsfp_ctrl_onchip_memory2_0/sim//../altera_avalon_onchip_memory2_1938/sim/*.hex . &&  ../simv $(CFG_SW) $(SIMV_OPT) $(SIMV_OPT_EXTRA) ; perl $(WORKDIR)/../env_not_shipped/tools/bin/postsim.pl

endif
#Added for QSFP env _end

view:
	dve -full64 -vpd inter.vpd&



