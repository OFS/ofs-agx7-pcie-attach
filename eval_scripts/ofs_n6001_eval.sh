#!/bin/bash
# Copyright 2022-2023 Intel Corporation
# SPDX-License-Identifier: MIT

# This script relies on the following set of software tools, (intelFPGA_pro, Synopsys, Questasim and Intel OFS) which should be installed using the directory structure below. Tool versions can vary.

##├── intelFPGA_pro
##│   └── 23.1
##│       ├── devdata
##│       ├── gcc
##│       ├── hld
##│       ├── hls
##│       ├── ip
##│       ├── licenses
##│       ├── logs
##│       ├── nios2eds
##│       ├── niosv
##│       ├── qsys
##│       ├── quartus
##│       ├── questa_fe
##│       ├── questa_fse
##│       ├── syscon
##│       └── uninstall
##├── mentor
##│   ├── questasim
##│   │   └── 2021.4
##├── synopsys
##│   ├── vcsmx
##│   │   └── S-2021.09-SP1
##│   └── vip_common
##│       └── vip_Q-2020.03A
##├── user_area
##│   └── ofs-X.X.X

## ofs-X.X.X is a directory the user creates based on version they want to test e.g ofs-2.3.1 

## The Intel OFS repos are then cloned beneath ofs-X.X.X and is assigned to the $IOFS_BUILD_ROOT environment variable. This script is then copied to the same directory location, see example below

##├── ofs-2.3.1
##│   ├── examples-afu
##│   ├── linux-dfl
##│   ├── ofs-n6001
##│   ├── oneapi-asp
##│   ├── oneAPI-samples
##│   ├── opae-sdk
##│   ├── opae-sim
##│   ├── ofs_n6001_eval.sh

# Repository Contents
## examples-afu	          (Basic Building Blocks (BBB) for Intel FPGAs is a suite of application building blocks and shims for transforming the CCI-P interface)
## linux-dfl	            (Contains mirror of linux-dfl and specific Intel OFS drivers that are being upstreamed to the Linux kernel)
## fim-n6001	            (Contains FIM or shell RTL, automated compilation scripts, unit tests and UVM test framework)
## oneapi-asp	            (Contains the hardware and software components you need to develop your own oneAPI or OpenCL board support package for the Intel® Stratix 10® and Intel® Agilex® FPGAs)
## oneAPI-samples         (Samples for Intel® oneAPI Toolkits)
## opae-sdk	              (Contains the files for building and installing Open Programmable Acceleration Engine Software Development Kit from source)
## opae-sim	              (Contains the files for an AFU developer to build the Accelerator Funcitonal Unit Simulation Environment (ASE) for workload development)

# Generate Log file
TIMESTAMP=`date "+%Y_%m_%d-%H%M%S"`
mkdir -p log_files/n6001_log_$TIMESTAMP
LOG_FILE=$PWD/log_files/n6001_log_$TIMESTAMP/ofs_n6001_eval.log
exec > >(tee ${LOG_FILE}) 2>&1

unset SCRIPT_DIR

# Set-Up Proxy Server
export http_proxy=
export https_proxy=
export no_proxy=

# License Files
export LM_LICENSE_FILE=
export DW_LICENSE_FILE=
export SNPSLMD_LICENSE_FILE=

# General Environment Variables
export IOFS_BUILD_ROOT=$PWD

export OFS_ROOTDIR=$IOFS_BUILD_ROOT/ofs-n6001
export WORKDIR=$OFS_ROOTDIR

#################################################################################
#################### Set Tools Location  ########################################
#################################################################################

# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #
export QUARTUS_TOOLS_LOCATION=/home
export SYNOPSYS_TOOLS_LOCATION=/home
export QUESTASIM_TOOLS_LOCATION=/home
export ONEAPI_TOOLS_LOCATION=/opt
# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #

# Quartus Tools
# ************** Set version of Quartus ***************** #
export QUARTUS_VERSION=23.1
# ************** Set version of Quartus ***************** #

export QUARTUS_HOME=$QUARTUS_TOOLS_LOCATION/intelFPGA_pro/$QUARTUS_VERSION/quartus
export QUARTUS_ROOTDIR=$QUARTUS_HOME
export QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
export IMPORT_IP_ROOTDIR=$QUARTUS_ROOTDIR/../ip
export QSYS_ROOTDIR=$QUARTUS_ROOTDIR/../qsys/bin
export PATH=$QUARTUS_HOME/bin:$QUARTUS_HOME/qsys/bin:$QUARTUS_HOME/sopc_builder/bin/:$PATH

# OPAE Tools
# ************** Change OPAE SDK VERSION ***************** #
export OPAE_SDK_VERSION=2.5.0-1
# ************** Change OPAE SDK VERSION ***************** #

export OPAE_SDK_REPO_BRANCH=release/$OPAE_SDK_VERSION
export OPAE_SDK_ROOT=$OFS_ROOTDIR/../opae-sdk
export PATH=$PATH:$OPAE_SDK_ROOT/bin
export LD_LIBRARY_PATH=$OPAE_SDK_ROOT/lib64:$LD_LIBRARY_PATH

# OFS Platform Tools
export OFS_PLATFORM_AFU_BBB_EXTERNAL=$OFS_ROOTDIR/external/ofs-platform-afu-bbb

# OFS Platform BBB Tools
# Set the FPGA_BBB_CCI_SRC variable to the full path of the examples-afu directory
export FPGA_BBB_CCI_SRC=$IOFS_BUILD_ROOT/examples-afu

# Synopsys Verification Tools
export DESIGNWARE_HOME=$SYNOPSYS_TOOLS_LOCATION/synopsys/vip_common/vip_Q-2020.03A
export PATH=$DESIGNWARE_HOME/bin:$PATH
export UVM_HOME=$SYNOPSYS_TOOLS_LOCATION/synopsys/vcsmx/S-2021.09-SP1/linux64/rhel/etc/uvm
export VCS_HOME=$SYNOPSYS_TOOLS_LOCATION/synopsys/vcsmx/S-2021.09-SP1/linux64/rhel
export PATH=$VCS_HOME/bin:$PATH
export VERDIR=$OFS_ROOTDIR/verification
export VIPDIR=$VERDIR

## QuestaSIM Verification Tools
export MTI_HOME=$QUESTASIM_TOOLS_LOCATION/mentor/questasim/2021.4/linux64
export PATH=$MTI_HOME/linux_x86_64/:$MTI_HOME/bin/:$PATH
export QUESTA_HOME=$MTI_HOME

#################################################################################
#################### Set ADP Platform  ##########################################
#################################################################################

# Definition of n6001 Board
#* PCIe Gen4x16, 400 MHz
#* 2x4x25GbE
#* One memory channel supporting x40 (x32 Data + x8ECC), 1200 MHz (2400) 1G (for HPS)
#* Four memory channels: x32 (x32 Data no ECC), 1200 MHz (2400), 4 GB
#* Partial Reconfiguration support
#* oneAPI Support

# ADP Platform (Example:= n6001)
export ADP_PLATFORM=n6001

# Multi Card (Example:= SINGLE or MULTI)
export ADP_CARD_CONFIG=SINGLE

# (Device ID) (Example:= bcce(n6001))

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    
  
        echo ""
        export ADP_CARD1_DEVICE_ID=bcce
        echo ""
  
    else 

        echo "None of the conditions met"

    fi  
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_DEVICE_ID=bcce
        echo ""    
  
        echo ""
        export ADP_CARD1_DEVICE_ID=bcce
        echo ""
  
    else 

        echo "None of the conditions met"

    fi  
  
else
 
  echo "None of the conditions met"

fi

#################################################################################
#################### Identify ADP Platform  #####################################
#################################################################################

# PCIe (Socket Number)
export ADP_CARD0_SOCKET_NUMBER=0000
export ADP_CARD1_SOCKET_NUMBER=0000

# PCIe (Bus Number)
# The Bus number must be entered by the user after installing the hardware in the chosen server, in the example below "b1" is the Bus Number for a single card
if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then     
        echo ""
        export ADP_CARD0_BUS_NUMBER=98
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_BUS_NUMBER=b1
        echo ""    
  
        echo ""
        export ADP_CARD1_BUS_NUMBER=XX
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_BUS_NUMBER=b1
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_BUS_NUMBER=b1
        echo ""    
  
        echo ""
        export ADP_CARD1_BUS_NUMBER=XX
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

