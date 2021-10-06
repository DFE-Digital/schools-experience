# Input variables
ADD_ROUTE=${1}

# Static Variables
DOMAIN="london.cloudapps.digital"
URL="https://api.london.cloud.service.gov.uk/v3/"
STATIC="review-school-experience-"
STATIC_START=1
STATIC_END=10
create=0

# Get the token needed to run this
TOKEN=$(cf oauth-token)


#  List all the applications that we are interested in
APPS=$(curl -s "${URL}/apps?per_page=2000"  -X GET  -H "Authorization: ${TOKEN}" | jq '.resources[] | select(.name | startswith("review-school-experience"))  | {name,guid}')

# Check the route we want to add exists
CURRENT=$(echo ${APPS} | jq --arg ROUTE "${ADD_ROUTE}"  '. | select (.name==$ROUTE) | {name,guid} ')
if [[ -z "${CURRENT}"  ]] ; then
    create=1
else
    create=1
    GUID=$(echo ${CURRENT}  | jq -r '.guid' )
    LIST_OF_ROUTES=$(curl -s "${URL}/routes?app_guids=${GUID}"  -X GET  -H "Authorization: ${TOKEN}" | jq '.resources[] | {host,guid,url}')
    while read i; do
        for (( v=${STATIC_START} ; v<${STATIC_END}+1 ; v++ ))
        do
            if [[ "${i}" == "${STATIC}${v}" ]] ; then
                echo "${i}"
                create=0
                break
            fi
        done
    done <<< "$( echo "${LIST_OF_ROUTES}" | jq -r  '.host ' )"
fi

if [[ ${create} == 1 ]]; then

    # Get a comman seperated list of Application GUIDs
    CSV_LIST=$( echo "${APPS}" | jq -r -c  '.guid ' | tr '\n' ',' )

    # Get a list of all the routes for all the applications
    LIST_OF_ROUTES=$(curl -s "${URL}/routes?per_page=2000&app_guids=${CSV_LIST}"  -X GET  -H "Authorization: ${TOKEN}" | jq '.resources[] | {host,guid,url}')

    # Run through each static route checking to see if it has been used. Store the result in an array
    for (( v=${STATIC_START} ; v<${STATIC_END}+1 ; v++ ))
    do
        USED[$v]=0
        # run through each application route and check if it has a static route
        while read i; do
            if [[ "${STATIC}${v}.${DOMAIN}" == ${i} ]]; then
                USED[$v]=1
            fi
        done <<< "$(echo "${LIST_OF_ROUTES}" | jq -r -c  '.url ')"
    done

    # run through the array of static routes, looking for the first unused one
    c=${STATIC_START}
    for i in "${USED[@]}"; do
        if [[ ${i} == 0 ]] ; then
            echo "${STATIC}${c}"
            break
        fi
        ((c+=1))
    done
fi
