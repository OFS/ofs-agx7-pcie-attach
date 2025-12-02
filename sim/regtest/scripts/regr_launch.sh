#------------------------------------------------------------------------------
# This script acts as the launcher script for the OFS Unit Test Simulation
# Regression.  Using a crontab, this script is called after the environment is 
# set up with the script in "env_not_shipped/n6001/go_regtest.sh".
# This script does the following:
#    1.) An update of the repository is done with "git pull".
#    2.) The OFS setup script "setup.sh" is run into the environment.
#    3.) Directories are defined to direct execution to the Regtest scripts.
#    4.) The Python simulation regression script is then run to execute 
#        all the unit tests.
#    5.) After the simulation regression tests are run, then the copy manager 
#        Perl script sets up the RegTest directories in approprate places and 
#        then copies the simulation logs into the RegTest directory structure. 
#        These files are then used by the RegTest scripts to analyze and 
#        report the results via PERT/SPETC.
#    6.) The last act of this script is to invoke RegTest to run the analysis.
#------------------------------------------------------------------------------
COMMAND_LINE="git pull"
echo ""
echo "Update repo with: ${COMMAND_LINE}"
${COMMAND_LINE}
echo ""
echo "Running Setup Script:"
echo "OFS_ROOTDIR is --> ${OFS_ROOTDIR}"
source ${OFS_ROOTDIR}/../env_not_shipped/n6001/setup.sh
export REG_LOCAL_ROOT_DIR_PATH=${OFS_ROOTDIR}/sim/regtest/scripts
echo "REG_LOCAL_ROOT_DIR_PATH now set to: ${REG_LOCAL_ROOT_DIR_PATH}"
export REG_LOCAL_REG_PYTHON_DIR_PATH=${OFS_ROOTDIR}/sim/unit_test/scripts
echo "REG_LOCAL_REG_PYTHON_DIR_PATH now set to: ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
echo "Going to RegTest Script Directory:"
#----------------------------------------------------------------------------------------
# Go to RegTest directory first to set up "test_list" file before going to Python
# script directory and executing simulations.
#----------------------------------------------------------------------------------------
COMMAND_LINE="cd ${REG_LOCAL_ROOT_DIR_PATH}"
echo "${COMMAND_LINE}"
${COMMAND_LINE}
#----------------------------------------------------------------------------------------
# Here are some run options for running the Python Regression script.  The "-g" option
# is the one used during normal operations.  The others are provided for debug to shorten
# the length of the run which normally might take hours.
#----------------------------------------------------------------------------------------
# Options: "-g -k list" to generate simulation files for variant from RegTest list.
#          "-g -k fme" to generate simulation files and run shortened regression.
#          "-k fme" to skip generation of simulation files and run shortened regression.
#----------------------------------------------------------------------------------------
# PY_REGRESS_OPTION="-k fme"
PY_REGRESS_OPTION="-g -k list"
echo ""
case "${FIM_VARIANT_TARGET}" in
   "n6001")
      COMMAND_LINE="cp test_list_${FIM_VARIANT_TARGET} test_list"
      echo "Copying Test List: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      COMMAND_LINE="perl create_simlist.pl"
      echo "Creating Test List for Simulation Regression: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      echo "Going to Python Regression Script Directory:"
      COMMAND_LINE="cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
      echo "${COMMAND_LINE}"
      ${COMMAND_LINE}
      PY_REGRESS_CMD="python regress_run.py ${PY_REGRESS_OPTION} -b ${FIM_VARIANT_TARGET}"
      echo "Running Regression Test Script: ${PY_REGRESS_CMD}"
      ${PY_REGRESS_CMD}
      ;;
   "iseries-dk")
      COMMAND_LINE="cp test_list_${FIM_VARIANT_TARGET} test_list"
      echo "Copying Test List: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      COMMAND_LINE="perl create_simlist.pl"
      echo "Creating Test List for Simulation Regression: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      echo "Going to Python Regression Script Directory:"
      COMMAND_LINE="cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
      echo "${COMMAND_LINE}"
      ${COMMAND_LINE}
      PY_REGRESS_CMD="python regress_run.py ${PY_REGRESS_OPTION} -b ${FIM_VARIANT_TARGET} -o ${OFS_ROOTDIR}/tools/ofss_config/pcie/pcie_host_2link.ofss"
      echo "Running Regression Test Script: ${PY_REGRESS_CMD}"
      ${PY_REGRESS_CMD}
      ;;
   "iseries-dk_1x400")
      COMMAND_LINE="cp test_list_${FIM_VARIANT_TARGET} test_list"
      echo "Copying Test List: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      COMMAND_LINE="perl create_simlist.pl"
      echo "Creating Test List for Simulation Regression: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      echo "Going to Python Regression Script Directory:"
      COMMAND_LINE="cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
      echo "${COMMAND_LINE}"
      ${COMMAND_LINE}
      PY_REGRESS_CMD="python regress_run.py ${PY_REGRESS_OPTION} -b iseries-dk -o ${OFS_ROOTDIR}/tools/ofss_config/hssi/hssi_1x400_ftile.ofss"
      echo "Running Regression Test Script: ${PY_REGRESS_CMD}"
      ${PY_REGRESS_CMD}
      ;;
   "fseries-dk")
      COMMAND_LINE="cp test_list_${FIM_VARIANT_TARGET} test_list"
      echo "Copying Test List: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      COMMAND_LINE="perl create_simlist.pl"
      echo "Creating Test List for Simulation Regression: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      echo "Going to Python Regression Script Directory:"
      COMMAND_LINE="cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
      echo "${COMMAND_LINE}"
      ${COMMAND_LINE}
      PY_REGRESS_CMD="python regress_run.py ${PY_REGRESS_OPTION} -b ${FIM_VARIANT_TARGET}"
      echo "Running Regression Test Script: ${PY_REGRESS_CMD}"
      ${PY_REGRESS_CMD}
      ;;
   "mseries-dk")
      COMMAND_LINE="cp test_list_${FIM_VARIANT_TARGET} test_list"
      echo "Copying Test List: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      COMMAND_LINE="perl create_simlist.pl"
      echo "Creating Test List for Simulation Regression: ${COMMAND_LINE}"
      ${COMMAND_LINE}
      echo "Going to Python Regression Script Directory:"
      COMMAND_LINE="cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}"
      echo "${COMMAND_LINE}"
      ${COMMAND_LINE}
      PY_REGRESS_CMD="python regress_run.py ${PY_REGRESS_OPTION} -b ${FIM_VARIANT_TARGET} -o ${OFS_ROOTDIR}/tools/ofss_config/mseries-dk.ofss"
      echo "Running Regression Test Script: ${PY_REGRESS_CMD}"
      ${PY_REGRESS_CMD}
      ;;
   *)
      echo -e "Invalid FIM Variant Target Entered: ${FIM_VARIANT_TARGET}."
      exit -1
      ;;
esac
cd ${REG_LOCAL_ROOT_DIR_PATH}
COMMAND_LINE="perl copy_manager.pl"
echo ""
echo "Running copy manager script: ${COMMAND_LINE}"
${COMMAND_LINE}
echo ""
#----------------------------------------------------------------------------------------
# Use the --localr command for debug purposes and the --farm version for usual regression runs.
# COMMAND_LINE="reg_exe --localr"
COMMAND_LINE="reg_exe --farm --title=\"OFS-Sim-Unit-Test-${FIM_VARIANT_TARGET}\""
#----------------------------------------------------------------------------------------
echo "Running RegTest: ${COMMAND_LINE}"
${COMMAND_LINE}
