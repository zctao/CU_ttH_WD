#!/bin/bash

###############################################################
###############################################################
##
## Analyzer runner
##
###############################################################
###############################################################


## Script's parameters
######################

LOG_FILENAME=run_analyzer.log
START_DIR=${PWD}


## Script's execution code
##########################

# cmsRun adores stderr output, thus stdout&stderr are redirected to a log
cmsRun ${CMSSW_BASE}/src/Analyzers/ttH_analyzer/python/CU_ttH_EDA_cfg.py &> \
	${LOG_FILENAME}
