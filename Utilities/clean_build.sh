#!/bin/bash


## Script's parameters
######################

LOG_FILENAME=build.log
START_DIR=${PWD}


## Script's execution code
##########################

cd ${CMSSW_BASE}

scram b clean > ${START_DIR}/${LOG_FILENAME}
scram b -j 24 >> ${START_DIR}/${LOG_FILENAME}

cd ${START_DIR}