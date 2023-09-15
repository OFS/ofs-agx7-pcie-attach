#set QSYS_SIMDIR $env(WORKDIR)/sim/scripts/qip_sim_script
#set QSYS_SIMDIR $env(WORKDIR)/sim/scripts/qip_sim_script
cd $env(WORKDIR)/sim/scripts/qip_sim_script/mentor
# Source the generated sim script
#source msim_setup.tcl
source  $env(WORKDIR)/sim/scripts/qip_sim_script/mentor/msim_setup.tcl
# # Compile eda/sim_lib contents first
 dev_com
# # Compile the standalone IP.
com
# # Report success to the shell
#elab
ld_debug
quit -f
# exit -code 0
# # End of template

