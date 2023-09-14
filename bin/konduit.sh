#!/bin/bash
# Connect to a backend service via an app instance
#

# TODO
#
# - usually more than one redis service. Set default and how to override?
# - test against azure redis service when available
# - confirm before running if interactive, a flag to run without confirmation?
#

help() {
   echo
   echo "Script to connect to a k8 backing service via an app service"
   echo

   echo "Syntax:"
   echo "   konduit [-a|-c|-h|-i file-name|-p postgres-var|-r redis-var|-t timeout] app-name -- command [args]"
   echo "      Connect to the default database for app-name"
   echo
   echo "or konduit [-a|-c|-h|-i file-name|-r redis-var|-t timeout] -d db-name -k key-vault app-name -- command [args]"
   echo "      Connect to a specific database from app-name"
   echo "      Requires a secret containing the DB URL in the specified Azure KV,"
   echo "      with name {db-name}-database-url"
   echo
   echo "options:"
   echo "   -a                Backend is an AKS service. Default is Azure backing service."
   echo "   -c                Input file is compresses. Requires -i."
   echo "   -d db-name        Database name, required if connecting to a db other than the app default."
   echo "   -i file-name      Input file for a restore. Only valid for command psql."
   echo "   -k key-vault      Key vault that holds the Azure secret containing the DB URL."
   echo "                     The secret {db-name}-database-url must exist in this vault,"
   echo "                     and contain a full connection URL. The URL is in the format:"
   echo "                     postgres://ADMIN_USER:URLENCODED(ADMIN_PASSWORD)@POSTGRES_SERVER_NAME-psql.postgres.database.azure.com:5432/DB_NAME."
   echo "                     The ADMIN_PASSWORD can be url encoded using terraform console "
   echo "                     using CMD: urlencode(ADMIN_PASSWORD)"
   echo "   -p postgres-var   Variable for postgres [defaults to DATABASE_URL if not set]"
   echo "                     Only valid for commands psql, pg_dump or pg_restore"
   echo "   -r redis-var      Variable for redis cache [defaults to REDIS_URL if not set]"
   echo "                     Only valid for command redis-cli"
   echo "   -t timeout        Timeout in seconds. Default is 28800 but 3600 for psql, pg_dump or pg_restore commands."
   echo "   -h                Print this help."
   echo
   echo "parameters:"
   echo "   app-name     app name to connect to."
   echo "   command      command to run."
   echo "                  valid commands are psql, pg_dump, pg_restore or redis-cli"
   echo "   args         args for the command"
}

init_setup() {
   if [ "${RUNCMD}" != "psql" ] && [ "${RUNCMD}" != "pg_dump" ] && [ "${RUNCMD}" != "pg_restore" ] && [ "${RUNCMD}" != "redis-cli" ]; then
      echo
      echo "Error: invalid command ${RUNCMD}"
      echo "Only valid options are psql, pg_dump, pg_restore or redis-cli"
      help
      exit 1
   fi

   if [ "${Timeout}" = "" ]; then
      # Default timeout for psql/pg_dump/pg_restore set to 8 hours. Increase if required.
      # This is to allow for long running queries or backups.
      # The timeout is reset for each command run.
      # The timeout can be overridden with the -t option.
      TMOUT=28800 # 8 hour timeout default for nc tunnel
      if [ "${RUNCMD}" = "psql" ] && [ "${Inputfile}" != "" ]; then
         # Default timeout for restore set to 1 hour. Increase if required.
         TMOUT=3600
      elif [ "${RUNCMD}" = "pg_dump" ] || [ "${RUNCMD}" = "pg_restore" ]; then
         # Default timeout for backup set to 1 hour. Increase if required.
         TMOUT=3600
      fi
   else
     TMOUT="${Timeout}"
   fi

   # If an input file is given, check it exists and is readable
   if [ "${Inputfile}" != "" ] && [ ! -r "${Inputfile}" ]; then
      echo "Error: invalid input file"
      exit 1
   fi

   # Settings dependant on AKS or Azure backing service
   if [ "${AKS}" = "" ]; then
      # redis backing service requires TLS set for redis-cli
      TLS="--tls"
      REDIS_PORT=6380
   else
      # redis aks service does not use TLS
      TLS=""
      REDIS_PORT=6379
   fi

   # Set default Redis var if not set
   if [ "${Redis}" = "" ]; then
      Redis="REDIS_URL"
   fi

   # Set default Postgres var if not set
   if [ "${Postgres}" = "" ]; then
      Postgres="DATABASE_URL"
   fi

   # Get the deployment namespace
   NAMESPACE=$(kubectl get deployments -A | grep "${INSTANCE} " | awk '{print $1}')

   # Set service ports
   DB_PORT=5432
}

