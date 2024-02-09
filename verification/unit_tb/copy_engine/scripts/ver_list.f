+incdir $VCS_HOME/etc/uvm-1.2/src
+incdir+$VERDIR/vip/axi_vip/include/verilog
+incdir+$VERDIR/vip/axi_vip/include/sverilog
+incdir+$VERDIR/vip/axi_vip/src/verilog/vcs
+incdir+$VERDIR/vip/axi_vip/src/sverilog/vcs
+incdir+$VERDIR/vip/pcie_vip/vip_seqinclude/verilog
+incdir+$VERDIR/vip/pcie_vip/include/sverilog
+incdir+$VERDIR/vip/pcie_vip/src/verilog/vcs
+incdir+$VERDIR/vip/pcie_vip/src/sverilog/vcs
+incdir+$VERDIR/tests/sequences/vip_seq
+incdir+$VERDIR/tests/sequences
+incdir+$VERDIR/tests
+incdir+$VERDIR/testbench
+incdir+$VERDIR/testbench/ral
+incdir+$VERDIR/testbench/tb_pcie
+incdir+$VERDIR/testbench/tb_pcie/src/verilog/vcs
+incdir+$OFS_ROOTDIR/ofs-common/verification/common/vip/include/
+incdir+$OFS_ROOTDIR/ofs-common/verification/common/vip/seq/
+incdir+$OFS_ROOTDIR/ofs-common/verification/common/vip/env/

-y $VERDIR/vip/pcie_vip/src/verilog/vcs
-y $VERDIR/vip/pcie_vip/src/sverilog/vcs
$VCS_HOME/etc/uvm-1.2/src/uvm_pkg.sv
$VERDIR/vip/axi_vip/include/sverilog/svt.uvm.pkg
$VERDIR/vip/axi_vip/include/sverilog/svt_axi.uvm.pkg
$VERDIR/vip/pcie_vip/include/sverilog/svt_pcie.uvm.pkg
#VERDIR/tests/test_pkg.svh
$OFS_ROOTDIR/ofs-common/verification/common/vip/include/synopsys_vip_defines.sv
$OFS_ROOTDIR/ofs-common/src/common/copy_engine/wrapper/pcie_wrapper_ce.sv
$VERDIR/testbench/tb_top.sv

