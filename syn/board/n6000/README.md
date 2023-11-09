
# N6000 Reference Platform Variant 

* This directory consists of board specific setup and script files for n6000 FIM variant with following features 
* HSSI configured to 4x100G - 2 connected to Intel Ethernet Adapter E810 and 2 connected to QSFP on the board
* PCIe IP BAR0 PF0 VF space configured to 1GB. 
* This n6000 variant does not consist of the following - DDR4, HPS, UART and TOD.

## Compile Instructions  

### Running ofss\_config tool

n6000 FIM variant uses this ofss file which has the respective ofss files for different IPs for the specified configuration - 
$OFS\_ROOTDIR/tools/ofss\_config/n6000.ofss 


* To run the ofss\_config tool use the command  
python3 gen\_ofs\_settings.py --ofss $OFS\_ROOTDIR/tools/ofss\_config/n6000.ofss

### Synthesis
* Once the IPs are configured with required settings, use the following command  
./ofs-common/scripts/common/syn/build\_top.sh -p n6000 work\_n6000

* If you have not run ofss\_config tool, you can directly invoke it in the build command as follows 
./ofs-common/scripts/common/syn/build\_top.sh --ofss tools/ofss\_config/n6000.ofss -p n6000 work\_n6000


### Simulation filelist generation
*  Once the IPs are configured with required settings, use the following command 
   cd  $OFS\_ROOTDIR/ofs-common/scripts/common/sim
   Run the script "sh gen\_sim\_files.sh n6000"

* If you have not run ofss\_config tool, you can directly invoke it in the script as follows 
    cd  $OFS\_ROOTDIR/ofs-common/scripts/common/sim
    Run the script "sh gen\_sim\_files.sh --ofss $OFS\_ROOTDIR/tools/ofss\_config/n6000.ofss n6000 "




