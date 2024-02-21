# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# Description:
#  	Makefile for VCS

ifndef OFS_ROOTDIR
    $(error undefined OFS_ROOTDIR)
endif
ifndef WORKDIR
    WORKDIR := $(OFS_ROOTDIR)
endif

export VERDIR = $(OFS_ROOTDIR)/verification/unit_tb/copy_engine
export VERDIR = $(OFS_ROOTDIR)/verification/unit_tb/copy_engine

#ifndef UVM_HOME
#    $(error undefined UVM_HOME)
#endif 

#ifndef TESTNAME
#    $(error undefined TESTNAME)
#endif    
TEST_DIR :=  $(shell ./create_dir.pl $(VERDIR)/sim/$(TESTNAME) )

SCRIPTS_DIR = $(VERDIR)/scripts

VCDFILE = $(SCRIPTS_DIR)/vpd_dump.key
FSDBFILE = $(SCRIPTS_DIR)/fsdb_dump.tcl


ADP_DIR = $(OFS_ROOTDIR)/sim/scripts

PLATFORM_DIR = $(AGILEX_DIR)

#VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -CFLAGS -debug_pp -l vlog.log -assert enable_diag -ignore unique_checks -debug_all
VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -l vlog.log -assert enable_diag -ignore unique_checks 
VLOG_OPT += -Mdir=./csrc +warn=noBCNACMBP -CFLAGS -y $(VERDIR)/vip/pcie_vip/src/verilog/vcs -y $(VERDIR)/vip/pcie_vip/src/sverilog/vcs -P $(VERDIR)/scripts/vip/pli.tab $(WORKDIR)/scripts/vip/msglog.o -notice -work work +incdir+./ 
VLOG_OPT += +define+INCLUDE_HSSI +define+INCLUDE_PCIE_SS
VLOG_OPT += +define+SIM_MODE +define+SIM_SERIAL +define+PU_MMIO #Enable PCIE Serial link up for p-tile and Power user MMIO for PO FIM
ifeq ($(n6000_100G),1)
VLOG_OPT += +define+n6000_100G #Includes CVL by passthrough logic
endif
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+SVT_PCIE_ENABLE_GEN3+GEN3
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SYNOPSYS_SV
VLOG_OPT += +define+ENABLE_AC_COVERAGE
VLOG_OPT += +define+ENABLE_COV_MSG
VLOG_OPT += +define+BASE_AFU=dummy_afu+
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/common/includes
VLOG_OPT += +incdir+$(WORKDIR)/src/includes
VLOG_OPT += +incdir+$(WORKDIR)/ipss/pcie/rtl
VLOG_OPT += +incdir+$(WORKDIR)/ipss/hssi/rtl/inc

VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue  +vcs+lic+wait -l vcs.log  
VLOG_OPT += -debug_access+f
VCS_OPT += -debug_access+f
SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
#SIMV_OPT += +UVM_NO_RELNOTES
SIMV_OPT += -l runsim.log 
SIMV_OPT += +ntb_disable_cnst_null_object_warning=1 -assert nopostproc +vcs+lic+wait +vcs+initreg+0 
SIMV_OPT += +UVM_PHASE_TRACE
SIMV_OPT +=  +vcs+lic+wait 
SIMV_OPT += +vcs+nospecify+notimingchecks +vip_verbosity=svt_pcie_pl:UVM_NONE,svt_pcie_dl:UVM_NONE,svt_pcie_tl:UVM_NONE  
#SIMV_OPT +=  +vcs+lic+wait -ucli -i $(VCDFILE)

ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif

ifndef MSG
    SIMV_OPT += +UVM_VERBOSITY=LOW
else
    SIMV_OPT += +UVM_VERBOSITY=$(MSG)
endif

ifdef DUMP
    #VLOG_OPT += -debug_all 
    #VCS_OPT += -debug_all 
    VLOG_OPT += -debug_access+f
    VCS_OPT += -debug_access+f
    SIMV_OPT += -ucli -i $(VCDFILE)
endif

ifdef DUMP_FSDB
    #VLOG_OPT += -debug_all 
    #VCS_OPT += -debug_all 
    VLOG_OPT += -debug_access+f
    VCS_OPT += -debug_access+f
    SIMV_OPT += -ucli -i $(FSDBFILE)
endif

#ifdef DEBUG
#SIMV_OPT += -l runsim.log 
#VLOG_OPT += +define+RUNSIM
#endif



ifdef GUI
    VCS_OPT += -debug_all +memcbk
    SIMV_OPT += -gui
endif

ifdef QUIT
    SIMV_OPT_EXTRA = +UVM_MAX_QUIT_COUNT=1
else
   SIMV_OPT_EXTRA = ""
endif

ifdef COV 
    VLOG_OPT += -debug_all 
    VCS_OPT += -debug_all 
    VLOG_OPT += +define+COV -debug_all -cm line+cond+fsm+tgl+branch -cm_dir simv.vdb
    VCS_OPT  += -debug_all -cm line+cond+fsm+tgl+branch  -cm_dir simv.vdb 
    SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name $(TESTNAME) -cm_dir ../regression.vdb
    #SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name seed.1 -cm_dir regression.vdb