check_instance() {
   if [ "$INSTANCE" = "" ]; then
      echo "Error: Must provide instance name as parameter e.g. apply-qa, apply-review-1234"
      exit 1
   fi
   # make sure it's LC
   INSTANCE=$(echo "${INSTANCE}" | tr '[:upper:]' '[:lower:]')
   # Lets check the container exists and we can connect to it first
   if ! kubectl -n "${NAMESPACE}" exec -i deployment/"${INSTANCE}" -- echo; then
      echo "Error: Container does not exist or connection cannot be established"
      exit 1
   fi
}

set_ports() {
   # Get a random DEST port for the k8 container
   # so there is minimal conflict between users
   DEST_PORT=0
   until [ $DEST_PORT -gt 1024 ]; do
      DEST_PORT=$RANDOM
   done

   # Get a random LOCAL port
   # so we can have more than one session if wanted
   LOCAL_PORT=0
   until [ $LOCAL_PORT -gt 1024 ]; do
      LOCAL_PORT=$RANDOM
      nc -z 127.0.0.1 $LOCAL_PORT 2>/dev/null && LOCAL_PORT=0 # try again if it's in use
   done
}

set_db_psql() {
   PORT=${DB_PORT}
   # Get DB settings
   # Either from the app DATABASE_URL or the AZURE KV secret
   #
   # DATABASE_URL format (K8_URL/KV_URL)
   # for backing service
   #     postgres://ADMIN_USER:ADMIN_PASSWORD@s999t01-someapp-rv-review-99999-psql.postgres.database.azure.com:5432/someapp-postgres-review-99999
   # for k8 pod
   #     postgres://ADMIN_USER:ADMIN_PASSWORD@someapp-postgres-review-99999:5432/someapp-postgres-review-99999
   #
   if [ "${DBName}" = "" ]; then
      # If an input file is given, check it exists and is readable
      K8_URL=$(echo "echo \$${Postgres}" | kubectl -n "${NAMESPACE}" exec -i deployment/"${INSTANCE}" -- sh)
      DB_URL=$(echo "${K8_URL}" | sed "s/@[^~]*\//@127.0.0.1:${LOCAL_PORT}\//g")
      DB_NAME=$(echo "${K8_URL}" | awk -F"@" '{print $2}' | awk -F":" '{print $1}')
   else
      KV_URL=$(az keyvault secret show --name "${DBName}"-database-url --vault-name "${KV}" | jq -r .value)
      DB_URL=$(echo "${KV_URL}" | sed "s/@[^~]*\//@127.0.0.1:${LOCAL_PORT}\//g")
      DB_NAME=$(echo "${KV_URL}" | awk -F"@" '{print $2}' | awk -F":" '{print $1}')
   fi

   if [ "${KV_URL}" = "" ] && [ "${K8_URL}" = "" ] || [ "${DB_URL}" = "" ] || [ "${DB_NAME}" = "" ]; then
      echo "Error: invalid DB settings"
      exit 1
   fi
}

set_db_redis() {
   PORT=${REDIS_PORT}
   # Get DB settings
   # Either from the app REDIS_URL or the AZURE KV secret
   #
   # REDIS_URL (queue) or REDIS_CACHE_URL (cache) format (K8_URL/KV_URL)
   # for backing service
   #     rediss://:somepassword=@s9999t99-att-env-redis-service.redis.cache.windows.net:6380/0
   #
   # for k8 pod
   #     redis://someapp-redis-review-99999:6379/0
   #
   # Not tested from an azure backing service

   if [ "${DBName}" = "" ]; then
      K8_URL=$(echo "echo \$${Redis}" | kubectl -n "${NAMESPACE}" exec -i deployment/"${INSTANCE}" -- sh)
      if [ "${AKS}" = "" ]; then
         DB_URL=$(echo "${K8_URL}" | sed "s/@[^~]*\//@127.0.0.1:${LOCAL_PORT}\//g" | sed "s/rediss:\/\//rediss:\/\/default/g")
         DB_NAME=$(echo "${K8_URL}" | awk -F"@" '{print $2}' | awk -F":" '{print $1}')
      else
         DB_URL=$(echo "$K8_URL" | sed "s/\/\/[^~]*/\/\/127.0.0.1:${LOCAL_PORT}\//g")
         DB_NAME=$(echo "$K8_URL" | awk -F"/" '{print $3}' | awk -F":" '{print $1}')
      fi
   else
      KV_URL=$(az keyvault secret show --name "${DBName}"-database-url --vault-name "${KV}" | jq -r .value)
      if [ "${AKS}" = "" ]; then
         DB_URL=$(echo "${KV_URL}" | sed "s/@[^~]*\//@127.0.0.1:${LOCAL_PORT}\//g" | sed "s/rediss:\/\//rediss:\/\/default/g")
      else
         DB_URL=$(echo "${KV_URL}" | sed "s/\/\/[^~]*/\/\/127.0.0.1:${LOCAL_PORT}\//g")
      fi
      DB_NAME="${DBName}"
   fi

   if [ "${KV_URL}" = "" ] && [ "${K8_URL}" = "" ] || [ "${DB_URL}" = "" ] || [ "${DB_NAME}" = "" ]; then
      echo "Error: invalid DB settings"
      exit 1
   fi
}

