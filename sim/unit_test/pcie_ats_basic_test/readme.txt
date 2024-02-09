## Copyright 2021 Intel Corporation
## SPDX-License-Header: MIT
***Test Description***
This is a basic test of PCIe ATS messages and ATS invalidation handling.

PCIe ATS must be enabled in the FIM Quartus project being simulated. If ATS
is not enabled the test will pass but do nothing.

The FIM has an ATS invalidation handler that generates responses for AFUs that
are not holding address translations. The test begins by sending an inval to each
AFU in the port gasket and confirms that the FIM responds. It then requests ATS
translations on each port and confirms they are successful. After that, more
ATS invalidations are sent and the test confirms that the AFUs see them and
respond -- not the FIM.

Description of test modules:
   * test_csr_defs.sv   - Defines CSR addresses used in the test. 
   * unit_test.sv       - Defines the unit test procedure for the respective test.
   * set_params.sh      - Defines to run the test.
   * test_afu           - AFU implementation (instead of the default exercisers)

***Running the test***
 Follow steps in $OFS_ROOTDIR/sim/readme.txt with TEST=pcie_ats_basic_test
