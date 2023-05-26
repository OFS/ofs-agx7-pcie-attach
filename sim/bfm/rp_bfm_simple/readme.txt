#//Copyright 2022 Intel Corporation.
#// SPDX-License-Identifier: MIT
#
***Description***
This folder hosts the common top level testbench, BFMs and IP module to enable CoreFIM unit testing.

File description:
   * top_tb.sv          - Testbench top level module where DUT is instantiated
   * tester.sv          - Main test module which kicks off all the test cases and verify test results.
   * pcie_top.sv        - PCIe BFM with tester functionality  
   * pcie_csr.sv        - PCIe CSR   
   * shmem.sv           - Root port shared memory BFM
   * ready_gen.sv       - Generate random backpressure signal
   * packet_sender.sv   - Helper module to send TLP packets to downstream modules
   * packet_receiver.sv - Helper module to receive TLP packets from downsteram modules
   * test_pcie_utils.sv - Defines utility tasks to create PCIe TLP packets
   * tester_utils.sv    - Defines utility tasks to create, send and receive TLP packets
   * test_utils.sv      - Defines utility tasks to log test status
