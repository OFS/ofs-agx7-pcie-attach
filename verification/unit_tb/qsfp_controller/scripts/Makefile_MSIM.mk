# Copyright (C) 2021 Intel Corporation
# SPDX-License-Identifier: MIT

# Description:
#  Makefile for MSIM

ifdef CFG_RAND
  CFG_SW = +CONFIG_RAND=1
endif

ifndef WORKDIR
  WORKDIR := $(OFS_ROOTDIR)
endif
  
TEST_DIR :=  $(shell ./create_dir.pl $(VERDIR)/unit_tb/qsfp_controller/sim/$(TESTNAME) )

QSFP_SCRIPTS_DIR = $(VERDIR)/unit_tb/qsfp_controller/scripts

VCDFILE = $(QSFP_SCRIPTS_DIR)/vpd_dump.key

ADP_DIR = $(OFS_ROOTDIR)/sim/scripts

export VIPDIR = $(VERDIR)
export QLIB_DIR = $(QSFP_SCRIPTS_DIR)/qip/mentor/libraries

ifeq ($(MSIM),1)
# initialize variables
QUARTUS_INSTALL_DIR=$(QUARTUS_HOME)
QSYS_SIMDIR=$(QSFP_SCRIPTS_DIR)/qip
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="-finish exit"
TOP_LEVEL_NAME="qsfp_tb_top"
endif

VLOG_OPT = +define+QUESTA
VLOG_OPT = +define+MODEL_TECH
VLOG_OPT = +define+MODELTECH
VLOG_OPT += +incdir+$(QUESTA_HOME)/verilog_src/uvm-1.2/src
VLOG_OPT += +incdir+$(VERDIR)/vip/axi_vip/include/verilog
VLOG_OPT += +incdir+$(VERDIR)/vip/axi_vip/include/sverilog
VLOG_OPT += +incdir+$(VERDIR)/vip/axi_vip/src/verilog/mti
VLOG_OPT += +incdir+$(VERDIR)/vip/axi_vip/src/sverilog/mti
VLOG_OPT += +incdir+$(VERDIR)/unit_tb/qsfp_controller/tests/sequences
VLOG_OPT += +incdir+$(VERDIR)/unit_tb/qsfp_controller/tests
VLOG_OPT += +incdir+$(VERDIR)/unit_tb/qsfp_controller/testbench
VLOG_OPT += +incdir+$(VERDIR)/unit_tb/qsfp_controller/testbench/ral
VLOG_OPT += +incdir+$(VERDIR)/unit_tb/qsfp_controller/testbench/tb_pcie
VLOG_OPT += +incdir+$(QSFP_SCRIPTS_DIR)/vip/ethernet_vip/lib/linux64
VLOG_OPT += +incdir+$(QSFP_SCRIPTS_DIR)/vip/axi_vip/lib/linux64
VLOG_OPT += +define+IGNORE_DF_SIM_EXIT
VLOG_OPT += +define+INCLUDE_MEM_TG +define+INCLUDE_HSSI +define+INCLUDE_PCIE_SS +define+PCIE_GEN4X16 +define+INCLUDE_PR #Enable PCIE SS for Gen4x16 configuration
VLOG_OPT += +define+SIM_MODE +define+PU_MMIO #Enable PCIE Serial link up for p-tile and Power user MMIO for PO FIM
VLOG_OPT += +define+SIMULATION_MODE
VLOG_OPT += +define+UVM_DISABLE_AUTO_ITEM_RECORDING
VLOG_OPT += +define+UVM_PACKER_MAX_BYTES=1500000
VLOG_OPT += +define+SVT_UVM_TECHNOLOGY
VLOG_OPT += +define+SYNOPSYS_SV
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/common/includes
VLOG_OPT += +incdir+$(WORKDIR)/src/includes
VLOG_OPT += +incdir+$(WORKDIR)/ofs-common/src/fpga_family/agilex/remote_stp/ip/remote_debug_jtag_only/st_dbg_if/intel_st_dbg_if_10/sim

#VLOG_OPT += -debug_all 
VCS_OPT = -full64 -ntb_opts uvm-1.2 -licqueue  +vcs+lic+wait -l vcs.log 
VCS_OPT += -debug_access+f
#VCS_OPT += -debug_all 
SIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)
#SIMV_OPT += +UVM_NO_RELNOTES
#SIMV_OPT += -l runsim.log 
SIMV_OPT += +ntb_disable_cnst_null_object_warning=1 -assert nopostproc +vcs+lic+wait +initreg+0  
#SIMV_OPT += +UVM_PHASE_TRACE
SIMV_OPT +=  +vcs+lic+wait 
SIMV_OPT += +vcs+nospecify+notimingchecks +vip_verbosity=svt_pcie_pl:UVM_NONE,svt_pcie_dl:UVM_NONE,svt_pcie_tl:UVM_NONE  

MSIMV_OPT = +UVM_TESTNAME=$(TESTNAME) +TIMEOUT=$(TIMEOUT)

#SIMV_OPT +=  +vcs+lic+wait -ucli -i $(VCDFILE)


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
    #VLOG_OPT += -debug_all 
    #VCS_OPT  += -debug_all 
ifneq ($(MSIM),1)
    VLOG_OPT += -debug_access+f
    VCS_OPT  += -debug_access+f
    SIMV_OPT += -ucli -i $(VCDFILE)
