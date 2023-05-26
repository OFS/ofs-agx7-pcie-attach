# N6001 FPGA Development Directory

This is the OFS N6001 Agilex FPGA development top-level directory.

## Directories

### Evaluation Scripts (***eval\_scripts***)
   - Contains resources to report and setup N6001 development environment.
### External Tools (***external***)
   - Contains the software repositories needed for OFS/OPAE development and integration. 
   - Lightweight virtual environment containing the required Python packages needed for this repo and its tools.
### IP Subsystems (***ipss***)
   - Contains the code and supporting files that define or set up the IP subsystems contained in the N6001 FPGA Interface Manager (FIM)
### Licensing for Quartus (***license***)
   - Contains the license setup software for the version of Quartus used for this distribution/release of the N6001 product.
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
### Physical Function/Virtual Function (PF/VF) Configuration Tool (***tools***)
   - This directory contains the shell and Python scripts that form the PF/VF configuration tool.

   Please see the following file for more information on this block

* [PF/VF Configuration Tool README](tools/pfvf_config_tool/README)

### Verification (UVM) (***verification***)
   - This directory contains all of the scripts, testbenches, and test cases for the supported UVM tests for the N6001 FIM.
   - **NOTE:** UVM resources are currently not available in this release due to difficulties in open-sourcing some components.  It is hoped that this will be included in future releases.