open_tunnels() {
   # Open netcat tunnel between k8 deployment and postgres database
   # Timeout of 8 hours set for an interactive session
   # Testing for kubectl deployment with multiple replicas always hit the same pod (the first one?),
   # will have to revisit if it becomes an issue
   echo 'nc -v -lk -p '${DEST_PORT}' -w '${TMOUT}' -e /usr/bin/nc -w '${TMOUT} "${DB_NAME}" "${PORT}" | kubectl -n "${NAMESPACE}" exec -i deployment/"${INSTANCE}" -- sh &

   # Open local tunnel to k8 deployment
   kubectl port-forward -n "${NAMESPACE}" deployment/"${INSTANCE}" ${LOCAL_PORT}:${DEST_PORT} &
}

run_psql() {
   if [ "$Inputfile" = "" ]; then
      psql -d "$DB_URL" --no-password "${OTHERARGS}"
   elif [ "$CompressedInput" = "" ]; then
      psql -d "$DB_URL" --no-password <"$Inputfile"
   else
      gzip -d --to-stdout "${Inputfile}" | psql -d "$DB_URL" --no-password
   fi
}

run_pgdump() {
   if [ "${OTHERARGS}" = "" ]; then
      echo "ERROR: Must supply arguments for pg_dump"
      exit 1
   fi
   pg_dump -d "$DB_URL" --no-password ${OTHERARGS}
}

run_pg_restore() {
   if [ "${OTHERARGS}" = "" ]; then
      echo "ERROR: Must supply arguments for pg_restore"
      exit 1
   fi
   pg_restore -d "$DB_URL" --no-password ${OTHERARGS}
}

cleanup() {
   unset DB_URL DB_NAME K8_URL
   pkill -15 -f "kubectl port-forward.*${LOCAL_PORT}"
   sleep 3 # let the port-forward finish
   kubectl -n "${NAMESPACE}" exec -i deployment/"${INSTANCE}" -- pkill -15 -f "nc -v -lk -p ${DEST_PORT}"
}

# Get the options
while getopts "ahcd:i:k:r:p:t:" option; do
   case $option in
   a)
      AKS="True"
      ;;
   c)
      CompressedInput="True"
      ;;
   d)
      DBName=$OPTARG
      ;;
   k)
      KV=$OPTARG
      ;;
   i)
      Inputfile=$OPTARG
      ;;
   p)
      Postgres=$OPTARG
      ;;
   r)
      Redis=$OPTARG
      ;;
   t)
      Timeout=$OPTARG
      ;;
   h)
      help
      exit
      ;;
   \?)
      echo "Error: Invalid option"
      exit 1
      ;;
   esac
done
shift "$((OPTIND - 1))"
INSTANCE=$1
# $2 is --
RUNCMD=$3
shift 3
OTHERARGS=$*

###
### Main
###

init_setup
check_instance
set_ports
# Get DB settings and set the CMD to run
case $RUNCMD in
psql)
   set_db_psql
   CMD="run_psql"
   ;;
pg_dump)
   set_db_psql
   CMD="run_pgdump"
   ;;
pg_restore)
   set_db_psql
   CMD="run_pg_restore"
   ;;
redis-cli)
   set_db_redis
   CMD="redis-cli -u $DB_URL $TLS ${OTHERARGS}"
   ;;
esac
open_tunnels >/dev/null 2>&1
sleep 5 # Need to allow the connections to open
$CMD    # Run the command
echo Running cleanup...
cleanup >/dev/null 2>&1 # Cleanup on completion
