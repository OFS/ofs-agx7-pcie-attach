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
## ofs-n6001	            (Contains FIM or shell RTL, automated compilation scripts, unit tests and UVM test framework)
## oneapi-asp	            (Contains the hardware and software components you need to develop your own OneAPI or OpenCL board support package for the Intel® Stratix 10® and Intel® Agilex® FPGAs)
## oneAPI-samples         (Samples for Intel® oneAPI Toolkits)
## opae-sdk	              (Contains the files for building and installing Open Programmable Acceleration Engine Software Development Kit from source)
## opae-sim	              (Contains the files for an AFU developer to build the Accelerator Funcitonal Unit Simulation Environment (ASE) for workload development)

#################################################################################################################################################################################
# To adapt this script to the user environment please follow the instructions below which explains which line numbers to change in the ofs_n6001_eval.sh script #################
#################################################################################################################################################################################
# User Directory Creation
# Create the top-level source directory and then clone Intel OFS repositories
mkdir ofs-2.3.1

In the example above we have used ofs-2.3.1 as the directory name

# Set-Up Proxy Server (lines 65-67)
# Please edit the lines indicated to add the location of your proxy server to allow access to external internet to build software packages
export http_proxy=
export https_proxy=
export no_proxy=

# License Files (lines 70-72)
# Please enter the the license file locations for the following tool variables
export LM_LICENSE_FILE=
export DW_LICENSE_FILE=
export SNPSLMD_LICENSE_FILE=

# Tools Location (line 83)
# ************** Set Location of Quartus and Synopsys Tools ***************** #
export TOOLS_LOCATION=/home
# ************** Set Location of Quartus and Synopsys Tools ***************** #

In the example above /home is used as the base location of Quartus and Synopsys tools

# Tools Location (line 85, 86, 87, 88)
# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #
export QUARTUS_TOOLS_LOCATION=/home
export SYNOPSYS_TOOLS_LOCATION=/home
export QUESTASIM_TOOLS_LOCATION=/home
export ONEAPI_TOOLS_LOCATION=/opt
# ************** Set Location of Quartus, Synopsys, Questasim and oneAPI Tools ***************** #

# Set OPAE Tools Version(line 106)
# ************** change OPAE SDK VERSION ***************** #
export OPAE_SDK_VERSION=2.5.0-1
# ************** change OPAE SDK VERSION ***************** #

In the example above "2.5.0-1" is used as the OPAE SDK tools version

# PCIe (Bus Number) (lines 231 and 238)
# The Bus number must be entered by the user after installing the hardware in the chosen server, in the example below "b1" is the Bus Number for a single card
export ADP_CARD0_BUS_NUMBER=b1

# Set BMC FLASH Image Version(RTL and FW) (line 395)
export BMC_RTL_FW_FLASH=AC_BMC_RSU_user_retail_3.2.0_unsigned.rsu

# The BMC firmware can be updated and the file name will change based on revision number. In the example above "AC_BMC_RSU_user_retail_3.2.0_unsigned.rsu" is the FW file used to update the BMC. 
# Please place the new flash file in the following newly created location $OFS_ROOTDIR/bmc_flash_files

#################################################################################
#################### AFU Set-up  ################################################
#################################################################################

# Testing Remote Signal Tap

after the building steps 17 and 18 from the script (ofs_n6001_eval.sh)

"17  - Build Partial Reconfiguration Tree for $ADP_PLATFORM Hardware with Remote Signal Tap"
"18  - Build Base FIM Identification(ID) into PR Build Tree template with Remote Signal Tap"

# Then to test the Remote Signal Tap feature for the host_chan_mmio example, copy the supplied host_chan_mmio.stp Signal Tap file to the following location
$IOFS_BUILD_ROOT

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
