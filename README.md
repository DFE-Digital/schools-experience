# DfE School Experience

[![Build Status](https://dfe-ssp.visualstudio.com/School-Experience/_apis/build/status/School-Experience-CI?branchName=master)](https://dfe-ssp.visualstudio.com/School-Experience/_build/latest?definitionId=33&branchName=master)

## Prerequisites

- Ruby 2.5.3
- PostgreSQL
- PostGIS extension
- Redis
- NodeJS 8.11.x
- Yarn 1.12.x

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data.
4. If you don't wish to use the first Redis Database, set the `REDIS_URL`, eg in the `.env` file
5. Run `bundle exec rails s` to launch the app on http://localhost:3000.
6. If in production, DelayedJob is needed for background job processing - run `bundle exec rake jobs:work`

## Whats included in this App?

- Rails 5.2 with Webpacker
- SassC (replacement for deprecated sass-rails)
- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Lint](https://github.com/alphagov/govuk-lint)
- Autoprefixer rails
- RSpec
- Dotenv (managing environment variables)
- Dockerfile to package app for deployment
- Azure DevOps integration

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app lib spec
```

Seems to be an issue with files already known to git being ignored. If so use

```bash
GIT_DIR=ignore bundle exec govuk-lint-ruby app lib spec
```

## HTTP Basic Auth access control

If its required to password protect then entire application then you can set two
environment variables when booting the app. This can either be part of the 
deployment configuration.

```
SECURE_USERNAME = <my-username>
SECURE_PASSWORD = <my-password>
```

## Exception notification

If required Exceptions Notifications can be sent to a Slack channel. This is 
enabled and configured via environment variables.

**SLACK_WEBHOOK** _(required)_ Webhook to use to post to Slack
**SLACK_CHANNEL** _(optional)_ Channel to post to, should be left blank if hook defaults to a specifi channel
**SLACK_ENV** _(optional)_ Identifier for deployment environment - eg Staging or Production

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
