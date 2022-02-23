#################################################################################################
###
### CURL the deployed containers healthcheck and return the status and SHA.
### check the SHA against a passed in parameter
###
### Input parameters ( not validated )
### 1 URL
### 2 APP SHA
###
### Returns
### 1 on failure
### 0 on sucess
###
#################################################################################################
URL=${1}
APP_SHA=${2}

#URL="review-schools-experience-1787"
#APP_SHA="e1c94c1"
#APP_SHA="e1c94cx"


if [ -z "${HTTPAUTH_USERNAME}" ]
then
    AUTHORITY=""
else
    AUTHORITY="--user ${HTTPAUTH_USERNAME}:${HTTPAUTH_PASSWORD}"
fi

rval=0
FULL_URL="https://${URL}.london.cloudapps.digital/healthcheck"

http_status()
{
     echo $(curl ${AUTHORITY} -o /dev/null -s -w "%{http_code}"  ${FULL_URL})
}

 
count=0
while [ "$(http_status)" != "200" ]
do
    if [ ${count} -eq 10 ]
    then
	    echo "Timeout after ${count} attempts"
	    break
    else
	    ((count++))
	    echo "Waiting for Server attempt ${count} of 10"
	    sleep 30
    fi
done

if [ "$(http_status)" != "200" ]
then
    echo "HTTP Status $(http_status)"
    rval=1
else
    echo "HTTP Status is Healthy"

    json=$(curl ${AUTHORITY}  -s -X GET ${FULL_URL})

    sha=$( echo ${json} | jq -r .app_sha)
    if [ "${sha}" != "sha-${APP_SHA}"  ]
    then
        echo "APP SHA (${sha}) is not sha-${APP_SHA}"
        rval=1
    else
        echo "APP SHA is correct"
    fi
fi
exit ${rval}
