# OFSS Config Tool: Memory

## Overview
- This directory contains example IOPLL OFSS Configuration Files
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md


### Board Specific Recommendations
- Memory configuration is currently done with `--preset` values
- Currently supported preset values are `n6001` and `f2000x` and `ftile-dev`


## Configurable Parameters
- `preset`: string

```
[ip]
type = memory

[settings]
output_name = mem_ss_fm
preset = n6001
```


