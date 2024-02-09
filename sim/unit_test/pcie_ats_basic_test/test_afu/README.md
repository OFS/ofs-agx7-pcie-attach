# PCIe Address Translation Basic Test

This full AFU tests a few PCIe ATS patterns through the FIM:

* Assign a PASID to port
* Request translation from virtual to physical using PCIe ATS
* Generate a page request for a VA
* Read from a physical address
* Respond to ATS invalidation

The test can be run as a normal unit test, driven by the BFM. It is also structured like a normal AFU that can be configured for simulation with afu\_sim\_setup or synthesis with afu\_synth\_setup. It is expected to work on ASE and on HW that supports PASID. The program in the [sw](sw) tree can drive both ASE and HW.
