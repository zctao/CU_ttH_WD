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

. Setup_modules/setup_CMSSW.sh > ${LOG_FILENAME}
. Setup_modules/setup_packages_CMSSW.sh >> ${LOG_FILENAME}
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


## Prepare GRID environment
voms-proxy-init -voms cms
