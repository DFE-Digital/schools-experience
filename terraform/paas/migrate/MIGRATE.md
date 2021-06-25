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

## DFE Sign In DSI
The sign in DSI needs to be configured per environment.
### Devevelopment and Test 
Manually via the [UI](https://pp-manage.signin.education.gov.uk/)

### Production via a Service Now Ticket.