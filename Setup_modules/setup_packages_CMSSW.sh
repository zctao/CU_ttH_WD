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

		# Switch to branch CMSSW_72X
		git checkout CMSSW_72X

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
		ln -s $CMSSW_RELEASE_BASE/src/RecoJets/JetProducers/plugins/VirtualJetProducer.h \
BoostedProducer/plugins/VirtualJetProducer.h
		ln -s $CMSSW_RELEASE_BASE/src/RecoJets/JetProducers/plugins/VirtualJetProducer.cc \
BoostedProducer/plugins/VirtualJetProducer.cc
		
		cd ${CMSSW_BASE}/src
		
		MAKE_CLEAN_BUILD=True
	else
		echo "ERROR: ${CMSSW_BASE}/src/BoostedTTH is NOT set." 1>&2
	fi
	
	
	#######################
	## BoostedTTH additions
	#######################

	# Set up BoostedTTH if it is missing
	if [ ! -d "${CMSSW_BASE}/src/PhysicsTools/JetMCAlgos" ]; then
		git cms-addpkg PhysicsTools/JetMCAlgos
	fi  

	if [ -d "${CMSSW_BASE}/src/PhysicsTools/JetMCAlgos" ]; then
		echo "${CMSSW_BASE}/src/PhysicsTools/JetMCAlgos is set. Updating."
		cd ${CMSSW_BASE}/src/PhysicsTools/JetMCAlgos
		git pull
		
		echo "Issuing BoostedTTH hacks"
		wget https://twiki.cern.ch/twiki/pub/CMSPublic/GenHFHadronMatcher/GenHFHadronMatcher.cc
		mv GenHFHadronMatcher.cc plugins/

		cd ${CMSSW_BASE}/src
		git cms-merge-topic gkasieczka:htt-v2-74X

		MAKE_CLEAN_BUILD=True
	else
		echo "ERROR: ${CMSSW_BASE}/src/PhysicsTools/JetMCAlgos is NOT set." 1>&2
	fi
	
	
	if [ ${MAKE_CLEAN_BUILD} ]; then
		scram b clean
	fi
	
	scram b -j 24
	cd ${START_DIR}
else
	echo "ERROR: The CMSSW environment is not ready. Packages are not prepared." 1>&2
fi
