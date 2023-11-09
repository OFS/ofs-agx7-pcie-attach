#set QSYS_SIMDIR $env(WORKDIR)/sim/scripts/qip_sim_script
#set QSYS_SIMDIR $env(WORKDIR)/sim/scripts/qip_sim_script
cd $env(WORKDIR)/sim/scripts/qip_sim_script/mentor
# Source the generated sim script
#source msim_setup.tcl
source  $env(WORKDIR)/sim/scripts/qip_sim_script/mentor/msim_setup.tcl
# # Compile eda/sim_lib contents first
#do /nfs/sc/disks/swuser_work_sajmal/ofs_ac_49/verification/n6000/base_x16_adp/scripts/qip/mentor/msim_setup.tcl USER_DEFINED_COMPILE_OPTIONS="+define+__ALTERA_STD__METASTABLE_SIM"
 dev_com
# # Compile the standalone IP.
com
# # Report success to the shell
#elab
ld_debug
quit -f
# exit -code 0
# # End of template

