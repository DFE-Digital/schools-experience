#!/bin/bash

MODE=NOTSET
MODE_ERROR="Mode must be be one of (  -r (--rubocop), -f (--frontend), -b (--background), -c (--brakeman) , -x (--database) )"

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -m|--migrate)
	  echo Running Migration
          bundle exec rails db:migrate
	  shift
      ;;
    -x|--database)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=DATABASE
          fi
	  shift
      ;;
    -c|--brakeman)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=BRAKEMAN
          fi
	  shift
      ;;
    -r|--rubocop)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=RUBOCOP
          fi
	  shift
      ;;
    -f|--frontend)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=FRONTEND
          fi
	  shift
      ;;
    -b|--background)
	  if [[ ${MODE} != "NOTSET" ]] ; then
		  echo ${MODE_ERROR}
	  else
	          MODE=BACKGROUND
          fi
	  shift
      ;;
    *)    # unknown option
	  echo Unknown Option
      ;;
  esac
done


if [[ ${MODE} == "FRONTEND" ]] ; then
	  echo Running Frontend
          bundle exec rails server
elif [[ ${MODE} == "BACKGROUND" ]] ; then
	  echo Running Background Jobs 
          bundle exec rake jobs:work
elif [[ ${MODE} == "RUBOCOP" ]] ; then
	  echo Running Rubocop 
	  bundle exec rubocop app config lib features spec --format json --out=/app/out/rubocop-result.json
elif [[ ${MODE} == "BRAKEMAN" ]] ; then
	  echo Running Bakeman 
	  bundle exec brakeman --no-pager
elif [[ ${MODE} == "DATABASE" ]] ; then
	  echo Running database create 
  	  bundle exec rake db:create db:schema:load
else
 echo ${MODE_ERROR}
fi
