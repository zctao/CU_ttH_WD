#!/bin/bash

###############################################################
###############################################################
##
## Script checks and sets up YAML package and environment
##
###############################################################
###############################################################


## Script's parameters
#####################

PyYAML_PATH=PyYAML
PyYAML_LINK=http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
PyYAML_TAR=PyYAML-3.11.tar.gz
START_DIR=${PWD}

#####################


# Try out loading up yaml
python -c "import yaml" > /dev/null 2>&1


# Try out loading up yaml from a "default" path
if [ $? -ne 0 ] && [ -d ${PyYAML_PATH}/lib/*/site-packages/ ]; then
	# try loading up an existing path
	cd ${PyYAML_PATH}/lib/*/site-packages/
	YAML_PATH=${PWD}
	cd ${START_DIR}

	export PYTHONPATH=${YAML_PATH}:${PYTHONPATH}

	# Try out loading up yaml with a given path
	python -c "import yaml" > /dev/null 2>&1
fi


# Try out loading up yaml. Again
python -c "import yaml" > /dev/null 2>&1


# Check if python suceeded loading up yaml.
# If failed, download and prepare yaml.
if [ $? -ne 0 ]; then
	## A downloaded source cleaner
	clean_PyYAML()
	{
		cd ${START_DIR}
		rm -f ${PyYAML_TAR}
		rm -rf `echo ${PyYAML_TAR} | sed "s:.tar.gz::"`
	}
	trap clean_PyYAML EXIT

	wget ${PyYAML_LINK} 2>&1
	tar -xf ${PyYAML_TAR}
	cd `echo ${PyYAML_TAR} | sed "s:.tar.gz::"`
	
	python setup.py --without-libyaml install --prefix=${START_DIR}/${PyYAML_PATH}

	cd ../
	cd ${PyYAML_PATH}/lib/*/site-packages/
	YAML_PATH=${PWD}
	cd ${START_DIR}
	
	export PYTHONPATH=${YAML_PATH}:${PYTHONPATH}
	
	# If nothing has killed the script, run the cleaner manually
	clean_PyYAML
fi


# Try out loading up yaml. Again
python -c "import yaml" > /dev/null 2>&1

# Check if python suceeded loading up yaml. Again
if [ $? -ne 0 ]; then
	echo "ERROR: Problems in setting up PyYAML. A manual intervention is needed!" 1>&2
fi