endif
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
	@echo VIPDIR  $(VIPDIR)              
	@echo \`include \"$(TESTNAME).svh\" > test_lib.svh                
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
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_8x10.ofss n6000 
else ifeq ($(n6000_25G),1)
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_8x10.ofss n6000 
else ifeq ($(n6000_100G),1)
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh --ofss $(OFS_ROOTDIR)/tools/ofss_config/n6000.ofss,"$(OFS_ROOTDIR)"/tools/ofss_config/hssi/hssi_4x100.ofss n6000
else
	cd $(OFS_ROOTDIR)/ofs-common/scripts/common && "$(OFS_ROOTDIR)"/ofs-common/scripts/common/sim/gen_sim_files.sh n6001 #Default
endif
	@echo ''  


#Added for QSFP env

 
qsfp_build_all: qsfp_vcs

qsfp_vcs: qsfp_vlog vopt_adp

qsfp_vlog: setup 
	QSYS_SIMDIR=$(QSFP_SCRIPTS_DIR)/qip
	QUARTUS_INSTALL_DIR=$(QUARTUS_HOME)
	# Generate On-the-fly IP Sim files for the target platform
	@echo "Starting  Quartus  library Compile with Questa "              
	test -s $(QSFP_SCRIPTS_DIR)/qip || ln -s $(ADP_DIR)/qip_sim_script qip
	cd $(QSFP_SCRIPTS_DIR)/qip/mentor 
	@echo "Starting  Quartus  library Compile with Questa ..... "              
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlogan -ntb_opts uvm-1.2 -sverilog
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlogan -full64 -ntb_opts uvm-1.2 -sverilog -timescale=1ns/1ns -l vlog_uvm.log
	cd $(VERDIR)/unit_tb/qsfp_controller/sim && vlog  $(VLOG_OPT) -suppress 13364,2388,13311,8364,,8386,7061,7033,1902,8303,2997,1321 -mfcu  -timescale=1ns/1ns -l adp_vlog.log +libext+.v+.sv   -lint -sv +define+QUESTA +define+FIM_C -f $(QSFP_SCRIPTS_DIR)/../qsfp_rtl.f -f $(QSFP_SCRIPTS_DIR)/../qsfp_msim_list.f -f $(QSFP_SCRIPTS_DIR)/questa_list.f

vopt_adp:
	vopt $(TOP_LEVEL_NAME) -o des -designfile design_2.bin -debug $(VLOG_OPT) -suppress 2732,12003,7033,3837,8386,13364,2388,13311,8364,7061,7033,7077 +initwire+0 -L $(QUESTA_HOME)/uvm-1.2 -work $(QSFP_SCRIPTS_DIR)/../sim/work -l msim_vopt.log 


ifndef TEST_DIR
$(error undefined TESTNAME)
else
ifeq ($(DUMP),1)
qsfp_run:
	gcc -m64 -fPIC -DQUESTA -g -W -shared -x c -I $(QUESTA_HOME)/include -I $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi  $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi/uvm_dpi.cc -o $(QSFP_SCRIPTS_DIR)/../sim/uvm_dpi.so	
	cd $(QSFP_SCRIPTS_DIR)/../sim && mkdir $(TEST_DIR)  &&  cd $(TEST_DIR)  && cp $(WORKDIR)/sim/scripts/qip_gen/ipss/qsfp/ip/qsfp_ctrl/sim/../../qsfp_ctrl_onchip_memory2_0/sim//../altera_avalon_onchip_memory2_1938/sim/*.hex . && vsim -64 -qwavedb=+signal -nosva des -lib $(QSFP_SCRIPTS_DIR)/../sim/work -permit_unmatched_virtual_intf    -dpicpppath /p/psg/ctools/gcc/7.2.0/1/linux64/bin/gcc +UVM_TESTNAME=$(TESTNAME) $(CFG_SW) -sv_lib $(QSFP_SCRIPTS_DIR)/../sim/uvm_dpi -sv_lib $(QSFP_SCRIPTS_DIR)/../vip/axi_vip/lib/linux64/libvcap -c -suppress 2732,3053,12003,7033,3837,8386,13364,2388,13311,8364,7061,7033,7077,8303,16132 -L $(QUESTA_HOME)/uvm-1.2 -do "add log -r /* ; run -all; quit -f"

else
qsfp_run:
	gcc -m64 -fPIC -DQUESTA -g -W -shared -x c -I $(QUESTA_HOME)/include -I $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi  $(QUESTA_HOME)/verilog_src/uvm-1.2/src/dpi/uvm_dpi.cc -o $(QSFP_SCRIPTS_DIR)/../sim/uvm_dpi.so	
	cd $(QSFP_SCRIPTS_DIR)/../sim && mkdir $(TEST_DIR)  &&  cd $(TEST_DIR) && cp $(WORKDIR)/sim/scripts/qip_gen/ipss/qsfp/ip/qsfp_ctrl/sim/../../qsfp_ctrl_onchip_memory2_0/sim//../altera_avalon_onchip_memory2_1938/sim/*.hex . && vsim -64 -nosva des -lib $(QSFP_SCRIPTS_DIR)/../sim/work -permit_unmatched_virtual_intf  -dpicpppath /p/psg/ctools/gcc/7.2.0/1/linux64/bin/gcc +UVM_TESTNAME=$(TESTNAME) $(CFG_SW) -sv_lib $(QSFP_SCRIPTS_DIR)/../sim/uvm_dpi -sv_lib $(QSFP_SCRIPTS_DIR)/../vip/axi_vip/lib/linux64/libvcap -c -suppress 2732,3053,12003,7033,3837,8386,13364,2388,13311,8364,7061,7033,7077,8303,16132 -L $(QUESTA_HOME)/uvm-1.2  -do " run -all; quit -f" 
endif
endif

#Added for QSFP env _end