# PCIe (Device Number)
export ADP_CARD0_DEVICE_NUMBER=00
export ADP_CARD1_DEVICE_NUMBER=00

# PCIe (Function Number)
export ADP_CARD0_FUNCTION_NUMBER=0
export ADP_CARD1_FUNCTION_NUMBER=0

# PCIe ((Full Identification-Socket:Bus:Device:Function(S:B:D:F))
export ADP_CARD0_ID=$ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER
export ADP_CARD1_ID=$ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.$ADP_CARD1_FUNCTION_NUMBER

# oneAPI Slot Identification
if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    
  
        echo ""
        export ADP_CARD1_ACL1=acl1
        echo ""
  
    else 

        echo "None of the conditions met"

    fi

elif [ $ADP_PLATFORM == "nXXXX" ]

then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        export ADP_CARD0_ACL0=acl0
        echo ""    
  
        echo ""
        export ADP_CARD1_ACL1=acl1
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
else 

  echo "None of the conditions met"

fi

#################################################################################
#################### FIM and PR/AFU Set-up  #####################################
#################################################################################

# FIM Options (base_x16, base_x16:no_hssi, base_x16:null_he)
export FIM_SHELL=base_x16

# SHELL FIM Null Options (for base_x16 leave blank, no_hssi, (null_he,null_he_hssi,null_he_mem,null_he_mem_tg))
export FIM_SHELL_NULL=

# FIM working directories
if [ $ADP_PLATFORM == "n6001" ]

  then

      export FIM_WORKDIR=work_adp_${FIM_SHELL}
      export FIM_WORKDIR_PR=work_adp_${FIM_SHELL}_pr
      export FIM_WORKDIR_PR_STP=work_adp_${FIM_SHELL}_pr_stp
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

      export FIM_WORKDIR=work_adp_${FIM_SHELL}
      export FIM_WORKDIR_PR=work_adp_${FIM_SHELL}_pr
      export FIM_WORKDIR_PR_STP=work_adp_${FIM_SHELL}_pr_stp
      
else
 
  echo "None of the conditions met"

fi

#################################################################################
#################### FLASH Set-up  ##############################################
#################################################################################

# BMC FLASH Image (RTL and FW)
export BMC_RTL_FW_FLASH=AC_BMC_RSU_user_retail_3.2.0_unsigned.rsu

# FPGA STATIC REGION USER FLASH Image (user1, user2)
export FPGA_SR_USER_FLASH=user1

# FPGA STATIC REGION PAGE FLASH Image (page1, page2)
export FPGA_SR_PAGE_FLASH=page1

#################################################################################
#################### AFU Set-up  ################################################
#################################################################################

# OFS AFU Examples (host_chan_intr, host_chan_mmio, host_chan_params, local_mem_params)
export AFU_TEST_NAME=host_chan_mmio

#################################################################################
#################### AFU BBB Set-up  ############################################
#################################################################################

# OFS AFU BBB Examples (clocks, copy_engine, hello_world, local_memory, PIM_advanced)
export AFU_BBB_TEST_NAME=hello_world

# OFS AFU BBB Interface Types (avalon, axi, ccip)
export AFU_BBB_INTERFACE_NAME=axi

#################################################################################
#################### ONEAPI Set-up  #############################################
#################################################################################

# oneAPI BSP's (ofs_n6001, ofs_n6001_usm)
export ONEAPI_BOARD_NAME=ofs_n6001

# Kernel Name (Example:= board_test)
export ONEAPI_KERNEL_TEST_NAME=board_test

#################################################################################
#################### Simulater Set-up  ##########################################
#################################################################################

# Simulation Tool for Unit Test (MSIM, VCS, VCSMX)
export SIMULATION_TOOL_UNIT_TEST=VCS

# Simulation Tool for UVM (MSIM, VCS)
export SIMULATION_TOOL_UVM=VCS

#################################################################################
#################### Unit test Set-up  ##########################################
#################################################################################

# Examples for Unit test "base_x16"
# (bfm_test, csr_test, 
#  dfh_walker, flr, fme_csr_access, fme_csr_directed, he_lb_test, he_mem_lb_test, 
#  he_mem_tg_test, he_null_test, hssi_csr_test, hssi_kpi_test, 
#  hssi_test, indirect_csr, mem_ss_csr_test, mem_ss_rst_test, pcie_csr_test,
#  pmci_covergae_interface, pmci_csr_test,  pmci_fbm_fifo_overflow_test
#  pmci_fbm_fifo_underflow_test,
#  pmci_fbm_fifo_wr_rd_test, pmci_flash_test, pmci_flash_wr_rd_511dw_test,
#  pmci_flash_wr_rd_63dw_test, pmci_flash_wr_rd_random_test, pmci_flash_wr_rd_rsu_test,
#  pmci_flash_wr_rd_wo_rdmode_test, pmci_flash_wr_rd_wo_rsu_test, pmci_mailbox_test,
#  pmci_multi_master_test, pmci_pxeboot_test, pmci_qsfp_telemetry_test, pmci_rd_default_value_test,
#  pmci_ro_mailbox_test, pmci_vdm_b2b_drop_err_scenario_test, pmci_vdm_len_err_scenario_test,
#  pmci_vdm_mctp_mmio_b2b_test, pmci_vdm_multipkt_error_scenario_test, pmci_vdm_multipkt_tlp_err_test
#  pmci_vdm_tlp_error_scenario_test, pmci_vdm_tx_rx_all_random_lpbk_test, pmci_vdm_tx_rx_all_toggle_test
#  pmci_vdm_tx_rx_lpbk_test, port_gasket_test, qsfp_test, remote_stp_test, uart_csr)
                     
export UNIT_TEST_NAME=dfh_walker

#################################################################################
#################### UVM Set-up  ################################################
#################################################################################

