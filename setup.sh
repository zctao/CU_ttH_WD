#!/bin/bash

###############################################################
###############################################################
##
## Setup for the CU ttH analyzer suite.
##
###############################################################
###############################################################


## Script's parameters
######################

LOG_FILENAME=setup.log
START_DIR=${PWD}


## Script's execution code
##########################

TASK="$@"

if [ "${TASK}" = "analyzer" ]; then
	
	echo "Setting up an analyzer"
	. Setup_modules/setup_CMSSW.sh > ${LOG_FILENAME}
	. Setup_modules/setup_packages_CMSSW.sh >> ${LOG_FILENAME}
	
	cp Utilities/module_warehouse/analyzer/run_analyzer.sh .
	
	## Prepare GRID environment
	voms-proxy-init -voms cms
elif [ "${TASK}" = "environment" ]; then
	
	echo "Setting up an environment"
	. Setup_modules/setup_CMSSW.sh > ${LOG_FILENAME}
	
	## Prepare GRID environment
	voms-proxy-init -voms cms
elif [ "${TASK}" = "dummy" ]; then
	
	echo "A dummy placeholder."
else
	
	echo "Current choices are:"
	echo "analyzer environment dummy"
fi

#. Setup_modules/setup_YAML.sh >> ${LOG_FILENAME}

# # Make a portable archive for batch submissions
# if [ -d "${CMSSW_BASE}" ]; then
# 	cd ${CMSSW_BASE}/src/
# 	tar -czf CMSSW_portable_src.tar.gz *
# 	
# 	cd ${START_DIR}
# 	mv ${CMSSW_BASE}/src/CMSSW_portable_src.tar.gz .
# 	
# 	
# 	cd ${CMSSW_BASE}
# 	tar -czf CMSSW_portable_full.tar.gz *
# 	
# 	cd ${START_DIR}
# 	mv ${CMSSW_BASE}/CMSSW_portable_full.tar.gz .
# fi
