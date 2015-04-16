#!/bin/bash

###############################################################
###############################################################
##
## Script checks and sets up CMSSW packages
##
###############################################################
###############################################################


## Script's parameters
######################

START_DIR=${PWD}




## Script's execution code
##########################

# At this point CMSSW should be fine. Let us check.
if [ "${CMSSW_VERSION}" = "${CMSSW_VER_CHOICE}" ] && [ -d "${CMSSW_BASE}" ]; then
	cd ${CMSSW_BASE}/src
	
	MAKE_CLEAN_BUILD=False
	
	#######################
	## Analyzers
	#######################
	
	# Set up Analyzers if it is missing
	if [ ! -d "${CMSSW_BASE}/src/Analyzers" ]; then
		git clone https://github.com/odysei/Analyzers
	fi

	if [ -d "${CMSSW_BASE}/src/Analyzers" ]; then
		echo "${CMSSW_BASE}/src/Analyzers was set. Updating."
		cd ${CMSSW_BASE}/src/Analyzers
		git pull
		cd ${CMSSW_BASE}/src
		
		MAKE_CLEAN_BUILD=True
	else
		echo "ERROR: ${CMSSW_BASE}/src/Analyzers is NOT set." 1>&2
	fi
	
	
	#######################
	## MiniAOD helper
	#######################
	
	# Set up MiniAOD helper if it is missing
	if [ ! -d "${CMSSW_BASE}/src/MiniAOD" ]; then
		git clone https://github.com/cms-ttH/MiniAOD
	fi

	if [ -d "${CMSSW_BASE}/src/MiniAOD" ]; then
		echo "${CMSSW_BASE}/src/MiniAOD is set. Updating."
		cd ${CMSSW_BASE}/src/MiniAOD
		git pull
		cd ${CMSSW_BASE}/src
		
		MAKE_CLEAN_BUILD=True
	else
		echo "ERROR: ${CMSSW_BASE}/src/MiniAOD is NOT set." 1>&2
	fi
	
	
	#######################
	## BoostedTTH
	#######################
	
	# Set up BoostedTTH if it is missing
	if [ ! -d "${CMSSW_BASE}/src/BoostedTTH" ]; then
		git clone https://github.com/cms-ttH/BoostedTTH
	fi

	if [ -d "${CMSSW_BASE}/src/BoostedTTH" ]; then
		echo "${CMSSW_BASE}/src/BoostedTTH is set. Updating."
		cd ${CMSSW_BASE}/src/BoostedTTH
		git pull
		cd ${CMSSW_BASE}/src
		
		MAKE_CLEAN_BUILD=True
	else
		echo "ERROR: ${CMSSW_BASE}/src/BoostedTTH is NOT set." 1>&2
	fi
	
	
	if [ ${MAKE_CLEAN_BUILD} ]; then
		scram b clean
	fi
	
	scram b -j 24
	cd ${START_DIR}
else
	echo "ERROR: The CMSSW environment is not ready. Packages are not prepared." 1>&2
fi