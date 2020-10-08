#!/bin/bash
image="$1";

echo "version: '3.3'

services:
   school-experience:
     image: ${image}

   delayed-jobs:
     image: ${image}

   db-tasks:
     image: ${image}" > docker-compose-override.yml;

cat docker-compose-override.yml;
