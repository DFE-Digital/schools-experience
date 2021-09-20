# Migration Tasks
## Database
After the database has been created with terraform it will be blank and a one off task needs to be executed in development and test environments to populate it with test data.
### Development and Test Data Population
```
cf ssh school-experience-app-staging
>> cd /app
>> export PATH=${PATH}:/usr/local/bin
>> bundle exec rails db:schema:load
>> bundle exec rails db:seed
>> bundle exec rails db:migrate
>> bundle exec rails data:schools:mass_import
```

### Production
The database will need to be exported from the current production database and imported into the new one.

1. Allow your local IP address access to the database [Azure](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.DBforPostgreSQL%2Fservers)
2. Gather the sign-in details for the production database using the credentials found in [Azure](https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fsites)
3. Carry out a database dump (enter password at prompt). 
```
pg_dump  --host=HOSTNAME --port=5432 --dbname=DATABASE_NAME --username=USERNAME  -f output.sql
```
4. Connect to the new database using conduit in Cloud Foundry
```
cf conduit SERVICE_NAME -- psql
```
5. Empty the database ( if needed )
```
    \dt;
    drop owned by XXXX ;
```
where XXXX is the owner of the database tables.
6. Import the data from the old database
```
    \i output.sql
```

## DFE Sign In DSI
The sign in DSI needs to be configured per environment.
### Devevelopment and Test 
Manually via the [UI](https://pp-manage.signin.education.gov.uk/)

### Production via a Service Now Ticket.
