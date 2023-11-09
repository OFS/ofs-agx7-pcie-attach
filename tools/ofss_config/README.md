# OFSS Config Tool

## Overview
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md
- This directory only contains template OFSS files relevant to this platform.

### OFSS File Structure
#### "[include]" Section
Each element (separated by newline) under this section should be a path to an OFSS file to be included for configuration by the OFSS Config tool.  Please ensure any enviironment variables (ex: $OFS_ROOTDIR) is properly set up.  The OFSS Config tool uses a breadth first search method to include all the OFSS necessary files.  OFSS files ordering should not matter. 

#### "[ip]" Section
This section contains a key value pair that allows the OFSS Config tool to determine which IP configuration is being passed in.  With current release, the supported values of IP are `ofss`, `iopll`, `pcie`, `memory`, `hssi`.

#### "[settings]" Section
This section contains IP specific settings.  Please refer to an existing IP OFSS file to see what IP settings are set.  For the IP type "ofss", the settings will be information of the OFS device (platform, family, fim, part #, device_id)

#### "\<platform\>.ofss" vs "\<platform\>_base.ofss"
`<platform>.ofss` is the platform level OFSS wrapper file.  It contains only an `include` section on all the various OFSS files that are part of the design. `<platform>_base.ofss` should contain board specific information. 

