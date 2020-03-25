# DfE School Experience

[![Build Status](https://dfe-ssp.visualstudio.com/School-Experience/_apis/build/status/School-Experience-CI?branchName=master)](https://dfe-ssp.visualstudio.com/School-Experience/_build/latest?definitionId=33&branchName=master)

## Documentation

Confluence contains most of the project documentation, a good starting point is
the Development page.

[Confluence Development page](https://dfedigital.atlassian.net/wiki/spaces/SE/pages/945618970/Development)

We also have markdown pages within the `doc` folder of this git repo

- [Environment Variables](doc/env-vars.md)
- [Release process](doc/release-process.md)

## Prerequisites

- Ruby 2.6.5 - easiest with rbenv and ruby-build
  - `brew install rbenv`
  - `brew install ruby-build`
  - `rbenv install 2.6.5`
- Bundler 2.1.4 - `gem install bundler --version 2.1.4`
- PostgreSQL with PostGIS extension
  - `brew install postgis`
  - `brew services start postgresql`
- Redis
  - `brew install redis`
  - `brew services start redis`
- NodeJS 10.x
- Yarn

## Setting up the app in development

1. Clone this repo
2. Check your dependencies
  1. ruby -v
  2. node -v
  3. bundler -v
  4. yarn -v
2. Run `bundle intall` to install ruby dependencies
3. Run `yarn` to install node dependencies
4. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data.
5. If you don't wish to use the first available Redis Database, set the `REDIS_URL`, eg in the `.env` file
6. Create SSL certificates - `bundle exec rake dev:ssl:generate`
7. Add the `config/master.key` file - this is available from other team members
8. Run `bundle exec rails s` to launch the app on https://localhost:3000.
9. If running with `RAILS_ENV=production`, DelayedJob is needed for background job processing
   1. running `bundle exec rake jobs:work` will start a DelayedJob Worker

## Whats included in this App?

- Rails 6.0 app with Webpacker
- SassC (replacement for deprecated sass-rails)
- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Lint](https://github.com/alphagov/rubocop-govuk)
- Autoprefixer rails
- RSpec
- Cucumber
- Dotenv (managing environment variables)
- Dockerfile to package app for deployment
- Azure DevOps integration

## Getting started

1. The Get school experience service (the candidate facing part), is publicly 
available but you'll need to setup School profiles to search for school. 
   1. That can be done from the [Manage school experience](https://localhost:3000/schools) service
2. The Manage school experience service requires a DfE Sign In account attached 
to a School. You can sign up for an account from the login page, but you'll 
need to get the DfE Sign-in team to approve you for a school.

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app lib spec
```

You can copy the `script/pre-commit` to `.git/hooks/pre-commit` and `git` will
then lint check your commits prior to committing.

## Configuring the application

This can be controlled from various environment variables, see 
[Env Vars](doc/env-vars.md) for more information.

## Monitoring health and deployment version

There is a `/healthcheck.txt` endpoint which will verify both Postgres and 
Redis connectivity.

There is a `/deployment.txt` endpoint which will reflect the contents of 
`DEPLOYMENT_ID` back to allow checking when the deployed version has changed.

This is protected by HTTPS Basic Auth, and is configured by the following 3 
environment variables.

`DEPLOYMENT_ID` - identifier for the current deployment
`DEPLOYMENT_USERNAME` - username to protect the endpoint
`DEPLOYMENT_PASSWORD` - password to protect the endpoint

There is also an `/healthchecks/api.txt` which is password protected using the
above credentials and will perform a check against each of the configured API 
endpoints.
