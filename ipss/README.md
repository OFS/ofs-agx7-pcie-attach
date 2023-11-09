# IP Subsystem Directory

This directory contains the code and supporting files that define or set up the IP subsystems contained in the  FPGA Interface Manager (FIM)

## Directories

### High Speed Serial Interface (HSSI) Ethernet (***hssi***)
   - This directory contains the top-level description of the HSSI block and all of its supporting code.

### DDR4 Memory (***mem***)
   - This directory contains the top-level description of the DDR4 subsystem.
   - This directory also contains a lot of the settings regarding the physical interface management and PHY settings.

### Peripheral Component Interconnect Express (PCIe) Interface (***pcie***)
   - This directory contains the top-level description of the system's Peripheral Component Interconnect Express (PCIe) interface.
   - This is the main connection between the card and the host computer system.

### Platform Management Interface Controller (PMCI) (***pmci***)
   - This directory contains the top-level RTL block that connects one of the FPGA's AXI-Lite interfaces to its system controller via a SPI Bridge.

### Quad Small Form Factor Pluggable (QSFP) Serial Interface (***qsfp***)
   - This directory contains the top-level RTL and IP blocks for the QSFP interface.
   - A set of Control and Status Registers (CSRs) are also defined here.
      - The RTL defining these registers and their function is included here.
      - An Excel spreadsheet is also contained here that provides a better human-readable format describing the CSRs and their intended function.
