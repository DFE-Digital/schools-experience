###################################################
# Simple script used within the CD pipeline that
# writes a environment and release specific Docker
# Compose file. This is subsequently used by the 'az webapp config container set'
# command described in https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-multi-container-app#update-app-with-new-configuration-1 
###################################################


cat <<EOF > compose-school-experience.yml
version: '3.3'

services:
   school-experience:
     image: ${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}
     ports:
       - "3000:3000"
     restart: always
     healthcheck:
       disable: true

   delayed-jobs:
     image: ${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}
     command: rake jobs:work
     restart: always
     healthcheck:
       disable: true
EOF
echo "Using the following compose file..."
cat compose-school-experience.yml
