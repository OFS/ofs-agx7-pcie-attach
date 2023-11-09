# OFS Agilex 7 PCIe Attach FPGA Development Directory

This is the OFS Agilex 7 PCIe Attach FPGA development top-level directory. This repository supports targetting the same design to multiple board configurations specified in **syn/board/<board_name>** folder.

## Board
* n6001 
   - Default .ip parameters are based on n6001 design
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p n6001 work_n6001
    ```
   - Additionally, n6001 fim supports reconfiguring the .ip via .ofss flow. For
     example to change hssi config, pass the .ofss files below. 
    ```bash
        # n6001 with 2x100G 
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/n6001_base.ofss,tools/ofss_config/hssi/hssi_2x100.ofss n6001 work_n6001_2x100

        # n6001 with 8x10G 
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/n6001_base.ofss,tools/ofss_config/hssi/hssi_8x10.ofss n6001 work_n6001_8x10

    ```
* fseries-dk
   - Compiling the fseries-dk Ethernet 8x25G  design configuration requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/fseries-dk.ofss,tools/ofss_config/hssi/hssi_8x25_ftile.ofss fseries-dk work_fseries-dk
    ```
  
* n6000
   - Compiling the n6000 variant design requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/n6000.ofss n6000 work_n6000
    ```

* iseries-dk
   - Compiling the iseries-dk design requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_8x25_ftile.ofss iseries-dk work_iseries-dk
    ```
	```
   - Compiling the iseries-dk for Ethernet 200G design configuration requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_2x200_ftile.ofss iseries-dk work_iseries-dk_200
    ```
   - Compiling the iseries-dk Ethernet 400G design configuration requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/iseries-dk.ofss,tools/ofss_config/hssi/hssi_1x400_ftile.ofss iseries-dk work_iseries-dk_400

## Directories

### Evaluation Scripts (***eval\_scripts***)
   - Contains resources to report and setup development environment.
### External Tools (***external***)
   - Contains the software repositories needed for OFS/OPAE development and integration. 
   - Lightweight virtual environment containing the required Python packages needed for this repo and its tools.
### IP Subsystems (***ipss***)
   - Contains the code and supporting files that define or set up the IP subsystems contained in the FPGA Interface Manager (FIM)
### Licensing for Quartus (***license***)
   - Contains the license setup software for the version of Quartus used for this distribution/release.
### OFS Common Content Directory (**Link to top-level directory _ofs-common_**)
   - Contains the scripts, source code, and verification environment resources that are common to all of the repositories.
   - This directory is referenced via a link within each of the FPGA-Specific repositories.
### Simulation
   - Contains the testbenches and supporting code for all of the unit test simulations.
      - Bus Functional Model code is contained here.
      - Scripts are included for automating a myriad of tasks.
      - All of the individual unit tests and their supporting code is also located here.
### FPGA Interface Module (FIM) Source code (***src***)
   - This directory contains all of the structural and behavioral code for the FIM.
   - Also included are scripts for generating the AXI buses for module interconnect.
   - Top-level RTL for synthesis is located in this directory.
   - Accelerated Functional Unit (AFU) infrastructure code is contained in this directory.
### FPGA Synthesis
   - This directory contains all of the scripts, settings, and setup files for running synthesis on the FIM.
### OFSS Configuration Tool (***tools***)
   - This directory contains the shell and Python scripts that form the OFSS configuration tool.

   Please see the following file for more information on this block

* [OFSS Configuration Tool README](tools/ofss_config/README.md)

### Verification (UVM) (***verification***)
   - This directory contains all of the scripts, testbenches, and test cases for the supported UVM tests for the FIM.
   - **NOTE:** UVM resources are currently not available in this release due to difficulties in open-sourcing some components.  It is hoped that this will be included in future releases.