# Examples for UVM
# (afu_mmio_flr_pf0_test,	afu_mmio_flr_pf0_vf0_test, afu_mmio_flr_pf0_vf1_test, afu_mmio_flr_pf0_vf2_test,	
#  afu_mmio_flr_pf1_vf0_test, afu_mmio_flr_pf2_test, afu_mmio_flr_pf3_test,	
#  afu_mmio_flr_pf4_test, afu_mmio_flr_test, afu_stress_5bit_tag test, afu_stress_8bit_tag test,
#  afu_stress_test, bar_32b_test, bar_64b_test,, base_test, ce_csr_test, dfh_walking_test, emif_csr_test, 
#  err_demoter, fme_csr_test,	fme_err_intr_test, fme_intr_test, fme_multi_err_intr_test, 
#  fme_ras_cat_fat_err_test, fme_ras_no_fat_err_test, he_hssi_axis_rx_lpbk_test, he_hssi_csr_test, 
#  he_hssi_rx_lpbk_25G_10G_test, he_hssi_tx_err_L0_test, he_hssi_tx_err_L1_test, he_hssi_tx_err_L2_test, 
#  he_hssi_tx_err_L3_test, he_hssi_tx_err_L4_test, he_hssi_tx_err_L5_test, he_hssi_tx_err_L6_test, he_hssi_tx_err_L7_test,
#  he_hssi_tx_err_test,he_hssi_tx_lpbk_P0_test, he_hssi_tx_lpbk_P1_test, he_hssi_tx_lpbk_P2_test,	
#  he_hssi_tx_lpbk_P3_test, he_hssi_tx_lpbk_P4_test, he_hssi_tx_lpbk_P5_test,	
#  he_hssi_tx_lpbk_P6_test, he_hssi_tx_lpbk_P7_test, he_lpbk_cont_test,	
#  he_lpbk_csr_test,  he_lpbk_long_rst_test,	he_lpbk_long_test,
#  he_lpbk_rd_cont_test, he_lpbk_rd_test, he_lpbk_reqlen1_test, he_lpbk_reqlen2_test,	
#  he_lpbk_reqlen4_test, he_lpbk_rst_in_middle_test, he_lpbk_test, he_lpbk_thruput_contmode_test, 	
#  he_lpbk_thruput_test, he_lpbk_wr_cont_test, he_lpbk_wr_test, he_mem_cont_test,	
#  he_mem_csr_test, he_lpbk_flr_rst_test,  he_mem_lpbk_long_rst_test, he_mem_lpbk_long_test,	
#  he_lpbk_multi_user_intr_test, he_mem_rd_cont_test, he_mem_rd_test, he_mem_lpbk_reqlen16_test,
#  he_mem_lpbk_reqlen1_test, he_mem_lpbk_reqlen2_test, he_mem_lpbk_reqlen4_test, he_mem_lpbk_test,
#  he_mem_multi_user_intr_test, he_mem_rst_in_middle_test,	
#  he_mem_thruput_contmode_directed_test, he_mem_thruput_contmode_test, he_mem_thruput_test,
#  he_mem_user_intr_test, he_mem_wr_cont_test, he_mem_wr_test, he_random_test,	
#  helb_rd_1cl_test, helb_rd_2cl_test, helb_rd_4cl_test, helb_thruput_1cl_test,	
#  helb_thruput_2cl_test, helb_thruput_4cl_5bit_tag_test, helb_thruput_4cl_8bit_tag_test, 
#  helb_thruput_4cl_test, helb_wr_1cl_test, helb_wr_2cl_test,	helb_wr_4cl_test, hssi_ss_test, malformedtlp_pcie_rst_test, 
#  malformedtlp_test,	maxpayloaderror_test, MaxReadReqSizeError_test, MaxTagError_test,
#  mem_tg_csr_test, mem_tg_traffic_gen_test, mini_smoke_test, mix_intr_test, mmio_pcie_mrrs_128B_mps_128B_test,	
#  mmio_pcie_mrrs_128B_mps_256B_test, mmio_pcie_mrrs_256B_mps_128B_test, mmio_pcie_mrrs_256B_mps_256B_test,	
#  mmio_stress_nonblocking_test, mmio_stress_test, mmio_test, mmio_unimp_test,
#  MMIODataPayloadOverrun_test, MMIOInsufficientData_test, MMIOTimedout_test,	
#  pcie_csr_test, pcie_pmci_mctp_256DW_test, pcie_pmci_mctp_multi_vdm_test, pcie_pmci_mctp_vdm_test,	
#  pmci_csr_test, pmci_fme_csr_test, pmci_pcie_mctp_multi_vdm_test, pmci_pcie_mctp_vdm_test,
#  pmci_pciess_csr_test, pmci_qsfp_csr_test, port_gasket_csr_test, protocol_checker_csr_test, qsfp_csr_test,	
#  TxMWrDataPayloadOverrun_test, TxMWrInsufficientData_test, uart_intr_test, UnexpMMIORspErr_test, vdm_err_vid_test)

export UVM_TEST_NAME=dfh_walking_test

#################################################################################
#################### Multi-Test Set-up  #########################################
#################################################################################

# A user can run a sequence of tests and execute them sequentially. In the example below when the user selects option 62 from the main menu the script will execute 24 tests ie (main menu options 2, 9, 12, 13, 14, 15, 16, 17, 18, 32, 34, 35, 37, 39, 40, 44, 45, 53, 55, 56, 57, 58, 59 and 60. All other tests with an "X" indicates do not run that test

intectiveprum=0
declare -A MULTI_TEST

# Enter Number of sequential tests to run
MULTI_TEST[62,tests]=24

# Enter options number from main menu

# "=======================================================================================" 
# "========================= ADP TOOLS MENU ==============================================" 
# "======================================================================================="
MULTI_TEST[62,X]=1
MULTI_TEST[62,0]=2
# "=======================================================================================" 
# "========================= ADP HARDWARE MENU ===========================================" 
# "=======================================================================================" 
MULTI_TEST[62,X]=3
MULTI_TEST[62,X]=4
MULTI_TEST[62,X]=5
MULTI_TEST[62,X]=6
MULTI_TEST[62,X]=7
MULTI_TEST[62,X]=8
# "======================================================================================="
# "========================= ADP PF/VF MUX MENU =========================================="
# "======================================================================================="
MULTI_TEST[62,1]=9
MULTI_TEST[62,X]=10
MULTI_TEST[62,X]=11
# "=======================================================================================" 
# "========================= ADP FIM/PR BUILD MENU =======================================" 
# "=======================================================================================" 
MULTI_TEST[62,2]=12
MULTI_TEST[62,3]=13
MULTI_TEST[62,4]=14
MULTI_TEST[62,5]=15
MULTI_TEST[62,6]=16
MULTI_TEST[62,7]=17
MULTI_TEST[62,8]=18
# "=======================================================================================" 
# "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
# "=======================================================================================" 
MULTI_TEST[62,X]=19
MULTI_TEST[62,X]=20
MULTI_TEST[62,X]=21
MULTI_TEST[62,X]=22
MULTI_TEST[62,X]=23
MULTI_TEST[62,X]=24
MULTI_TEST[62,X]=25
MULTI_TEST[62,X]=26
MULTI_TEST[62,X]=27
MULTI_TEST[62,X]=28
MULTI_TEST[62,X]=29
MULTI_TEST[62,X]=30
MULTI_TEST[62,X]=31
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
# "=======================================================================================" 
MULTI_TEST[62,9]=32
MULTI_TEST[62,X]=33
MULTI_TEST[62,10]=34
MULTI_TEST[62,11]=35
MULTI_TEST[62,X]=36
# "=======================================================================================" 
# "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
# "======================================================================================="
MULTI_TEST[62,12]=37
MULTI_TEST[62,X]=38
# "=======================================================================================" 
# "========================== ADP ONEAPI PROJECT MENU ====================================" 
# "======================================================================================="
MULTI_TEST[62,13]=39
MULTI_TEST[62,14]=40
MULTI_TEST[62,X]=41
MULTI_TEST[62,X]=42
MULTI_TEST[62,X]=43
MULTI_TEST[62,15]=44
MULTI_TEST[62,16]=45
MULTI_TEST[62,X]=46
MULTI_TEST[62,X]=47
MULTI_TEST[62,X]=48
MULTI_TEST[62,X]=49
MULTI_TEST[62,X]=50
MULTI_TEST[62,X]=51
MULTI_TEST[62,X]=52
MULTI_TEST[62,17]=53
MULTI_TEST[62,X]=54
# "=======================================================================================" 
# "========================== ADP UNIT TEST PROJECT MENU =================================" 
# "======================================================================================="
MULTI_TEST[62,18]=55
MULTI_TEST[62,19]=56
# "=======================================================================================" 
# "========================== ADP UVM PROJECT MENU =======================================" 
# "======================================================================================="
MULTI_TEST[62,20]=57
MULTI_TEST[62,21]=58
MULTI_TEST[62,22]=59
MULTI_TEST[62,23]=60
MULTI_TEST[62,X]=61

test_number=0
i=0
function press_enter
{
    echo ""
    
    if [ "$intectiveprum" = "0" ]  
    then           
      echo -n "Press Enter to continue" 
      read
      clear      
    elif [ "$intectiveprum" = "2" ]    
      then      
        if [ $i -gt ${MULTI_TEST[$test_number,tests]} ]        
          then          
            selection=
            multiplesteps=0
            i=0
            intectiveprum=0           
        else                          
            selection=${MULTI_TEST[$test_number,$i]}
            ((i++))      
        fi        
    else    
      echo -n "cycle complete exiting..."
      echo ""
      exit 0      
    fi    
}

