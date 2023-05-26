# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

#// Description:
#//  	Makefile for VCS
#// 
#// Author:  Krupa Shah
#//
#// $Id: Makefile_VCS.mk $
#////////////////////////////////////////////////////////////////////////////////////////////////

ifndef OFS_ROOTDIR
    $(error undefined OFS_ROOTDIR)
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

SCRIPTS_DIR = $(OFS_ROOTDIR)/sim/scripts
VERIF_SCRIPTS_DIR = $(VERDIR)/scripts

TEST_DIR :=  $(shell $(VERIF_SCRIPTS_DIR)/create_dir.pl $(VERDIR)/sim/$(TESTNAME) )

VCDFILE = $(VERIF_SCRIPTS_DIR)/vpd_dump.key
FSDBFILE = $(VERIF_SCRIPTS_DIR)/fsdb_dump.tcl

ADP_DIR = $(OFS_ROOTDIR)/sim/scripts/
QIP_DIR = $(ADP_DIR)/qip_sim_script

export VIPDIR = $(VERDIR)
export RALDIR = $(VERDIR)/testbench/ral

#VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -CFLAGS -debug_pp -l vlog.log -assert enable_diag -ignore unique_checks -debug_all
VLOG_OPT = -kdb -full64 -error=noMPD -ntb_opts uvm-1.2 +vcs+initreg+random +vcs+lic+wait -ntb_opts dtm -sverilog -timescale=1ns/1fs +libext+.v+.sv -l vlog.log -assert enable_diag -ignore unique_checks 
VLOG_OPT += -Mdir=./csrc +warn=noBCNACMBP -CFLAGS -y $(VERDIR)/vip/pcie_vip/src/verilog/vcs -y $(VERDIR)/vip/pcie_vip/src/sverilog/vcs -P $(VERIF_SCRIPTS_DIR)/vip/pli.tab $(WORKDIR)/scripts/vip/msglog.o -notice -work work +incdir+./
#VLOG_OPT += +define+DISABLE_AFU_MAIN #Remove afu_main() ref from UVM TB for PIM AFU testing
VLOG_OPT += +define+IGNORE_DF_SIM_EXIT
VLOG_OPT += +define+INCLUDE_MEM_TG +define+INCLUDE_HSSI +define+INCLUDE_PCIE_SS +define+PCIE_GEN4X16 +define+INCLUDE_PR #Enable PCIE SS for Gen4x16 configuration
VLOG_OPT += +define+SIM_MODE +define+PU_MMIO #Enable PCIE Serial link up for p-tile and Power user MMIO for PO FIM
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+bypass_address    #bypass UNIMPLEMENTED_ADDRESS
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_NO_DEPRECATED
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+MMIO_TIMEOUT_IN_CYCLES=1024
VLOG_OPT += +define+SVT_PCIE_ENABLE_GEN3+GEN3+SVT_PCIE_ENABLE_10_BIT_TAGS
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SVT_ETHERNET +define+VIP_ETHERNET_40G100G_OPT_SVT
VLOG_OPT += +define+ETH_CAUI_25G_INTERFACE_WIDTH=8 +define+SVT_ETHERNET_CLKGEN
VLOG_OPT += +define+VIP_ETHERNET_100G_SVT +define+SVT_ETHERNET_DEBUG_BUS_ENABLE
VLOG_OPT += +define+SYNOPSYS_SV
VLOG_OPT += +define+ETH_FORCE_FS_TIME_PRECISION
VLOG_OPT += +define+BASE_AFU=dummy_afu+
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/common/includes
VLOG_OPT += +incdir+$(WORKDIR)/src/includes
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/fpga_family/agilex/remote_stp/ip/remote_debug_jtag_only/st_dbg_if/intel_st_dbg_if_10/sim
VLOG_OPT += +incdir+$(WORKDIR)/ipss/pcie/rtl
VLOG_OPT += +incdir+$(WORKDIR)/ipss/hssi/rtl/inc
VLOG_OPT += +incdir+$(RALDIR)
#VLOG_OPT += -debug_all 
VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue  +vcs+lic+wait -l vcs.log 
VLOG_OPT += -debug_access+f
VCS_OPT += -debug_access+f
#VCS_OPT += -debug_all 
SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
#SIMV_OPT += +UVM_NO_RELNOTES
#SIMV_OPT += -l runsim.log 
SIMV_OPT += +ntb_disable_cnst_null_object_warning=1 -assert nopostproc +vcs+lic+wait +vcs+initreg+0 
#SIMV_OPT += +UVM_PHASE_TRACE
SIMV_OPT +=  +vcs+lic+wait 
SIMV_OPT += +vcs+nospecify+notimingchecks +vip_verbosity=svt_pcie_pl:UVM_NONE,svt_pcie_dl:UVM_NONE,svt_pcie_tl:UVM_NONE  
#SIMV_OPT +=  +vcs+lic+wait -ucli -i $(VCDFILE)

ifndef SEED
    SIMV_OPT += +ntb_random_seed_automatic
else
    SIMV_OPT += +ntb_random_seed=$(SEED)
endif
ifdef TEST_LPBK
    VLOG_OPT += +define+TEST_LPBK 
endif

ifdef LPBK_WITHOUT_HSSI
    VLOG_OPT += +define+LPBK_WITHOUT_HSSI 
endif

ifndef MSG
    SIMV_OPT += +UVM_VERBOSITY=LOW
else
    SIMV_OPT += +UVM_VERBOSITY=$(MSG)
endif

ifdef NO_MSIX
    VLOG_OPT += +define+NO_MSIX 
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

