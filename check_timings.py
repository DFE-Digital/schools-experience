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
