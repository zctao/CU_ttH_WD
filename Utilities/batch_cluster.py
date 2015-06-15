#!/usr/bin/python

#
# Contains a submission_maker class, which is the core of the .py file.
#

import logging
import os
import re
import shutil
import subprocess
import sys
import yaml
#import ROOT


#cmssw_base = os.environ['CMSSW_BASE']
#current_dir = os.environ['PWD']



class submission_maker:
	"""class is intended to serve as a simple, generic, and easily configurable
	cluster submission maker. Each submission packet must be provided by an
	external tool, which is defined in 'project_config'."""
	
	## options are supposed to be updated by config file(s)
	options = {'my_name': 'batch_cluster',
		'config_file': 'Configs/batch_cluster_reference.yaml',
		'log_filename': 'batch_cluster.log',
		'log_vebosity': 'errors',
		'console_vebosity': 'errors',
		'submit_type': 'runtime',
		'submit_all_file': 'submit_all.run',
		'batch_executable': 'qsub',
		'allowed_maximum_jobs': 10000,
		'first_job_nr': 0,
		'last_job_nr': 10000,
		'job_config_src_path': 'Utilities/module_warehouse/batch_cluster/',
		'job_config_src_file': 'batch_PBS_default_config.job',
		'submission_dirnames': 'submission_',
		'place_submission_dirs_in': 'Outputs',
		'expected_run_duration': '20:00:00',
		'job_nodes': '1',
		'processors_per_node': '1',
		'job_memory': '1000mb',
		'project_input_path': 'Input/examples/batch_cluster/',
		'project_config': 'example.yaml',
		'project_name': 'cluster_run',
		'submission_maker': 'create_submission.py',
		'outputs_a_dir': False,
		'output_dir_name': 'submit',
		'output_files': ['test.dat', 'test.sh'],
		'executable': 'run_me.sh',
		'execute_as': 'bash',
		}
	
	
	def __init__(self, config):
		self.load_yaml_config(config)
		
		## Load a submission paket maker's config
		self.load_yaml_config_dependent(
			os.path.join(self.options['project_input_path'],
				self.options['project_config']))
		
		self.initialize_logger(self.options['log_filename'])
		
		self.__loaded_job_config_src = False
	
	
	### Methods follow below
	def load_yaml_config(self, input_config=None):
		"""Used to initialize a class using parameters from a config file"""
		
		if os.path.lexists(input_config):
			with open(input_config, 'r') as config_file:
				config = yaml.load(config_file)
			
			self.options['config_file'] = input_config
			
			self.options['project_input_path'] = config[
				"Generic"]["project_input_path"]
			self.options['project_config'] = config[
				"Generic"]["project_config"]
			self.options['log_filename'] = config[
				"Generic"]["log_filename"]
			self.options['log_vebosity'] = config[
				"Generic"]["log_vebosity"]
			self.options['console_vebosity'] = config[
				"Generic"]["console_vebosity"]
			
			self.options['batch_executable'] = config[
				"submission_specifics"]["batch_executable"]
			self.options['allowed_maximum_jobs'] = config[
				"submission_specifics"]["allowed_maximum_jobs"]
			self.options['first_job_nr'] = config[
				"submission_specifics"]["first_job_nr"]
			self.options['last_job_nr'] = config[
				"submission_specifics"]["last_job_nr"]
			self.options['job_config_src_path'] = config[
				"submission_specifics"]["job_config_src_path"]
			self.options['job_config_src_file'] = config[
				"submission_specifics"]["job_config_src_file"]
			self.options['submission_dirnames'] = config[
				"submission_specifics"]["submission_dirnames"]
			self.options['place_submission_dirs_in'] = config[
				"submission_specifics"]["place_submission_dirs_in"]
			self.options['expected_run_duration'] = config[
				"submission_specifics"]["expected_run_duration"]
			self.options['job_nodes'] = config[
				"submission_specifics"]["nodes"]
			self.options['processors_per_node'] = config[
				"submission_specifics"]["processors_per_node"]
			self.options['job_memory'] = config[
				"submission_specifics"]["memory"]
			
			self.options['submit_type'] = config[
				"execution_specifics"]["task_submission_type"]
			self.options['submit_all_file'] = config[
				"execution_specifics"]["multiple_submission_file"]
			
		else:
			raise RuntimeError, 'A config file {0} does not exist.'.format(
				input_config)
	
	
	def load_yaml_config_dependent(self, input_config=None):
		"""Used to read submission paket maker's config, which has common
		settings."""
		
		if os.path.lexists(input_config):
			with open(input_config, 'r') as config_file:
				config = yaml.load(config_file)
			
			self.options['project_name'] = config[
				"batch_cluster"]["project_name"]
			self.options['submission_maker'] = config[
				"batch_cluster"]["submission_maker"]
			self.options['outputs_a_dir'] = config[
				"batch_cluster"]["outputs_a_dir"]
			self.options['output_dir_name'] = config[
				"batch_cluster"]["output_dir_name"]
			self.options['output_files'] = config[
				"batch_cluster"]["output_files"]
			self.options['executable'] = config[
				"batch_cluster"]["executable"]
			self.options['execute_as'] = config[
				"batch_cluster"]["execute_as"]
			
			#Adjustments to names for local needs
			self.options['submission_maker'] = re.sub('.py', '',\
										self.options['submission_maker'])
			if not self.options['execute_as'] == './':
				self.options['execute_as'] += ' '
			
		else:
			raise RuntimeError, 'A config file {0} does not exist.'.format(
				input_config)
	
	
	def initialize_logger(self, log_filename):
		"""Loads a logger that is to be used by the class."""
		
		#if is_logger_initialized:
			#return 0
		
		log_existed = False

		if os.path.lexists(log_filename):
			log_existed = True
		
		# logging class format for both console and file outputs
		logging_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
		
		if self.options['console_vebosity'] == 'debug' or \
		   self.options['log_vebosity'] == 'debug':
			logging.basicConfig(format=logging_format,
								filename=log_filename,
								level=logging.DEBUG)
		else:
			logging.basicConfig(format=logging_format,
								filename=log_filename,
								level=logging.INFO)
		self.logger = logging.getLogger(self.options['my_name'])
		
		# console handler
		ch = logging.StreamHandler()
		if self.options['console_vebosity'] == 'errors':
			ch.setLevel(logging.ERROR)
		elif self.options['console_vebosity'] == 'warnings':
			ch.setLevel(logging.WARNING)
		elif self.options['console_vebosity'] == 'debug':
			ch.setLevel(logging.DEBUG)
		else:
			ch.setLevel(logging.INFO)
		
		# create formatter
		formatter = logging.Formatter(logging_format)
		
		## add formatter to ch and to a log
		ch.setFormatter(formatter)
		
		# add ch to logger
		self.logger.addHandler(ch)
		
		if log_existed:
			self.logger.warning('A log file {0} already exists. Appending.'.format(
									log_filename))
		
		#is_logger_initialized = True
	
	
	def make_submissions(self):
		"""Makes submissions based on provided config settings. Each
		submission packet is provided by an external code."""
		
		if not os.path.isfile(os.path.join(
						self.options['project_input_path'],
						'{0}.py'.format(self.options['submission_maker']))):
			raise RuntimeError, 'Submission maker does not exist!'
		
		## Dynamically load a provided submission-packet maker
		sys.path.append(self.options['project_input_path'])
		submission = __import__(self.options['submission_maker'], globals(),
								locals(), [], -1)
		
		## Easy to make string here. It is not necessarily used later
		src_dir = os.path.join(self.options['project_input_path'],
							   self.options['output_dir_name'])
		
		if self.options['submit_type'] == 'file':
			if os.path.lexists(self.options['submit_all_file']):
				self.logger.warning(
					'A submit file {0} already exists. Appending.'.format(
						self.options['submit_all_file']))
		
		## Make and move submissions packets to their execution place
		first = self.options['first_job_nr']
		last = self.options['last_job_nr'] + 1
		if last > (first + self.options['allowed_maximum_jobs']):
			last = first + self.options['allowed_maximum_jobs']
			self.logger.warning('Last job exceeds the maximum allowed' + \
				' number of jobs ({0}).\nNew last job: {1}.'.format(
					self.options['allowed_maximum_jobs'],
					first + self.options['allowed_maximum_jobs'] - 1))
		
		for it in xrange(first, last):
			if it == (last - 1):
				if it == (first + self.options['allowed_maximum_jobs'] - 1):
					self.logger.warning('Allowed maximum number of jobs' + \
						' reached: {0}.'.format(
							self.options['allowed_maximum_jobs']))
			
			status = self.__make_submission_packet(submission, src_dir, it)
			
			## Trying to close a cycle
			if status != submission.EXIT_SUCCESS:
				break
		
		return 0
	
	
	def __make_submission_packet(self, packet_maker, src_dir, it):
		## Produce a submission packet, read out status
		status = packet_maker.main([self.options['project_name'], it])
		
		if status != packet_maker.EXIT_SUCCESS:
			if status == packet_maker.EXIT_CYCLE_ENDED:
				self.logger.info('A last job has been reached. ' + \
					'Job number: {0}'.format(it))
			else:
				self.logger.error('An error in {0} occured. Error code {1}'.\
					format(self.options['submission_maker'], status))
				return status
		
		## Create a path string for a designated submission
		target_dir = os.path.join(self.options['place_submission_dirs_in'],
								  '{0}{1}{2}'.format(
									self.options['submission_dirnames'],
									self.options['project_name'],
									it))
		target_dir = os.path.join(os.getcwd(), target_dir)
		self.logger.info(target_dir)
		
		## Move produced submission packet to a designated location
		if self.options['outputs_a_dir']:
			shutil.move(src_dir, target_dir)
		else:
			if not os.path.exists(target_dir):
				os.makedirs(target_dir)
			for item in self.options['output_files']:
				src_file = os.path.join(self.options['project_input_path'],
										item)
				if not os.path.isfile(src_file):
					raise RuntimeError, 'File for submission {0} is missing'.\
						format(src_file)
				shutil.move(src_file, os.path.join(target_dir, item))
		
		## Put an execution script for a cluster system in a designated loc
		job_runner = os.path.join(target_dir,
								  '{0}{1}.job'.format(
									  self.options['project_name'], it))
		self.__put_job_runner(target_dir, it, job_runner)
		
		## Submit created jobs
		if self.options['submit_type'] == "runtime":
			subprocess.check_output([self.options['batch_executable'],
									job_runner])
			
		elif self.options['submit_type'] == "file":
			with open(self.options['submit_all_file'], "a") as sumbmit_all_file:
				sumbmit_all_file.write('{0} {1}\n'.format(
					self.options['batch_executable'], job_runner))
		
		return status
	
	
	def __put_job_runner(self, target_dir, job_nr, job_runner=None):
		"""Produces an actual submission file to be processed by a cluster
		job submission system. This file serves mostly as a run initializer
		and a settings file."""
		
		## Load a default source file for default job config
		if not self.__loaded_job_config_src:
			self.__load_job_config_src()
		
		execution_file = os.path.join(target_dir,
									  self.options['executable'])
		if not os.path.exists(execution_file):
			self.logger.error('Can\'t find {0}'.format(execution_file))
			sys.exit(1)
		
		### Create specialized files for jobs. Submit jobs
		job_config = self.__make_substitutes(target_dir,
											 job_nr,
											 self.job_config_src)
		
		out_file_job_config = open(job_runner ,"w")
			
		for item in job_config:
			out_file_job_config.write("{0}\n".format(item))
				
		out_file_job_config.close()
	
	
	def __load_job_config_src(self):
		"""Loads a default source file for default job config"""
		
		job_config_src_file = os.path.join(
			self.options['job_config_src_path'],
			self.options['job_config_src_file'])
		
		if not os.path.exists(job_config_src_file):
			self.logger.error('Can\'t find {0}'.format(job_config_src_file))
			sys.exit(1)
		
		with open(job_config_src_file) as inputfile:
			self.job_config_src = inputfile.read().splitlines()
		
		self.__loaded_job_config_src = True
	
	
	def __make_substitutes(self, target_dir, job_nr, job_config_src):
		"""Makes substitutes to a provided string list"""
		
		job_config = []
		
		## Loop over the file/strings in the memory
		for read_string in job_config_src:
			# replace the dummy strings
			read_string = re.sub('<SUBMISSION>',
								 target_dir,
								 read_string)
			read_string = re.sub('<JOBNAME>',
								 self.options['project_name'] + str(job_nr),
								 read_string)
			read_string = re.sub('<EXECUTE_AS>',
								 self.options['execute_as'],
								 read_string)
			read_string = re.sub('<EXECUTE_THIS>',
								 self.options['executable'],
								 read_string)
			read_string = re.sub('<RUN_DURATION>',
								 self.options['expected_run_duration'],
								 read_string)
			read_string = re.sub('<NR_OF_NODES>',
								 self.options['job_nodes'],
								 read_string)
			read_string = re.sub('<PROCESSORS_PER_NODE>',
								 self.options['processors_per_node'],
								 read_string)
			read_string = re.sub('<PROCESS_MEMORY>',
								 self.options['job_memory'],
								 read_string)
			job_config.append(read_string)
			
		return job_config



def main(argv=None):
	if argv is None:
		argv = sys.argv
	
	if len(argv) < 2:
		print 'Choose a config file for this task, like: ' +\
			submission_maker.options['config_file'] + '.\n' + '\tUsage: ' +\
			submission_maker.options['my_name'] + '.py ' +\
			submission_maker.options['config_file']
		
		sys.exit(1)
	
	### Load submission maker with a given config
	maker = submission_maker(argv[1])
	
	### Make submissions using an external packet maker
	maker.make_submissions()
	
	
	return 0



if __name__ == "__main__":
	sys.exit(main())