ifdef DEBUG
SIMV_OPT += -l runsim.log 
VLOG_OPT += +define+RUNSIM
endif



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

ifndef DISABLE_EMIF
  VLOG_OPT += +define+INCLUDE_DDR4
  VLOG_OPT += +define+SIM_MODE_NO_MSS_RST
endif

## The Platform Interface Manager is always available for use by AFUs,
## whether or not a specific AFU requires it. These parameters define
## the platform-dependent PIM instance that will be created below
## during cmplib.
PIM_TEMPLATE_DIR=$(VERDIR)/ip_libraries/pim_template

ifndef AFU_WITH_PIM
    # No PIM. Use the default exerciser AFU.
    AFU_FLIST_IMPORT=-F $(OFS_ROOTDIR)/sim/scripts/rtl_afu_default.f
else
    # Simulating an AFU wrapped by the PIM's ofs_plat_afu() top-level
    # module wrapper.
    AFU_WITH_PIM_DIR=$(VERDIR)/sim/afu_with_pim
    AFU_FLIST_IMPORT=-F $(PIM_TEMPLATE_DIR)/pim_source_files.list -F $(AFU_WITH_PIM_DIR)/afu_sim_files.list
endif

batch: vcs
	./simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)

dump:
	make DUMP=1

clean:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.hex *.xml DVEfiles;
	@rm -rf $(VERDIR)/sim $(VERDIR)/ip_libraries $(VERDIR)/vip;

clean_dve:
	@if [ -d worklib ]; then rm -rf worklib; fi;
	@if [ -d libs ]; then rm -rf libs; fi;
	@rm -rf simv* csrc *.out* *.OUT *.log *.txt *.h *.setup *.vpd test_lib.svh .vlogansetup.* *.tr *.hex *.xml;

setup: clean_dve
	@echo WORK \> DEFAULT > synopsys_sim.setup
	@echo DEFAULT \: worklib >> synopsys_sim.setup              
	@mkdir worklib
	@echo VIPDIR  $(VIPDIR)              
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
	test -s $(VERDIR)/sim || mkdir $(VERDIR)/sim
	test -s $(VERDIR)/vip || mkdir $(VERDIR)/vip
	test -s $(VERDIR)/vip/axi_vip || mkdir $(VERDIR)/vip/axi_vip
	test -s $(VERDIR)/vip/pcie_vip || mkdir $(VERDIR)/vip/pcie_vip
	rsync -avz --checksum --ignore-times --exclude pim_template ../ip_libraries/* $(VERDIR)/sim/
	@echo ''
	@echo VCS_HOME: $(VCS_HOME)
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/axi_vip -add axi_system_env_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/pcie_vip -add pcie_device_agent_svt -svlog
	@$(DESIGNWARE_HOME)/bin/dw_vip_setup -path ../vip/ethernet_vip -add ethernet_agent_svt -svlog
	@echo ''  

cmplib_adp:
	mkdir -p ../ip_libraries
	# Generate On-the-fly IP Sim files for the target platform
	sh "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh n6001 #Default
	cp -f "$(QIP_DIR)"/synopsys/vcsmx/synopsys_sim.setup ../ip_libraries/
	cd ../ip_libraries && "$(QIP_DIR)"/synopsys/vcsmx/vcsmx_setup.sh SKIP_SIM=1 USER_DEFINED_COMPILE_OPTIONS=-v2005 QSYS_SIMDIR="$(QIP_DIR)" QUARTUS_INSTALL_DIR=$(QUARTUS_HOME)

vlog_adp: setup 
ifdef AFU_WITH_PIM
	# Construct the simulation build environment for the target AFU
	"$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/ofs_pim_sim_setup.sh -t "$(AFU_WITH_PIM_DIR)" -r "$(PIM_TEMPLATE_DIR)" -b adp -f base_x16 "$(AFU_WITH_PIM)"
endif
	cd $(VERDIR)/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(VERDIR)/sim && vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ns -l vlog_uvm.log
	cd $(VERDIR)/sim && vlogan $(VLOG_OPT) +define+FIM_C +define+INCLUDE_PMCI +define+INCLUDE_UART +define+SIM_VIP -F $(SCRIPTS_DIR)/ip_flist.f -F $(SCRIPTS_DIR)/generated_rtl_flist.f -F $(VERIF_SCRIPTS_DIR)/svt_list.f -F $(VERIF_SCRIPTS_DIR)/ver_list.f $(AFU_FLIST_IMPORT)

build_adp: vlog_adp
	cd $(VERDIR)/sim && vcs $(VCS_OPT) tb_top
#ifdef DUMP_FSDB
#	 @arc shell synopsys_verdi/R-2020.12-SP2 synopsys_verdi-lic/config
#endif


build_gka:cmplib_adp vlog_adp
	cd $(VERDIR)/sim && vcs $(VCS_OPT) tb_top

view:
	dve -full64 -vpd inter.vpd&
run:    
ifndef TEST_DIR
	$(error undefined TESTNAME)
else
	cd $(VERDIR)/sim && mkdir $(TEST_DIR) && cd $(TEST_DIR) && cp -f ../*.hex . && cp -f $(OFS_ROOTDIR)/ofs-common/src/common/fme_id_rom/fme_id.mif . && cp -f $(VERIF_SCRIPTS_DIR)/fme_id.ver . && cp -f $(VERIF_SCRIPTS_DIR)/recalibration.ver . && cp -f $(VERDIR)/sim/serdes.firmware.rom . && ../simv $(SIMV_OPT) $(SIMV_OPT_EXTRA)
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


