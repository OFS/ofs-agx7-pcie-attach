#!/bin/bash
# Copyright (C) 2020-2023 Intel Corporation
# SPDX-License-Identifier: MIT

SCRIPTNAME="$(basename -- "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd -P)"

# cleanup after qsys-generate 
cleanup()
{
   find . -name synth -exec rm -rf {} \;
   find . -name aldec -exec rm -rf {} \;
   find . -name cadence -exec rm -rf {} \;
   find . -name xcelium -exec rm -rf {} \;
   find . -name ncsim_files.tcl -exec rm -rf {} \;
   find . -name riviera_files.tcl -exec rm -rf {} \;
   find . -name xcelium_files.tcl -exec rm -rf {} \;
   find . -name aldec_files.txt -exec rm -rf {} \;
   find . -name cadence_files.txt -exec rm -rf {} \;
   find . -name *_bb.v -exec rm -rf {} \;
   find . -name *.cmp -exec rm -rf {} \;
   find . -name *.csv -exec rm -rf {} \;
   find . -name *.html -exec rm -rf {} \;
   find . -name *_inst.v -exec rm -rf {} \;
   find . -name *_inst.vhd -exec rm -rf {} \;
   find . -name *.qgsimc -exec rm -rf {} \;
   find . -name *.qgsynthc -exec rm -rf {} \;
   find . -name *.rpt -exec rm -rf {} \;
   find . -name *.qip -exec rm -rf {} \;
   find . -name *.sopcinfo -exec rm -rf {} \;
   find . -name *.xml -exec rm -rf {} \;
   find . -name *.ppf -exec rm -rf {} \;
   find . -name *.bsf -exec rm -rf {} \;   
}

PROJECT=ofs_top
SCRIPT_PATH="$OFS_ROOTDIR/ofs-common/src/common/lib/axi4lite/"
TOOLS_PATH="$OFS_ROOTDIR/ofs-common/tools/fabric_generation"
#set -xe

# Clean up old generated files
rm -rf *.qsys apf.tcl bpf.tcl *.qpf *.qsf ip.ipx hw_ip.iipx sw_ip.iipx gen_fabrics.log


# Create ipx file for IP component(s) that will be instantiated in BPF/APF Qsys fabric
if $QUARTUS_HOME/../qsys/bin/ip-make-ipx --source-directory=$SCRIPT_PATH --output=ip.ipx >>gen_fabrics.log 2>>gen_fabrics.log; then
    echo "PASS: STAGE ip.ipx generation" | tee -a gen_fabrics.log
else
    echo "Error: STAGE ip.ipx generation! Check gen_fabrics.log" | tee -a gen_fabrics.log
fi

# Generate Fabric Qsys scripts using txt file as input
# Generate APF Fabric Qsys scripts 
python3 $TOOLS_PATH/fabric_gen.py --fabric_def apf.txt --fabric_name apf --tcl apf.tcl | tee -a gen_fabrics.log

# Generate BPF Fabric Qsys scripts 
python3 $TOOLS_PATH/fabric_gen.py --fabric_def bpf.txt --fabric_name bpf --tcl bpf.tcl | tee -a gen_fabrics.log 

echo "PASS: STAGE tcl generation for fabrics" | tee -a gen_fabrics.log


# Create apf.qsys interconnect fabric
if $QUARTUS_HOME/sopc_builder/bin/qsys-script --new-quartus-project=$PROJECT --script=apf.tcl >>gen_fabrics.log 2>>gen_fabrics.log; then
    echo "PASS: STAGE apf.tcl to apf.qsys generation" | tee -a gen_fabrics.log
else
    echo "Error: STAGE apf.qsys generation failed! Check gen_fabrics.log" | tee -a gen_fabrics.log
    exit 1
fi

# Create bpf.qsys interconnect fabric
if $QUARTUS_HOME/sopc_builder/bin/qsys-script -qpf=$PROJECT --script=bpf.tcl >>gen_fabrics.log 2>>gen_fabrics.log; then
    echo "PASS: STAGE bpf.tcl to bpf.qsys generation" | tee -a gen_fabrics.log
else
    echo "Error: STAGE bpf.qsys generation failed! Check gen_fabrics.log" | tee -a gen_fabrics.log
    exit 1
fi

# Generate apf.qsys
if $QUARTUS_HOME/sopc_builder/bin/qsys-generate -syn=VERILOG -sim=VERILOG -qpf=$PROJECT apf.qsys >>gen_fabrics.log 2>>gen_fabrics.log; then
    echo "PASS: STAGE apf.qsys RTL generation" | tee -a gen_fabrics.log
else
    echo "Error: STAGE apf.qsys RTL generation! Check gen_fabrics.log" | tee -a gen_fabrics.log
fi

# Generate bpf.qsys
if $QUARTUS_HOME/sopc_builder/bin/qsys-generate -syn=VERILOG -sim=VERILOG -qpf=$PROJECT bpf.qsys >>gen_fabrics.log 2>>gen_fabrics.log; then
    echo "PASS: STAGE bpf.qsys RTL generation" | tee -a gen_fabrics.log
else
    echo "Error: STAGE bpf.qsys RTL generation! Check gen_fabrics.log" | tee -a gen_fabrics.log
fi

sh "${OFS_ROOTDIR}/ofs-common/tools/fabric_generation/gen_fabric_width_pkg.sh"

# Clean up generated folder
cleanup >/dev/null 2>&1

echo "PASS: STAGE APF and BPF Fabric generation" | tee -a gen_fabrics.log
