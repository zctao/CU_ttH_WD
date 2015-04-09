#
# A prototype framework/working directory to perform CMS ttbarH analysis.
#
# Goal: to be used as a common carcass for Cornell CMS (ttH) group.
#


Usage:
1. Load the packages and CMS environment (in bash):
	$. setup.sh

2. Run the analyzer (a particular CMSSW package checked out with 1.):
	$. run_analyzer.sh


Additional details on Usage:
1. Checks out CMSSW, downloads needed packages, and compiles everything
into a working environment. A log file for stdout is produced (default:
setup.log).

2. An analyzer is a particular CMSSW plugin that has dependencies on
several other shared and nonshared libraries. It is suppose to have
dependencies on Configs, Inputs, and produce results in Outputs directories.
A log file for stdout&stderr is produced (default: run_analyzer.log).


Working directory structure:
* Configs: a directory to store run configs in YAML format. All the run
parameters/constants are supposed to be stored here in appropriate configs.

* Inputs: a directory to store input files needed for execution, like datacards,
data containers, custom partonic densities, etc.

* Outputs: a directory to store results.

* Setup_modules: a directory containing scripts needed to set up the
environment.

* Utilities: a directory for various custom scripts and tools (a place for
potentially "dirty" code).