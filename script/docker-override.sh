#!/bin/bash
version="$1";

echo <<< EOL
version: '3.3'

services:
   school-experience:
     image: school-experience:${version}

   delayed-jobs:
     image: school-experience:${version}

   db-tasks:
     image: school-experience:${version}
EOL >> docker-compose-override.yml;
cat docker-compose-override.yml;
