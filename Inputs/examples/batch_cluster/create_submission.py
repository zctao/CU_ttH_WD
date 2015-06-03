import sys
import os
import re
import yaml

EXIT_SUCCESS = 0
EXIT_FAILURE = 1
EXIT_CYCLE_ENDED = 2

__location__ = os.path.realpath(
    os.path.join(os.getcwd(), os.path.dirname(__file__)))


class example_packet_maker:
	"""This is an example class to make packets for cluster submission."""
	
	## options are supposed to be updated by config file(s)
	options = {'project_name': 'cluster_run',
		'submission_maker': 'create_submission.py',
		'outputs_a_dir': False,
		'output_dir_name': 'submit',
		'output_files': ['test.dat', 'test.sh'],
		'executable': 'run_me.sh',
		'execute_as': 'bash',
		}
	
	def __init__(self, config):
		self.load_yaml_config(config)
		
	
	### Methods follow below
	def load_yaml_config(self, input_config=None):
		"""Used to initialize a class using parameters from a config file"""
		
		if os.path.lexists(input_config):
			with open(input_config, 'r') as config_file:
				config = yaml.load(config_file)
			
			self.options['project_name'] = config["batch_cluster"][
												  "project_name"]
			self.options['submission_maker'] = config["batch_cluster"][
													  "submission_maker"]
			self.options['outputs_a_dir'] = config["batch_cluster"][
												   "outputs_a_dir"]
			self.options['output_dir_name'] = config["batch_cluster"][
													 "output_dir_name"]
			self.options['output_files'] = config["batch_cluster"][
												  "output_files"]
			self.options['executable'] = config["batch_cluster"][
				"executable"]
			self.options['execute_as'] = config["batch_cluster"][
												"execute_as"]
			
			#Adjustments to names for local needs
			self.options['submission_maker'] = re.sub('.py', '',\
										self.options['submission_maker'])
			
		else:
			raise RuntimeError, 'A config file ' + input_config +\
				' does not exist.'
	
	
	def example_files(self):
		"""An example file-only producer."""
		
		batch_runner = os.path.join(__location__, 'test.sh')
		if not os.path.exists(batch_runner):
			f = open(batch_runner, 'w')
			f.write('#! /bin/bash\n\n')
			f.write('echo "Hello world!"\n')
			f.write('cat test.dat\n')
			f.close()
		
		batch_data = os.path.join(__location__, 'test.dat')
		if not os.path.exists(batch_data):
			f = open(batch_data, 'w')
			f.write('World hello!\n')
			f.close()
			

	def example_dir(self):
		"""An example directory producer."""
		
		target_dir = os.path.join(__location__, self.options['output_dir_name'])
		os.makedirs(target_dir)
		
		batch_runner = os.path.join(target_dir, 'test.sh')
		if not os.path.exists(batch_runner):
			f = open(batch_runner, 'w')
			f.write('#! /bin/bash\n\n')
			f.write('echo "Hello world!"\n')
			f.write('cat test.dat\n')
			f.close()
		
		batch_data = os.path.join(target_dir, 'test.dat')
		if not os.path.exists(batch_data):
			f = open(batch_data, 'w')
			f.write('World hello!\n')
			f.close()
	
	
	def make(self, packet_nr):
		"""Makes a submission packet."""
		
		#Example has only one iteration
		if int(packet_nr) == 0:
			if self.options['outputs_a_dir']:
				self.example_dir()
			else:
				self.example_files()
			
			return EXIT_CYCLE_ENDED
		else:
			return EXIT_FAILURE
		
		return EXIT_SUCCESS


# Defined here so that it can be easily used many times as a module, i.e.,
# main() can be used many times from a higher level.
packet = example_packet_maker(os.path.join(__location__, 'example.yaml'))


def main(argv=None):
	if argv is None:
		argv = sys.argv
	
	if len(argv) != 2:
		print 'Usage <module / program.py> <iteration>'
		return EXIT_FAILURE
	
	return packet.make(argv[1])


if __name__ == "__main__":
	sys.exit(main())
	