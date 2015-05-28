#
# A prototype framework/working directory to perform CMS ttbarH analysis.
#
## Goal: to be used as a common carcass for Cornell CMS (ttH) group.
#


get with

	$ git clone https://github.com/odysei/CU_ttH_WD


### Packages needing setup

Setup usage:

* Load the packages and the CMS SW environment (in bash):

	$ . setup.sh TASK


Additional details on Setup usage:

* Checks out CMSSW, downloads needed packages, and compiles everything
into a working environment. A log file for stdout is produced (default:
setup.log). If no TASK has been provided, a list of choices will be
printed out.


**Analyzer** usage (after ". setup.sh analyzer"):

* Run the analyzer (a particular CMSSW package):

	$ . run_analyzer.sh


Additional details on Analyzer usage:

* An analyzer is a particular CMSSW plugin that has dependencies on
several other shared and nonshared libraries. It is suppose to have
dependencies on Configs, Inputs, and produce results in Outputs directories.
A log file for stdout&stderr is produced (default: run_analyzer.log).


### Working directory structure
* **Configs**: a directory to store run configs in YAML format. All the run
parameters/constants are supposed to be stored here in appropriate configs.

* **Inputs**: a directory to store input files needed for execution, like datacards,
data containers, custom partonic densities, etc.

* **Outputs**: a directory to store results.

* **Setup_modules**: a directory containing scripts needed to set up the
environment.

* **Utilities**: a directory for various custom scripts and tools (a place for
potentially "dirty" code).


### Some of the **Utilities**
* batch_cluster.py: a helper program to automatically set sumbission
directories and their content. It is configurable (reference config:
Configs/batch_cluster_reference.yaml) and runs a given submission packet
maker. Passes ['projects_name', 'job_number'] to a main() of a specified maker.