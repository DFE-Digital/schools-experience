# A python script has been written which processes the cucumber json output. It takes two arguments, the first argument 
# is the location of the cucumber test result json file and the second is the minimum response time in nano seconds.
#
# Usage:
#  $ python check_timings.py reports/cucumber_chrome.json 2000000000
# * param1: location of the cucumber json output
# * param2: minimum response time in nanoseconds

import json
import sys
  
with open(sys.argv[1]) as data_file:
    json_data = json.load(data_file)

failures = {}

max_duration = int(sys.argv[2])

for feature in json_data:
  for scenario in feature['elements']:
    if scenario['type'] == 'scenario':
      for step in scenario['steps']:
        if step['result']['status'] == 'passed':
          if step['result']['duration'] > max_duration:
            failures[feature['id'] + ' ' + scenario['id'] + ' ' + step['name']] = step['result']['duration']

ninezeros = 1000000000

for key, value in failures.items():
  print("Duration {:.2f}s > {:.2f} {}".format( value/ninezeros, max_duration/ninezeros, key))

if len(failures) > 0:
  print("ERROR: some responses were too slow.") 
  sys.exit(1)
