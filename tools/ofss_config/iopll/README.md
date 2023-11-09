# OFSS Config Tool: IOPLL

## Overview
- This directory contains example IOPLL OFSS Configuration Files
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md


### Board Specific Recommendations
- Following frequencies have been tested on reference boards: 350MHz, 400MHz, 470MHz
- Recommended frequency range: 250-470MHz. 
- In OFSS file, frequency is specified in MHz.  (For example,  enter '470' as value)


## Configurable Parameters
- `freq`: integer (in MHz)

```
[ip]
type = iopll

[settings]
output_name = sys_pll
instance_name = iopll_0

[p_clk]
freq = 470
```


