# OFS Agilex 7 PCIe Attach FPGA Development Directory

This is the OFS Agilex 7 PCIe Attach FPGA development top-level directory. This repository supports targetting the same design to multiple board configurations specified in **syn/board/<board_name>** folder.

## Cloning this repository

*NOTE:* This repository uses [Git LFS](https://git-lfs.com/) to capture large files in the history without forcing the download of historic files during a plain `clone` operation. Please follow your preferred installation method [from the project's guide](https://github.com/git-lfs/git-lfs#installing) before proceeding. After installation, run `git lfs install` once to install hooks which will transparently fetch the large files into your workspace for use.

To fetch both the `FIM` and `ofs-common` files in a single step, run the following command:

   `git clone --recurse-submodules https://github.com/OFS/ofs-agx7-pcie-attach.git`

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
   - Compiling the fseries-dk design requires .ofss for changing the .ip configuration
    ```bash
        ./ofs-common/scripts/common/syn/build_top.sh -p --ofss tools/ofss_config/fseries-dk.ofss fseries-dk work_fseries-dk
    ```

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