if [ $# -eq 0 ];
then
  echo "$0: Missing arguments, opening the interactive screen"
  selection=
  
elif [ $# -gt 2 ];
then
  echo "$0: Too many arguments, opening the interactive screen"
  selection=
  
else
  
  selection=$1
  intectiveprum=1
  
fi

#################################################################################
#################### ADP TOOLS MENU  ############################################
#################################################################################

until [ "$selection" = "0" ]; do

if [ "$intectiveprum" = "0" ];
    
    then

echo ""
echo "=======================================================================================" 
echo "========================= ADP TOOLS MENU ==============================================" 
echo "======================================================================================="  
echo "1   - List of Documentation for ADP $ADP_PLATFORM Project" 
echo "2   - Check versions of Operating System and Quartus Premier Design Suite (QPDS)"
echo "=======================================================================================" 
echo "========================= ADP HARDWARE MENU ===========================================" 
echo "=======================================================================================" 
echo "3   - Identify Acceleration Development Platform (ADP) $ADP_PLATFORM Hardware via PCIe"
echo "4   - Identify the Board Management Controller (BMC) Version and check BMC sensors"
echo "5   - Identify the FPGA Management Engine (FME) Version"
echo "6   - Check Board Power and Temperature"
echo "7   - Check Accelerator Port status"
echo "8   - Check MAC and PHY status"
echo "======================================================================================="
echo "========================= ADP PF/VF MUX MENU =========================================="
echo "======================================================================================="
echo "9   - Check PF/VF Mux Configuration"
echo "10  - Modify PF/VF Mux Configuration"
echo "11  - Build PF/VF Mux Configuration"
echo "=======================================================================================" 
echo "========================= ADP FIM/PR BUILD MENU =======================================" 
echo "======================================================================================="     
echo "12  - Check ADP software versions for ADP $ADP_PLATFORM Project"
echo "13  - Build FIM for $ADP_PLATFORM Hardware"
echo "14  - Check FIM Identification of FIM for $ADP_PLATFORM Hardware"
echo "15  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware"
echo "16  - Build Base FIM Identification(ID) into PR Build Tree template"
echo "17  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware with Remote Signal Tap"
echo "18  - Build Base FIM Identification(ID) into PR Build Tree template with Remote Signal Tap"
echo "=======================================================================================" 
echo "========================= ADP HARDWARE PROGRAMMING/DIAGNOSTIC MENU ====================" 
echo "=======================================================================================" 
echo "19  - Program BMC Image into $ADP_PLATFORM Hardware"
echo "20  - Check Boot Area Flash Image from $ADP_PLATFORM Hardware"
echo "21  - Program FIM Image into $FPGA_SR_USER_FLASH area for $ADP_PLATFORM Hardware"
echo "22  - Initiate Remote System Upgrade (RSU) from $FPGA_SR_USER_FLASH Flash Image into $ADP_PLATFORM Hardware"
echo "23  - Check PF/VF Mapping Table, vfio-pci driver binding and accelerator port status"
echo "24  - Unbind vfio-pci driver"
echo "25  - Create Virtual Functions (VF) and bind driver to vfio-pci $ADP_PLATFORM Hardware"
echo "26  - Verify FME Interrupts with hello_events"
echo "27  - Run HE-LB Test"
echo "28  - Run HE-MEM Test"
echo "29  - Run HE-HSSI Test"
echo "30  - Run Traffic Generator AFU Test"
echo "31  - Read from CSR (Command and Status Registers) for $ADP_PLATFORM Hardware"
echo "=======================================================================================" 
echo "========================== ADP HARDWARE AFU TESTING MENU ==============================" 
echo "=======================================================================================" 
echo "32  - Build and Compile $AFU_TEST_NAME example"
echo "33  - Execute $AFU_TEST_NAME example"
echo "34  - Modify $AFU_TEST_NAME example to insert Remote Signal Tap"
echo "35  - Build and Compile $AFU_TEST_NAME example with Remote Signal Tap"
echo "36  - Execute $AFU_TEST_NAME example with Remote Signal Tap"
echo "=======================================================================================" 
echo "========================== ADP HARDWARE AFU BBB TESTING MENU ==========================" 
echo "=======================================================================================" 
echo "37  - Build and Compile $AFU_BBB_TEST_NAME example"
echo "38  - Execute $AFU_BBB_TEST_NAME example"
echo "=======================================================================================" 
echo "========================== ADP ONEAPI PROJECT MENU ====================================" 
echo "======================================================================================="
echo "39  - Check oneAPI software versions for $ADP_PLATFORM Project"
echo "40  - Build and clone shim libraries required by oneAPI host"
echo "41  - Install oneAPI Host Driver"
echo "42  - Uninstall one API Host Driver"
echo "43  - Diagnose oneAPI Hardware"
echo "44  - Build oneAPI BSP $ONEAPI_BOARD_NAME Default Kernel (hello_world)"
echo "45  - Build oneAPI MakeFile Environment for ($ONEAPI_KERNEL_TEST_NAME)"
echo "46  - Compile oneAPI Sample Application ($ONEAPI_KERNEL_TEST_NAME) for Emulation"
echo "47  - Run oneAPI Sample Application ($ONEAPI_KERNEL_TEST_NAME) for Emulation"
echo "48  - Generate oneAPI Optimization report for ($ONEAPI_KERNEL_TEST_NAME)"
echo "49  - Check PF/VF Mapping Table, vfio-pci driver binding and accelerator port status"
echo "50  - Unbind vfio-pci driver"
echo "51  - Create Virtual Function (VF) and bind driver to vfio-pci $ADP_PLATFORM Hardware"
echo "52  - Program oneAPI BSP $ONEAPI_BOARD_NAME Default Kernel (hello_world)"
echo "53  - Compile oneAPI Sample Application ($ONEAPI_KERNEL_TEST_NAME) for Hardware"
echo "54  - Run oneAPI Sample Application ($ONEAPI_KERNEL_TEST_NAME) for Hardware"
echo "=======================================================================================" 
echo "========================== ADP UNIT TEST PROJECT MENU =================================" 
echo "======================================================================================="
echo "55  - Generate Simulation files for Unit Test"
echo "56  - Simulate Unit Test $UNIT_TEST_NAME and log waveform using $SIMULATION_TOOL_UNIT_TEST"
echo "=======================================================================================" 
echo "========================== ADP UVM PROJECT MENU =======================================" 
echo "======================================================================================="
echo "57  - Check UVM software versions for $ADP_PLATFORM Project"
echo "58  - Compile UVM IP using $SIMULATION_TOOL_UVM"
echo "59  - Compile UVM RTL and Testbench using $SIMULATION_TOOL_UVM" 
echo "60  - Simulate single UVM $UVM_TEST_NAME and log waveform using $SIMULATION_TOOL_UVM"
echo "61  - Simulate all UVM test cases (Regression Mode) using $SIMULATION_TOOL_UVM"
echo "=======================================================================================" 
echo "========================== ADP BUILD ALL PROJECT MENU =================================" 
echo "======================================================================================="
echo "62  - Build and Simulate Complete $ADP_PLATFORM Project"
echo ""
echo "0   - Exit program"
echo ""
echo -n "Enter selection: "
read selection
echo ""

else
	echo "Go to selection: $selection"
fi

case $selection in

        1) 

echo "###########################################################################################"
echo "#################### List of Documentation for ADP Project ################################"
echo "###########################################################################################"
echo ""
echo "Open FPGA Stack Overview"
echo "Guides you through the setup and build steps to evaluate the OFS solution"
echo "https://ofs.github.io"
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        2) 

echo "###########################################################################################"
echo "#################### Check versions of Operation System, Quartus ##########################"
echo "###########################################################################################"
echo ""
echo "Checking Linux release"
cat /proc/version
echo ""
echo "Checking RedHat release"
cat /etc/redhat-release
echo ""
echo "Checking Ubuntu release"
cat /etc/lsb-release
echo ""
echo "Checking Kernel parameters"
cat /proc/cmdline
echo ""
echo "Checking Licenses"
echo "LM_LICENSE_FILE is set to $LM_LICENSE_FILE" 
echo ""
echo "DW_LICENSE_FILE is set to $DW_LICENSE_FILE"
echo ""
echo "SNPSLMD_LICENSE_FILE is set to $SNPSLMD_LICENSE_FILE"
echo ""
echo "Checking Tool versions"
echo "QUARTUS_HOME is set to $QUARTUS_HOME"
echo ""
echo "QUARTUS_ROOTDIR is set to $QUARTUS_ROOTDIR"
echo ""
echo "IMPORT_IP_ROOTDIR is set to $IMPORT_IP_ROOTDIR"
echo ""
echo "QSYS_ROOTDIR is set to $QSYS_ROOTDIR"
echo ""
echo "Checking QPDS Patches"
quartus_sh --version
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        3) 

echo "###########################################################################################"
echo "#################### Identify Acceleration Development Platform ADP Hardware ##############"
echo "###########################################################################################"
echo ""

