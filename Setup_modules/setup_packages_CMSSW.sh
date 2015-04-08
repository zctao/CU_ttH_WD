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
	
	#######################
	## Analyzers
	#######################
	
	# Set up Analyzers if it is missing
	if [ ! -d "${CMSSW_BASE}/src/Analyzers" ]; then
		git clone https://github.com/odysei/Analyzers
	fi

	if [ -d "${CMSSW_BASE}/src/Analyzers" ]; then
		echo "${CMSSW_BASE}/src/Analyzers is set."
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
		echo "${CMSSW_BASE}/src/MiniAOD is set."
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
		echo "${CMSSW_BASE}/src/BoostedTTH is set."
	else
		echo "ERROR: ${CMSSW_BASE}/src/BoostedTTH is NOT set." 1>&2
	fi
	
	
	scram b -j 24
	cd ${START_DIR}
else
	echo "ERROR: The CMSSW environment is not ready. Packages are not prepared." 1>&2
fi