endif

ifdef COV_FUNCTIONAL
		COV_TST := $(shell basename $(TEST_DIR))
    VLOG_OPT += +define+ENABLE_AC_COVERAGE+define+ENABLE_COV_MSG+define+COV_FUNCTIONAL -cm line+cond+fsm+tgl+branch -cm_dir simv.vdb
    VCS_OPT  += -cm line+cond+fsm+tgl+branch+assert  -cm_dir simv.vdb
    SIMV_OPT += -cm line+cond+fsm+tgl+branch+assert+group -cm_name $(COV_TST) -cm_dir ../regression.vdb
    #SIMV_OPT += -cm line+cond+fsm+tgl+branch -cm_name seed.1 -cm_dir regression.vdb
endif

batch: vcs
	./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)

dump:
	make DUMP=1

clean:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml DVEfiles;
	@rm -rf $(VERDIR)/sim $(VERDIR)/ip_libraries $(VERDIR)/vip $(VERDIR)/scripts/qip $(VERDIR)/scripts/ip_list.f $(VERDIR)/scripts/ip_flist.f;

clean_dve:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.ver *.hex *.xml;
             
setup: clean_dve
	@echo WORK \> DEFAULT > synopsys_sim.setup
	@echo DEFAULT \: worklib >> synopsys_sim.setup              
	@mkdir worklib
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
	test -s $(VERDIR)/sim || mkdir $(VERDIR)/sim
	test -s $(VERDIR)/vip || mkdir $(VERDIR)/vip
	test -s $(VERDIR)/vip/axi_vip || mkdir $(VERDIR)/vip/axi_vip
	test -s $(VERDIR)/vip/pcie_vip || mkdir $(VERDIR)/vip/pcie_vip
	rsync -avz --checksum --ignore-times ../ip_libraries/* $(VERDIR)/sim/
	@echo ''
	@echo VCS_HOME: $(VCS_HOME)
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/axi_vip -add axi_system_env_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/pcie_vip -add pcie_device_agent_svt -svlog
	@echo ''  

cmplib_adp:
	mkdir -p ../ip_libraries
	# Generate On-the-fly IP Sim files for the target platform
ifeq ($(n6000_10G),1)
	sh "$(OFS_ROOTDIR)"/sim/scripts/common/gen_sim_files_top.sh n6000_10G 
else ifeq ($(n6000_25G),1)
	sh "$(OFS_ROOTDIR)"/sim/scripts/common/gen_sim_files_top.sh n6000_25G 
else ifeq ($(n6000_100G),1)
	sh "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss n6000
	#sh $(OFS_ROOTDIR)/ofs-common/scripts/common/sim/gen_sim_files.sh n6000 
else
	sh "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh n6001 #Default
endif
	# Generate On-the-fly IP Sim files for the target platform
	rm -rf  $(SCRIPTS_DIR)/qip
	test -s $(SCRIPTS_DIR)/qip || ln -sf $(ADP_DIR)/qip_sim_script qip
	cp -f qip/synopsys/vcsmx/synopsys_sim.setup ../ip_libraries/
	cd ../ip_libraries && ../scripts/qip/synopsys/vcsmx/vcsmx_setup.sh SKIP_SIM=1 USER_DEFINED_COMPILE_OPTIONS=-v2005 QSYS_SIMDIR=../scripts/qip QUARTUS_INSTALL_DIR=$(QUARTUS_HOME)
	cd ../ip_libraries/&& sh "$(OFS_ROOTDIR)"/sim/scripts/ip_flist.sh

vlog_adp: setup 
	cd $(VERDIR)/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(VERDIR)/sim && vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ns -l vlog_uvm.log
	rm -rf  $(SCRIPTS_DIR)/ip_flist.f
	test -s $(SCRIPTS_DIR)/ip_flist.f  || ln -sf $(ADP_DIR)/ip_flist.f ip_flist.f
	cd $(VERDIR)/sim && vlogan $(VLOG_OPT) +define+SIM_VIP -f $(SCRIPTS_DIR)/ip_flist.f -F $(ADP_DIR)/generated_rtl_flist.f -f $(SCRIPTS_DIR)/ver_list.f -f $(SCRIPTS_DIR)/rtl_pcie.f 


build_adp: vlog_adp
	cd $(VERDIR)/sim && vcs $(VCS_OPT) tb_top 
ifdef DUMP_FSDB
	 @arc shell synopsys_verdi/R-2020.12-SP2 synopsys_verdi-lic/config
endif

build_gka:cmplib_adp vlog_adp
	cd $(VERDIR)/sim && vcs $(VCS_OPT) tb_top

view:
	dve -full64 -vpd inter.vpd&
urg:
	urg -dir simv.vdb -dir regression.vdb -report regression.urgReport -grade index
run:    
ifndef TEST_DIR
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/sim && mkdir $(TEST_DIR) && cd $(TEST_DIR) && cp -f ../*.hex . && ../simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)
endif
rundb:    
ifndef TESTNAME
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/sim && ./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)
endif

build_run: vcs run
build_all: cmplib vcs
do_it_all: cmplib vcs run


