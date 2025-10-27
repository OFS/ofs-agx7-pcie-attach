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
echo "Update repo with: git pull"
git pull
echo ""
echo "Running Setup Script:"
echo "OFS_ROOTDIR is --> ${OFS_ROOTDIR}"
source ${OFS_ROOTDIR}/../env_not_shipped/n6001/setup.sh
export REG_LOCAL_ROOT_DIR_PATH=${OFS_ROOTDIR}/sim/regtest/scripts
echo "REG_LOCAL_ROOT_DIR_PATH now set to: ${REG_LOCAL_ROOT_DIR_PATH}"
export REG_LOCAL_REG_PYTHON_DIR_PATH=${OFS_ROOTDIR}/sim/unit_test/scripts
echo "REG_LOCAL_ROOT_DIR_PATH now set to: ${REG_LOCAL_ROOT_DIR_PATH}"
echo "Going to RegTest Script Directory:"
echo "cd ${REG_LOCAL_ROOT_DIR_PATH}"
cd ${REG_LOCAL_ROOT_DIR_PATH}
echo ""
echo "Running Regression Test Script: python regress_run.py -g"
# echo "Running Regression Test Script: python regress_run.py -g -k fme"
# echo "Running Regression Test Script: python regress_run.py -k fme"
cd ${REG_LOCAL_REG_PYTHON_DIR_PATH}
# The below "regress_run.py -k fme" call will not update the simulation libraries and only generates the FME tests.
# The below "regress_run.py -g -k fme" call *will* update the simulation libraries and only generates the FME tests.
# This is done for testing and will shorten the run time by several hours.
python regress_run.py -g
# python regress_run.py -k fme
# python regress_run.py -g -k fme
echo ""
echo "Running copy manager script: perl copy_manager.pl"
cd ${REG_LOCAL_ROOT_DIR_PATH}
perl copy_manager.pl
echo ""
# echo "Running RegTest: reg_exe --localr"
echo 'Running RegTest: reg_exe --farm --title="OFS-Sim-Unit-Test"'
cd ${REG_LOCAL_ROOT_DIR_PATH}
reg_reset
# Use the --localr command for debug purposes and the --farm version for usual regression runs.
# reg_exe --localr
reg_exe --farm --title="OFS-Sim-Unit-Test"
