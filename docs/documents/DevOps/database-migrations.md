---
title: Automatic Migrations 
nav_order: 20
parent: DevOps
layout: page
---

## Automatic Migrations
The endpoint has been written for the Dockerfile. This has three parameters

- -m - Carry out migration
- -f run in frontend mode
- -b run in background jobs mode
- -s run in sidekiq jobs mode
( -f -b and -s are mutually exclusive )

## Migration Policy
In the following environments the two applications are set as

|Environment	|Frontend	|Background Jobs|
|-------------|---------|---------------|
|Development	|Migrates|	Does Not Migrate|
|Review	      |Migrates| 	Does Not Migrate|
|Staging      |	Migrates|	Does Not Migrate|
|Production   |	Migrates|	Does Not Migrate|

Development and Review run in the same space and share databases. We must take care not to remove or change existing objects unless on the master branch as this could impact older 'review' instances. Adding new objects should not normally be a problem, unless they are made mandatory and have no 'Defaults'

## Manual Migration
To manually migrate a database you need access to Cloud Foundry and the ability to ssh on to the application. Makesure the application is deployed
with the version of the code you wish to migrate the database to, then issue the following commands.

```
cf ssh school-experience-app-dev
>> cd /app
>> export PATH=${PATH}:/usr/local/bin
>> bundle exec rails db:migrate
```
