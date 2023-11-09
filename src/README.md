# N6001 Source Code Directory

This directory contains the source code specific to the N6001 FIM.  The complete set of source code needed to build the N6001 FIM will include code from the following:
   - The N6001 Source Code Directory (this directory) (***.***)
   - The OFS-Common directory (***../ofs-common***)
   - The N6001 IP Subsystem directory (***../ipss***)
   - More information may be found in the N6001 top-level README file at:
* [N6001 Repo Main README](../README.md) Contains the top-level description for the directories in the N6001 repository.

## Directories

### Accelerated Functional Unit (AFU) Top (***./afu\_top***)
   - Resources in this directory support the AFU top level which joins the user's accelerated function/application and the FPGA Interface Manager (FIM).
   - Contains:
      - Control and Status Register (CSR) definitions are contained in the top directory which has full-register definitions, bit-field definitions, and individual-bit definitions where applicable.
      - AFU top-level wrapper RTL is contained in the top directory and the subdirectory ***./afu\_top/pd***.  In addition, some support files such as Tcl and shell scripts are included for configuring the subsystems.
      - MUX configuration packages are contained in the subdirectory ***./afu\_top/mux***.  Supporting MUX/DEMUX logic is also included in the main directory.
### Includes (***./includes***)
   - Parameter definitions and packages used for the N6001 FIM configuration reside in this directory.
### Platform Designer (PD) Qsys (***./pd\_qsys***)
   - N6001-specific subsystems created with Platform Designer exist in this directory.
   - Contains:
      - Bus Connection Fabric (***./pd\_qsys/fabric***)
         - This is the connection fabric stitching together the various memory-mapped resources inside the FIM.
   - Please consult the following README file for more detailed information:
* [Platform Designer/Qsys Contents README](pd_qsys/fabric/README.md) Contains detailed information on the directory structure as well as the instructions for configuring and generating the memory-mapped bus fabric:
      - AFU Peripheral Fabric (APF)
      - Board Peripheral Fabric (BPF)
### Top-level RTL and Resource (***./top***)
   - This directory contains the top-level RTL which provides the overall structure of the FIM.
   - Also included is the reset controller for the FIM.

