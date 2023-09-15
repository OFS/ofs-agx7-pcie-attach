# OFSS Config Tool: PCIe 

## Overview
- This directory contains example PCIe OFSS Configuration Files
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md

### Board Specific Recommendations

 - For reference FIM configurations, 0 virtual functions on PF0 is not supported. This is because
   the PRR region cannot be left unconnected. A NULL AFU may need
   to be instantiated in this special case. 
 - PFs must be consecutive

Agilex N6001 PCIe  ||  
------------- | -------------
Min # of PFs  | 1 (on PF0)
Max # of PFs  | 8
Min # of VFs | 1 on PF0
Max # of VFs | 2000 distributed across all PFs
Consecutive PFs | True  


### Examples
N6001 Default | |
------------- | -------------
\# of PFs  | 5 (PF0-4)
\# of VFs  | 3 (on PF0)

N6001 1PFVF | |
------------- | -------------
\# of PFs  | 1 (PF0)
\# of VFs  | 1 (on PF0)



## Configurable Parameters
- `[pf*]`: integer
- `num_vfs`: integer
- `bar0_address_width`: integer
- `bar4_address_width`: integer
- `vf_bar0_address_width`: integer
- `ats_cap_enable`: 0 or 1
- `prs_ext_cap_able`: 0 or 1
- `pasid_cap_enable`: 0 or 1


```
# pcie_host.ofss 

[ip]
type = pcie

[settings]
output_name = pcie_ss

[pf0]
num_vfs = 3
bar0_address_width = 20
vf_bar0_address_width = 20

[pf1]

[pf2]
bar0_address_width = 18

[pf3]

[pf4]

```