echo "PCIe card detected as" 
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    
  
        echo ""
        lspci | grep $ADP_CARD1_DEVICE_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
elif [ $ADP_PLATFORM == "n6XXXX" ]  

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
        echo ""
        lspci | grep $ADP_CARD0_DEVICE_ID
        echo ""    
  
        echo ""
        lspci | grep $ADP_CARD1_DEVICE_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Host Server is connected to $ADP_CARD_CONFIG card configuration"
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        4) 

echo "###########################################################################################"
echo "#################### Identify the Board Management Controller (BMC) Version ###############"
echo "###########################################################################################"
echo ""
echo "Identify BMC Image"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo bmc $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo bmc $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo bmc $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;


        5) 

echo "###########################################################################################"
echo "#################### Identify the FPGA Management Engine (FME) Version ####################"
echo "###########################################################################################"
echo ""
echo "Identify FME Image"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo fme $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo fme $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        6)

echo ""     
echo "###########################################################################################"
echo "############ Check Board Power and Temperature ############################################"
echo "###########################################################################################"
echo ""
echo "Checking Power and Temperature Status"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo power $ADP_CARD1_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo power $ADP_CARD0_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo power $ADP_CARD1_ID
        echo ""
        sudo fpgainfo temp $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        7)

echo ""     
echo "###########################################################################################"
echo "############ Check Accelerator Port Status ################################################"
echo "###########################################################################################"
echo ""
echo "Checking Accelerator Port Status"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""    
  
        echo ""
        sudo fpgainfo port $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo port $ADP_CARD0_ID
        echo """"    
  
        echo ""
        sudo fpgainfo port $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        8)

echo ""     
echo "###########################################################################################"
echo "############ Check MAC and PHY status #####################################################"
echo "###########################################################################################"
echo ""
echo "Checking MAC and PHY status"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo mac $ADP_CARD1_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo mac $ADP_CARD0_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD0_ID
        echo ""   
  
        echo ""
        sudo fpgainfo mac $ADP_CARD1_ID
        echo ""
        sudo fpgainfo phy $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        9) 

echo "###########################################################################################"
echo "#################### Check PF/VF Mux Configuration ########################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
  
    cd $OFS_ROOTDIR/tools/pfvf_config_tool
    cat pcie_host.ofss
    cd $IOFS_BUILD_ROOT
 
elif [ $ADP_PLATFORM == "fXXXX" ]

  then

    cd $OFS_ROOTDIR/tools/pfvf_config_tool
    cat pcie_host.ofss
    cd $IOFS_BUILD_ROOT

else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        10) 

echo "###########################################################################################"
echo "#################### Modify PF/VF Mux Configuration #######################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
  
    cd $OFS_ROOTDIR/tools/pfvf_config_tool
    sed -i "s/num_vfs = 3/num_vfs = 1/g" pcie_host.ofss
    sed -i "s/\[pf[1-4]\]//g" pcie_host.ofss
    cat pcie_host.ofss
    cd $IOFS_BUILD_ROOT
 
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/tools/pfvf_config_tool
    sed -i "s/num_vfs = 3/num_vfs = 1/g" pcie_host.ofss
    sed -i "s/\[pf[1-4]\]//g" pcie_host.ofss
    cat pcie_host.ofss
    cd $IOFS_BUILD_ROOT

else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        11) 

echo "###########################################################################################"
echo "#################### Build PF/VF Mux Configuration ########################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
  
    cd $OFS_ROOTDIR/ofs-common/tools/pfvf_config_tool/
  
    ./gen_ofs_settings.py --ini ../../../tools/pfvf_config_tool/pcie_host.ofss --platform $ADP_PLATFORM
    
    cd $IOFS_BUILD_ROOT
 
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/ofs-common/tools/pfvf_config_tool/
  
    ./gen_ofs_settings.py --ini ../../../tools/pfvf_config_tool/pcie_host.ofss --platform $ADP_PLATFORM
    
    cd $IOFS_BUILD_ROOT

else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        12) 

echo "###########################################################################################"
echo "#################### Check ADP software versions for ADP Project ##########################"
echo "###########################################################################################"
echo ""
echo "OFS_ROOTDIR is set to $OFS_ROOTDIR"
echo ""
echo "OPAE_SDK_REPO_BRANCH is set to $OPAE_SDK_REPO_BRANCH"
echo ""
echo "OPAE_SDK_ROOT is set to $OPAE_SDK_ROOT"
echo ""
echo "LD_LIBRARY_PATH is set to $LD_LIBRARY_PATH"

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        13) 

echo "###########################################################################################"
echo "#################### Build FIM ############################################################"
echo "###########################################################################################"
echo ""
echo "Build default FIM"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR" ]; then rm -Rf $FIM_WORKDIR; fi     
    
    ofs-common/scripts/common/syn/build_top.sh $ADP_PLATFORM:$FIM_SHELL_NULL $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR" ]; then rm -Rf $FIM_WORKDIR; fi     
    
    ofs-common/scripts/common/syn/build_top.sh $ADP_PLATFORM:$FIM_SHELL_NULL $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        14) 

echo "###########################################################################################"
echo "#################### Check FIM Identification of Base FIM #################################"
echo "###########################################################################################"
echo ""
echo "checking FIM ID fme-ifc-id.txt"

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/
    echo ""
    cat fme-ifc-id.txt
    echo ""
    echo "This FIM ID must be used for the Partial Reconfigration Build Tree Template"
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/
    echo ""
    cat fme-ifc-id.txt
    echo ""
    echo "This FIM ID must be used for the Partial Reconfiguration Build Tree Template"
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        15) 

echo "###########################################################################################"
echo "#################### Build Partial Reconfiguration Tree ###################################"
echo "###########################################################################################"
echo ""
echo "Build Partial Reconfiguration Tree"

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR" ]; then rm -Rf $FIM_WORKDIR_PR; fi     
    
    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR $ADP_PLATFORM $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR" ]; then rm -Rf $FIM_WORKDIR_PR; fi     
    
    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR $ADP_PLATFORM $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        16) 

echo "###########################################################################################"
echo "#################### Build Base FIM ID into PR Build Tree template ########################"
echo "###########################################################################################"
echo ""
echo "Copying FIM ID into PR build tree template"

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/adp/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        17) 

echo "###########################################################################################"
echo "#################### Build Partial Reconfiguration Tree with Remote Signal Tap ############"
echo "###########################################################################################"
echo ""
echo "Build Partial Reconfiguration Tree with Remote Signal Tap"

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR_STP" ]; then rm -Rf $FIM_WORKDIR_PR_STP; fi     
    
    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR_STP $ADP_PLATFORM $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR

    if [ -d "$FIM_WORKDIR_PR_STP" ]; then rm -Rf $FIM_WORKDIR_PR_STP; fi     
    
    ofs-common/scripts/common/syn/generate_pr_release.sh -t $FIM_WORKDIR_PR_STP $ADP_PLATFORM $FIM_WORKDIR
    
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        18) 

echo "###########################################################################################"
echo "#################### Build Base FIM ID into PR Build Tree template with Remote Signal Tap #"
echo "###########################################################################################"
echo ""
echo "Copying FIM ID into PR build tree template"

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR_STP/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $OFS_ROOTDIR/$FIM_WORKDIR_PR_STP/hw/lib/
    cp $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/fme-ifc-id.txt .
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        19) 

echo "###########################################################################################"
echo "#################### Program BMC Image into Hardware ######################################"
echo "###########################################################################################"
echo ""
echo "Programming BMC image into $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID        
  
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD1_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD1_ID     
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD0_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD0_ID        
  
          cd $OFS_ROOTDIR/bmc_flash_files
          sudo fpgasupdate $BMC_RTL_FW_FLASH $ADP_CARD1_ID
          echo ""
          sudo rsu bmcimg $ADP_CARD1_ID
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        20) 

echo "###########################################################################################"
echo "#################### Check Boot Area Image into Hardware ##################################"
echo "###########################################################################################"
echo ""
echo "Checking Boot area Image from $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    
  
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""    
  
        echo ""
        sudo fpgainfo fme | grep Boot 
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        21) 

echo "###########################################################################################"
echo "#################### Program FIM Image into Hardware ######################################"
echo "###########################################################################################"
echo ""
echo "Programming FIM image into $ADP_PLATFORM hardware"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD0_ID
        echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD0_ID
        echo ""     
  
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD0_ID
        echo ""     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD0_ID
        echo ""     
  
        cd $OFS_ROOTDIR/$FIM_WORKDIR/syn/syn_top/output_files
        sudo fpgasupdate ofs_top_${FPGA_SR_PAGE_FLASH}_unsigned_${FPGA_SR_USER_FLASH}.bin $ADP_CARD1_ID
        echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        22)

echo "###########################################################################################"
echo "#################### RSU FIM Image into Hardware ##########################################"
echo "###########################################################################################"
echo ""
echo "Initiate Remote System Upgrade (RSU) from $FPGA_SR_USER_FLASH FIM Image into $ADP_PLATFORM Hardware"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""     
  
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD1_ID
        echo "" 
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD0_ID
        echo ""    
  
        echo ""
        sudo rsu fpga --page=$FPGA_SR_USER_FLASH $ADP_CARD1_ID
        echo ""  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        23) 

echo "###########################################################################################"
echo "#################### Check PF/VF, vfio-pci driver binding and accelerator port status #####"
echo "###########################################################################################"
echo ""
echo "Check PF/VF Mapping Table"
echo " │MODULE           │PF/VF"
echo ""
echo " │ST2MM            │PF0"
echo " │HE-MEM           │PF0-VF0"
echo " │HE-HSSI          │PF0-VF1"
echo " │HE-MEM_TG        │PF0-VF2"
echo " │HE-LB Dummy      │PF1-VF0"
echo " │HE-LB            │PF2"
echo " │VirtIO LB        │PF3"
echo " │HPS Copy Engine  │PF4"
echo ""

echo "Checking Current binding of Drivers"
sudo opae.io ls
echo ""

echo "Check that the accelerators are present using fpgainfo"
if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""        
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = Copy Engine"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
        echo ""        
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""         

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""         
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
        echo ""        
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;; 

        24) 

echo "###########################################################################################"
echo "#################### Unbind vfio-pci driver ###############################################"
echo "###########################################################################################"
echo ""
echo "Unbinding Current Drivers"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7   
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        25) 

echo "###########################################################################################"
echo "#################### Create 3 VF's and bind vfio-pci driver ###############################"
echo "###########################################################################################"
echo ""


if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 $USER
        echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 $USER
        echo ""    
  
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD1_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 $USER
        echo ""  
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 $USER
        echo "" 

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD0_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 $USER
        echo ""    
  
        echo "Create 3 Virtual Functions (VF)"
        sudo pci_device $ADP_CARD1_ID vf 3
        echo ""
        echo "Verify all 3 VFs were created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind all of the VFs 0 through 7 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 $USER
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 $USER
        echo "" 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        26) 

echo "###########################################################################################"
echo "#################### Verify FME Interrupts with hello_events ##############################"
echo "###########################################################################################"
echo ""
echo "Run a simple FME Interrupt test"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER 
           echo ""      

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER 
           echo "" 
    
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.$ADP_CARD1_FUNCTION_NUMBER 
           echo ""

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER 
           echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.$ADP_CARD0_FUNCTION_NUMBER 
           echo "" 
    
           echo "The hello_events utility is used to verify FME interrupts. This tool injects FME errors and waits for error interrupts, then clears the errors"
           sudo hello_events $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.$ADP_CARD1_FUNCTION_NUMBER 
           echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        27) 

echo "###########################################################################################"
echo "#################### Run HE-LB Test #######################################################"
echo "###########################################################################################"
echo ""
echo "Run a simple loopback test"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""   
    
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""   
    
           echo "Checking and generating traffic with the intention of exercising the path from the AFU to the Host at full bandwidth"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 lpbk 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_1 lpbk 
           echo ""
           echo "run a loopback read test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode read --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback write test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode write --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo ""
           echo "run a loopback throughput test using four cachelines per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 --clock-mhz 400 --mode trput --cls cl_4 --continuousmode true --contmodetime 10 lpbk 
           echo "" 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        28) 

echo "###########################################################################################"
echo "#################### Run HE-MEM Test ######################################################"
echo "###########################################################################################"
echo ""
echo "Run a simple mem test"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem 
           echo ""  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem
           echo ""  
    
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem 
           echo ""  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem 
           echo ""       

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem 
           echo ""  
    
           echo "Checking and generating traffic with the intention of exercising the path from FPGA connected DDR; data read from the host is written to DDR, and the same data is read from DDR before sending it back to the host"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 --clock-mhz 400 mem 
           echo ""
           echo "run a loopback throughput test using one cacheline per request"
           sudo host_exerciser --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 --clock-mhz 400 --mode trput --cls cl_1 mem 
           echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        29) 

echo "###########################################################################################"
echo "#################### Run HE-HSSI Test #####################################################"
echo "###########################################################################################"
echo ""
echo "HE-HSSI is responsible for handling client-side ethernet traffic. It wraps the 10G and 100G HSSI AFUs, and includes a traffic generator and checker. The user-space tool hssi exports a control interface to the HE-HSSI's AFU's packet generator logic"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD0_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo "" 

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD0_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo ""  
          
          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD1_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo ""  
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD0_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo ""    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD0_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo ""    

          echo "Check PHY settings with fpgainfo"
          sudo fpgainfo phy -B 0x$ADP_CARD1_BUS_NUMBER
          echo ""
          echo "Set loopback mode"
          sudo hssiloopback --loopback enable  --port 0 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 1 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 2 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 3 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 4 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 5 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 6 --pcie-address $ADP_CARD0_ID
          sudo hssiloopback --loopback enable  --port 7 --pcie-address $ADP_CARD0_ID
          echo ""
          echo "Send traffic through the 10G AFU"
          sudo hssi --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 hssi_10g --num-packets 100
          echo ""  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        30) 

echo "###########################################################################################"
echo "#################### Run Traffic Generator AFU Test #######################################"
echo "###########################################################################################"
echo ""
echo "Run a simple mem test"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""
     
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""
  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""      

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""
     
           echo "Run the preconfigured write/read traffic test on channel 0"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 tg_test 
           echo ""
           echo "Target channel 1 with a 1MB single-word write only test for 1000 iterations"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 1000 -r 0 -w 2000 -m 1 tg_test
           echo ""
           echo "Target channel 2 with 4MB write/read test of max burst length for 10 iterations"
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 10 -r 8 -w 8 --bls 255 -m 2 tg_test
           echo ""
           sudo mem_tg --pci-address $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 --loops 1000 -r 2000 -w 2000 --stride 2 --bls 2  -m 1 tg_test
           echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        31) 

echo "###########################################################################################"
echo "#################### Reading Command and Status Registers (CSR) ###########################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""
          
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""
          
          echo " HE-LB Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x1000010000000000    │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xb94b12284c31e02b    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x56e203e9864f49a7    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-LB AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x0
          echo ""
          echo "Reading HE-LB AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x8
          echo ""
          echo "Reading HE-LB AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x10
          echo ""
          echo "Reading HE-LB AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2 -r 0 peek 0x100
          echo ""
          echo ""
          echo " HE-MEM Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │HE_DFH                │0x0000     │0x10000100000000000   │HE DFH"
          echo " │HE_ID_L               │0x0008     │0xbb652a578330a8eb    │HE ID (Lower 64-bit)"
          echo " │HE_ID_H               │0x0010     │0x8568ab4e6ba54616    │HE ID (Upper 64-bit)"
          echo " │HE_SCRATCHPAD0        │0x00100    │0x0000000000000000    │Scratchpad Register 0"
          echo ""
          echo "Reading HE-MEM AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x0
          echo ""
          echo "Reading HE-MEM AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x8
          echo ""
          echo "Reading HE-MEM AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x10
          echo ""
          echo "Reading HE-MEM AFU_SCRATCHPAD0 CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 -r 0 peek 0x100
          echo ""
          echo " HE-HSSI Command and Status Register Default Definitions"
          echo ""
          echo " │REGISTER NAME         │ADDRESS    │DEFAULT___________	   │DESCRIPTION"
          echo ""
          echo " │AFU_DFH               │0x0000     │0x1000010000001000    │AFU DFH"
          echo " │AFU_ID_L              │0x0008     │0xBB370242AC130002    │AFU ID (Lower 64-bit)"
          echo " │AFU_ID_H              │0x0010     │0x823C334C98BF11EA    │AFU ID (Upper 64-bit)"
          echo " │AFU_SCRATCHPAD        │0x0048     │0x0000000045324511    │Scratchpad Register"
          echo ""
          echo "Reading HE-HSSI AFU_DFH CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x0
          echo ""
          echo "Reading HE-HSSI AFU_ID_L CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x8
          echo ""
          echo "Reading HE-HSSI AFU_ID_H CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x10
          echo ""
          echo "Reading HE-HSSI AFU_SCRATCHPAD CSR Register"
          sudo opae.io -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6 -r 0 peek 0x48
          echo ""
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        32) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU example ########################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME

if [ $ADP_PLATFORM == "n6001" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        33) 

echo "###########################################################################################"
echo "#################### Execute AFU example ##################################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
         
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME     

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        34) 

echo "###########################################################################################"
echo "#################### Insert Remote Signal Tap into AFU example ############################"
echo "###########################################################################################"
echo ""
echo "Modify ofs_top.qsf and ofs_pr_afu.qsf to add Remote Signal Tap"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    # Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
    export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
    cd $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
    echo ""
    echo set_global_assignment -name ENABLE_SIGNALTAP ON >> ofs_top.qsf
    echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> ofs_top.qsf
    echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  ofs_top.qsf
    echo ""
    echo set_global_assignment -name ENABLE_SIGNALTAP ON >> ofs_pr_afu.qsf
    echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> ofs_pr_afu.qsf
    echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  ofs_pr_afu.qsf
    
    echo "Copying host_chan_mmio.stp Signal Tap file to $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top"
    
    cp $IOFS_BUILD_ROOT/host_chan_mmio.stp $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    # Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
    export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
    cd $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
    echo ""
    echo set_global_assignment -name ENABLE_SIGNALTAP ON >> ofs_top.qsf
    echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> ofs_top.qsf
    echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  ofs_top.qsf
    echo ""
    echo set_global_assignment -name ENABLE_SIGNALTAP ON >> ofs_pr_afu.qsf
    echo set_global_assignment -name USE_SIGNALTAP_FILE $AFU_TEST_NAME.stp >> ofs_pr_afu.qsf
    echo set_global_assignment -name SIGNALTAP_FILE $AFU_TEST_NAME.stp>>  ofs_pr_afu.qsf
    
    echo "Copying host_chan_mmio.stp Signal Tap file to $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top"
    
    cp $IOFS_BUILD_ROOT/host_chan_mmio.stp $OPAE_PLATFORM_ROOT/hw/lib/build/syn/syn_top
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        35) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU example with Remote Signal Tap #################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP
cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME

if [ $ADP_PLATFORM == "n6001" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware_stp" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware_stp; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware_stp
    cd hardware_stp
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    echo "Removing $AFU_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware_stp" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware_stp; fi
      
    echo "Building $AFU_TEST_NAME test directory"
    mkdir -p $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/hw/rtl/test_mmio_axi1.txt hardware_stp
    cd hardware_stp
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        36) 

echo "###########################################################################################"
echo "#################### Execute AFU example with Remote Signal Tap ###########################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree (Remote Signal Tap)
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR_STP/pr_build_template

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
         
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME      

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD0_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME  
    
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware_stp 
        echo "Reconfigure $AFU_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_TEST_NAME.gbs $ADP_CARD1_ID
        cd $OFS_PLATFORM_AFU_BBB_EXTERNAL/plat_if_tests/$AFU_TEST_NAME/sw
        make
        ./$AFU_TEST_NAME 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        37) 

echo "###########################################################################################"
echo "#################### Build and Compile AFU BBB example ####################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME

if [ $ADP_PLATFORM == "n6001" ]

  then
    echo "Removing $AFU_BBB_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_BBB_TEST_NAME test directory"
    mkdir -p $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/hw/rtl/$AFU_BBB_INTERFACE_NAME/sources.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    echo "Removing $AFU_BBB_TEST_NAME test directory"
    if [ -d "$ADP_PLATFORM/$FIM_SHELL/hardware" ]; then rm -Rf $ADP_PLATFORM/$FIM_SHELL/hardware; fi
      
    echo "Building $AFU_BBB_TEST_NAME test directory"
    mkdir -p $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL
    afu_synth_setup -s $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/hw/rtl/$AFU_BBB_INTERFACE_NAME/sources.txt hardware
    cd hardware
    $OPAE_PLATFORM_ROOT/bin/afu_synth
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        38) 

echo "###########################################################################################"
echo "#################### Execute AFU BBB example ##############################################"
echo "###########################################################################################"
echo ""
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME
    
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD1_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME

    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME      

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD0_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME
        
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/$ADP_PLATFORM/$FIM_SHELL/hardware
        echo "Reconfigure $AFU_BBB_TEST_NAME Green Bit Stream"
        sudo fpgasupdate $AFU_BBB_TEST_NAME.gbs $ADP_CARD1_ID
        cd $FPGA_BBB_CCI_SRC/tutorial/afu_types/01_pim_ifc/$AFU_BBB_TEST_NAME/sw
        make
        ./$AFU_BBB_TEST_NAME 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        39) 

echo "###########################################################################################"
echo "#################### Check Set-up of ADP oneAPI Project ###################################"
echo "###########################################################################################"
echo ""
# oneAPI Tools
source $ONEAPI_TOOLS_LOCATION/intel/oneapi/setvars.sh
echo ""

echo "Checking Intel oneAPI base toolkit"
echo ""
icpx --version
echo ""
echo "The Intel oneAPI base toolkit version must match the oneAPI samples version"
echo ""
echo "Example: If icpx --version is 2023.1.0 then oneAPI-samples tag must be 2023.1.0"
echo ""
echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        40) 

echo "###########################################################################################"
echo "#################### Build and clone shim libraries required by oneAPI host ###############"
echo "###########################################################################################"
echo ""
cd $IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM/scripts
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
./build-bsp.sh

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        41)
    
echo "###########################################################################################"
echo "#################### Install oneAPI Host Driver ###########################################"
echo "###########################################################################################"
echo ""     
aocl install $IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo "" 
date
echo "" ; press_enter ;;

        42)
     
echo "###########################################################################################"
echo "#################### Uninstall oneAPI Host Driver #########################################"
echo "###########################################################################################"
echo ""     
aocl uninstall $IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo "" 
date
echo "" ; press_enter ;;

        43)

echo ""     
echo "###########################################################################################"
echo "#################### Diagnose oneAPI Hardware #############################################"
echo "###########################################################################################"
echo "" 
#export ACL_PCIE_DEBUG=1
#export ACL_HAL_DEBUG=1

aocl diagnose

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
         aocl diagnose acl0    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
         aocl diagnose acl0        
  
         aocl diagnose acl1     
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
         aocl diagnose acl0    

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
         aocl diagnose acl0        
  
         aocl diagnose acl1  
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        44) 

echo "###########################################################################################"
echo "#################### Build oneAPI BSP Default Kernel (hello_world) ########################"
echo "###########################################################################################"
echo ""
cd $IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM/scripts
# Partial Reconfiguration (PR) Build Tree
export OPAE_PLATFORM_ROOT=$OFS_ROOTDIR/$FIM_WORKDIR_PR
./build-default-aocx.sh -b $ONEAPI_BOARD_NAME

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        45) 

echo "###########################################################################################"
echo "#################### Build oneAPI MakeFile ################################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    
    echo "Removing $ONEAPI_KERNEL_TEST_NAME build directory"
    if [ -d "build" ]; then rm -Rf build; fi
    
    mkdir -p build
    cd build
    cmake -DFPGA_DEVICE=$IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM:$ONEAPI_BOARD_NAME ..
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    
    echo "Removing $ONEAPI_KERNEL_TEST_NAME build directory"
    if [ -d "build" ]; then rm -Rf build; fi
    
    mkdir -p build
    cd build
    cmake -DFPGA_DEVICE=$IOFS_BUILD_ROOT/oneapi-asp/$ADP_PLATFORM:$ONEAPI_BOARD_NAME ..
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        46) 

echo "###########################################################################################"
echo "#################### Compile oneAPI Sample Application for Emulation ######################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make fpga_emu
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make fpga_emu
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        47) 

echo "###########################################################################################"
echo "#################### Run oneAPI Sample Application for Emulation ##########################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    echo "Run oneAPI Emulation mode"
    ./board_test.fpga_emu
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    echo "Run oneAPI Emulation mode"
    ./board_test.fpga_emu
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        48) 

echo "###########################################################################################"
echo "#################### Generate oneAPI Optimization report ##################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make report
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make report
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        49) 

echo "###########################################################################################"
echo "#################### Check PF/VF, vfio-pci driver binding and accelerator port status #####"
echo "###########################################################################################"
echo ""
echo "Check PF/VF Mapping Table"
echo " │MODULE           │PF/VF"
echo ""
echo " │ST2MM            │PF0"
echo " │HE-MEM           │PF0-VF0"
echo " │HE-HSSI          │PF0-VF1"
echo " │HE-MEM_TG        │PF0-VF2"
echo " │HE-LB Dummy      │PF1-VF0"
echo " │HE-LB            │PF2"
echo " │VirtIO LB        │PF3"
echo " │HPS Copy Engine  │PF4"
echo ""

echo "Checking Current binding of Drivers"
sudo opae.io ls
echo ""

echo "Check that the accelerators are present using fpgainfo"
if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""        

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""        
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = Copy Engine"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
        echo ""        
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""         

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7
        echo ""         
  
        echo ""  
        echo "Accelerater Port 0 = ST2MM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.0
        echo "" 
        echo "Accelerater Port 1 = VirtIO LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
        echo "" 
        echo "Accelerater Port 2 = HE-LB"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
        echo ""
        echo "Accelerater Port 4 = HPS Copy Engine"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
        echo ""
        echo "Accelerater Port 5 = HE-MEM"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
        echo ""
        echo "Accelerater Port 6 = HE-HSSI" 
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
        echo ""
        echo "Accelerater Port 7 = HE-MEM-TG"
        sudo fpgainfo port $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
        echo ""        
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;; 

        50) 

echo "###########################################################################################"
echo "#################### Unbind vfio-pci driver ###############################################"
echo "###########################################################################################"
echo ""
echo "Unbinding Current Drivers"

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7 
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7   

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.7   
  
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.1
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.2
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.3
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.4
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.6
          sudo opae.io release -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.7 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        51) 

echo "###########################################################################################"
echo "#################### Create 1 VF and bind vfio-pci driver #################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD0_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD0_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER
          
        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD1_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 $USER
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
      
        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD0_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then
      
        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD0_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD0_SOCKET_NUMBER:$ADP_CARD0_BUS_NUMBER:$ADP_CARD0_DEVICE_NUMBER.5 $USER

        echo ""
        echo "Create 1 Virtual Function (VF)"
        sudo pci_device $ADP_CARD1_ID vf 1
        echo ""
        echo "Verify 1 VF is created"
        sudo lspci -s $ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER
        echo ""
        echo "Bind VF 5 to the vfio-pci driver"
        sudo opae.io init -d $ADP_CARD1_SOCKET_NUMBER:$ADP_CARD1_BUS_NUMBER:$ADP_CARD1_DEVICE_NUMBER.5 $USER
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        52) 

echo "###########################################################################################"
echo "#################### Program oneAPI BSP Default Kernel (hello_world) ######################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then

        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl1 $ONEAPI_BOARD_NAME  

    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then

        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl0 $ONEAPI_BOARD_NAME  

        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl1 $ONEAPI_BOARD_NAME 
  
    else 

        echo "None of the conditions met"

    fi
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
    if [ $ADP_CARD_CONFIG == "SINGLE" ]
      then
        
        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl0 $ONEAPI_BOARD_NAME 


    elif [ $ADP_CARD_CONFIG == "MULTI" ]

      then

        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl0 $ONEAPI_BOARD_NAME  

        # Program oneAPI BSP Default Kernel (boardtest)
        aocl initialize acl1 $ONEAPI_BOARD_NAME 
  
    else 

        echo "None of the conditions met"

    fi
  
else 

  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        53) 

echo "###########################################################################################"
echo "#################### Compile oneAPI Sample Application for Hardware #######################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make fpga
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    make fpga
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        54) 

echo "###########################################################################################"
echo "#################### Run oneAPI Sample Application for Hardware ###########################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    echo "Run oneAPI Hardware mode"
    ./board_test.fpga
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then
  
    cd $IOFS_BUILD_ROOT/oneAPI-samples/DirectProgramming/C++SYCL_FPGA/ReferenceDesigns/$ONEAPI_KERNEL_TEST_NAME
    cd build
    echo "Run oneAPI Hardware mode"
    ./board_test.fpga
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        55) 

echo "###########################################################################################"
echo "#################### Generate Simulation files for Unit Test  #############################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR/ofs-common/scripts/common/sim
    sh gen_sim_files.sh $ADP_PLATFORM
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/ofs-common/scripts/common/sim 
    sh gen_sim_files.sh $ADP_PLATFORM
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        56) 

echo "###########################################################################################"
echo "#################### Simulate Unit Test ###################################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $OFS_ROOTDIR/sim/unit_test/$UNIT_TEST_NAME
    sh run_sim.sh $SIMULATION_TOOL_UNIT_TEST=1
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $OFS_ROOTDIR/sim/unit_test/$UNIT_TEST_NAME
    sh run_sim.sh $SIMULATION_TOOL_UNIT_TEST=1
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        57) 

echo "###########################################################################################"
echo "#################### Check UVM software versions for ADP Project ##########################"
echo "###########################################################################################"
echo ""
echo "DESIGNWARE_HOME is set to $DESIGNWARE_HOME"
echo ""
echo "UVM_HOME  is set to $UVM_HOME"
echo ""
echo "VCS_HOME is set to $VCS_HOME"
echo ""
echo "VERDIR is set to $VERDIR"
echo ""
echo "VIPDIR is set to $VIPDIR"
echo ""

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        58) 

echo "###########################################################################################"
echo "#################### Compile UVM IP #######################################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk clean
    echo ""
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk cmplib_adp
    cd $IOFS_BUILD_ROOT
      
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk clean
    echo ""
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk cmplib_adp
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        59) 

echo "###########################################################################################"
echo "#################### Compile UVM RTL and Testbench ########################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk build_adp DUMP=1
    cd $IOFS_BUILD_ROOT
     
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk build_adp DUMP=1
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        60) 

echo "###########################################################################################"
echo "#################### Simulate UVM Test ####################################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk run TESTNAME=$UVM_TEST_NAME DUMP=1 
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $VERDIR/scripts
    gmake -f Makefile_${SIMULATION_TOOL_UVM}.mk run TESTNAME=$UVM_TEST_NAME DUMP=1 
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        61) 

echo "###########################################################################################"
echo "#################### Simulate UVM Test (Regression Mode) ##################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then

    cd $VERDIR/scripts
    python uvm_regress.py -l -n 8 -p adp -k top_pkg -s vcs -c none 
    cd $IOFS_BUILD_ROOT
    
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    cd $VERDIR/scripts
    python uvm_regress.py -l -n 8 -p adp -k top_pkg -s vcs -c none
    cd $IOFS_BUILD_ROOT
  
else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        62) 

echo "###########################################################################################"
echo "#################### Build and Simulate Complete Project ##################################"
echo "###########################################################################################"
echo ""

if [ $ADP_PLATFORM == "n6001" ]

  then
  
    echo "Building and Simulating Complete $ADP_PLATFORM Project"
    test_number=62
    intectiveprum=2
 
elif [ $ADP_PLATFORM == "nXXXX" ]

  then

    echo "Building and Simulating Complete $ADP_PLATFORM Project"
    test_number=62
    intectiveprum=2

else
 
  echo "None of the conditions met"

fi

echo "Generating Log File with date and timestamp"
echo "Log file written to $LOG_FILE"

cd $IOFS_BUILD_ROOT

echo ""
date
echo "" ; press_enter ;;

        0 ) return ;;
        * ) echo "Please enter 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62 or 0"; press_enter
    esac
done
