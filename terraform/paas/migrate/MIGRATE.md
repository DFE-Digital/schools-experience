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

#### Export Existing Database

To produce an export from the Azure version of Postgres you will need to run the following command; However, first you will need to find the adminuser password and add your PC to the whitelist.

1. Using an online webpage like [WhatsMyIPAddress](https://whatismyipaddress.com/)
2. Enter the details into [Azure Postgres](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/1a8aec7a-5732-4aed-a755-a9312b443c32/resourceGroups/s105p01-prod-resource-group/providers/Microsoft.DBForPostgreSQL/servers/s105p01-prod-postgres/connectionSecurity)
3. Get the AdminUser password from [Azure Production Key Vault](https://portal.azure.com/#@platform.education.gov.uk/resource/subscriptions/1a8aec7a-5732-4aed-a755-a9312b443c32/resourceGroups/s105p01-prod-vault-resource-group/providers/Microsoft.KeyVault/vaults/s105p01-prod-vault/secrets)

This process will take a few minutes.


```
pg_dump  --host=s105p01-prod-postgres.postgres.database.azure.com --port=5432 --dbname=school_experience_prod --username=adminuser@s105p01-prod-postgres  -f output.sql
```

#### Import Database
Connect as a user with access to the new production postgres service

```
cf target -s get-into-teaching-production
cf conduit school-experience-prod-pg-common-svc -- psql
```
Delete the contents of the database, 

```
drop owned by rdsbroker_459fc751_c929_4953_b732_5f15c72a12b5_manager; 
```

Note: The owner may have changed if the database service has been destroyed and rebuilt

Import the data

```
\i output.sql
```

## API ( CRM Connection )
Needs to be amended. In the secrets.

``` make production edit-app-secrets```

## DFE Sign In DSI
The sign in DSI needs to be configured per environment. This is done by altering the values in the SE-SECRETS, via the command:

``` make production edit-app-secrets```

### Development and Test 
The setting in the Sign In Service can be amended manually via the [UI](https://pp-manage.signin.education.gov.uk/)
