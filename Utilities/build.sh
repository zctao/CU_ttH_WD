#!/bin/bash


## Script's parameters
######################

LOG_FILENAME=build.log
START_DIR=${PWD}


## Script's execution code
##########################

cd ${CMSSW_BASE}/src

scram b -j 24 > ${START_DIR}/${LOG_FILENAME}

cd ${START_DIR}
