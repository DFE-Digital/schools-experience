# PowerBI dashboard data

The powerBI db backup pipeline was migrated from the old paas environment to the new aks environment

the old pipeline was implemented using azure devops classic release pipeline.
The new pipeline is also implemented using the classic azure devops release pipeline and it is located here
https://dev.azure.com/dfe-ssp/S105-School-Experience/_release?_a=releases&view=mine&definitionId=66

the pipeline works by doing a backup of the kubernetes application database in aks. The database is accessed byport forwarding using Konduit.

There are two set of credentials used in the pipeline namely admin and perfappuser
the admin credentials is used in deleting and recreating the perf analysis database
This is the admin credentials created when the db was initialised
The admin password is set on the Azure databse server and copied to Azure devops pipeline variables

the perfappuser credentials is used when importing the database and this is created when the perf analysis database is
being created
The password is set in Azure devops pipeline variables

konduit is installed using the make file from the repository

a dump command is then run on the postgres database to dump the db into a file on the pipeline
the command that is run is
``bin/konduit.sh  -k $(KV) -d gse-production get-school-experience-production  -- pg_dump  -E utf8 --clean --if-exists --no-owner --verbose --no-password  -f  schoolexperiencedb_temp.sql``
where kv is the keyvault name(s189p01-gse-pd-inf-kv in this case), -d option refers to the database name, and get-school-experience-production  refers to the pod name
the keyvault needs to have a secret named gse-production-database-url with a value corresponding to the parttern
postgres://<ADMIN_USER>:<URLENCODED(ADMIN_PASSWORD)>@<POSTGRES_SERVER_NAME>-psql.postgres.database.azure.com:5432/<DB_NAME>
where:
URLENCODED(ADMIN_PASSWORD) is the urlencoded password
ADMIN_USER: the username of the db admin
DB_NAME is the database name (gse_production in this case)
POSTGRES_SERVER_NAME is the postgres server name,s189p01-gse-pd-pg.postgres.database.azure.com:5432 in this case


the performance db is then deleted and recreated in the next task and the exported db in schoolexperiencedb_temp.sql  is then imported into the performance database. the recreation is done using the script available at
https://raw.githubusercontent.com/DFE-Digital/school-experience-devops/master/createdb.sql

in this script the perfappuser credentials(the password) is created using the password variable 'postgresUserPassword' that is stored in the pipeline variables
perfappuser credentials is used in the data source

ogr2ogr is also used to load GeoJSON files (eer.json and topo_lad.json) into the PostgreSQL database

at the PowerBI end, in order to change the database credentials and(possibly the reference db in future if necessary) we carried out the following steps
go to Settings -> Manage connections and gateways
open the data source options menu and choose settings
change  username and password
