#!/bin/bash

MODE=NOTSET
MODE_ERROR="Mode must be one of (  -b (background), -c (brakeman), -f (frontend), -r (rubocop) , -x (database) , -y (cucumber) , -z (rspec), -s (shell) )"

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -m|migrate)
	  echo Running Migration
          bundle exec rails db:migrate
	  shift
      ;;
    -p|profile)
	  echo Setting Profile ${2}
          export PROFILE=${2}
	  shift
	  shift
      ;;
    -y|cucumber)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=CUCUMBER
          fi
	  shift
      ;;
    -z|rspec)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=RSPEC
          fi
	  shift
      ;;
    -x|database)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=DATABASE
          fi
	  shift
      ;;
    -x|shell)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=SHELL
          fi
	  shift
      ;;
    -c|brakeman)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=BRAKEMAN
          fi
	  shift
      ;;
    -r|rubocop)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=RUBOCOP
          fi
	  shift
      ;;
    -f|frontend)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=FRONTEND
          fi
	  shift
      ;;
    -b|background)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=BACKGROUND
          fi
	  shift
      ;;
    *)    # unknown option
	  echo Unknown Option
	  shift
      ;;
  esac
done


if [[ ${MODE} == "FRONTEND" ]] ; then
	  echo Running Frontend
          bundle exec rails server
elif [[ ${MODE} == "BACKGROUND" ]] ; then
	  echo Running Background Jobs
          ./bin/delayed_job run
elif [[ ${MODE} == "RUBOCOP" ]] ; then
	  echo Running Rubocop
	  bundle exec rubocop app config lib features spec --format json --out=/app/out/rubocop-result.json
elif [[ ${MODE} == "BRAKEMAN" ]] ; then
	  echo Running Bakeman
	  bundle exec brakeman --no-pager
elif [[ ${MODE} == "DATABASE" ]] ; then
	  echo Running database create
  	  bundle exec rake db:create db:schema:load
elif [[ ${MODE} == "RSPEC" ]] ; then
	  echo Running rspec
  	  bundle exec rspec --format documentation --format RspecSonarqubeFormatter --out /app/out/test-report.xml
elif [[ ${MODE} == "SHELL" ]] ; then
	  echo Running shell
  	  bash
elif [[ ${MODE} == "CUCUMBER" ]] ; then
	  echo Running cucumber using profile ${PROFILE}

      # List all features to txt file.
      find . -type f -name "*.feature" > features.txt

      # Read features from text file.
      readarray -t FEATURES < features.txt

      # Determine portion of features to run.
      FEATURES_COUNT=("${#FEATURES[@]}")
      FEATURES_PER_NODE=($((FEATURES_COUNT / NODE_COUNT)))
      START_INDEX=($(((NODE - 1) * FEATURES_PER_NODE)))
      END_INDEX=($((START_INDEX + FEATURES_PER_NODE)))

      FEATURES_SUBSET=("${FEATURES[@]:START_INDEX:END_INDEX}")

      # Run subset of features.
      bundle exec cucumber "${FEATURES_SUBSET[@]}" --profile=${PROFILE} --format junit --out /app/out/
else
 echo ${MODE_ERROR}
fi
