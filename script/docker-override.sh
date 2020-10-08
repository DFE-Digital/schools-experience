#!/bin/bash
version="$1";

echo "version: '3.3'

services:
   school-experience:
     image: school-experience:${version}

   delayed-jobs:
     image: school-experience:${version}

   db-tasks:
     image: school-experience:${version}" > docker-compose-override.yml;

cat docker-compose-override.yml;
