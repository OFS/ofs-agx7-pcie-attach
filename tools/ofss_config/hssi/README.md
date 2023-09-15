# OFSS Config Tool: HSSI

## Overview
- This directory contains example HSSI OFSS Configuration Files
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md


### Board Specific Recommendations
- The following data rates have been tested, and therefore recommended, for reference boards: `10GbE`, `25GbE`, `100GCAUI-4` and `100GAUI-2`
- For `10GbE`, number of channels should not exceed 16
- For `25GbE`, number of channels should not exceed 8
- For `100GCAUI-4`, number of channels should not exceed 4
- For `100GAUI-4`, number of channels should not exceed 4

## Configurable Parameters
- `num_channels`: integer
- `data_rate` :  `10GbE`, `25GbE`, `100GCAUI-4` and `100GAUI-2`


```
[ip]
type = hssi

[settings]
output_name = hssi_ss
num_channels = 8
data_rate = 25GbE

```


