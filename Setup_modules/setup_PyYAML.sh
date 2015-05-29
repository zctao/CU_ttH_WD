#!/bin/bash

###############################################################
###############################################################
##
## Script checks and sets up PyYAML package and environment
##
###############################################################
###############################################################


## Script's parameters
######################

PyYAML_PATH=local
PyYAML_LINK=http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
PyYAML_TAR=PyYAML-3.11.tar.gz
START_DIR=${PWD}

######################

## Some functions
#################

## A downloaded source cleaner
clean_PyYAML()
{
	cd ${START_DIR}
	rm -f ${PyYAML_TAR}
	rm -rf `echo ${PyYAML_TAR} | sed "s:.tar.gz::"`
}


## Links contents of lib64 dir if it is used instead of lib
link_contents_lib64()
{
	cd ${START_DIR}
	if [ ! -e ${PyYAML_PATH}/lib/*/site-packages/yaml ]; then
		if [ -e ${PyYAML_PATH}/lib64/*/site-packages/yaml ]; then
				mkdir -p ${PyYAML_PATH}/lib
				cd ${PyYAML_PATH}/lib
				for item in `ls ../lib64`; do
						ln -s ../lib64/${item}
				done
		fi
	fi
}

#################


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
	trap clean_PyYAML EXIT
	
	wget ${PyYAML_LINK} 2>&1
	tar -xf ${PyYAML_TAR}
	cd `echo ${PyYAML_TAR} | sed "s:.tar.gz::"`
	
	python setup.py --without-libyaml install \
--prefix=${START_DIR}/${PyYAML_PATH}
	
	# if yaml is NOT inside lib
	link_contents_lib64
	
	cd ${START_DIR}/${PyYAML_PATH}/lib/*/site-packages/
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
