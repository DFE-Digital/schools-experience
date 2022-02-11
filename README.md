# DfE School Experience

[![Build Status](https://dfe-ssp.visualstudio.com/School-Experience/_apis/build/status/School-Experience-CI?branchName=master)](https://dfe-ssp.visualstudio.com/School-Experience/_build/latest?definitionId=33&branchName=master)

## Documentation

Confluence contains most of the project documentation, a good starting point is
the Development page.

[Confluence Development page](https://dfedigital.atlassian.net/wiki/spaces/SE/pages/945618970/Development)

We also have markdown pages within the `doc` folder of this git repo

- [Environment Variables](doc/env-vars.md)
- [Release process](doc/release-process.md)
- [DfE Sign-in](doc/dfe-sigin.md)
- [Gitis CRM](doc/gitis-crm.md)
- [Candidate notifications](doc/candidate-notifications.md)

## Prerequisites

- Ruby 2.7.5 - easiest with rbenv and ruby-build
  - `brew install rbenv`
  - `brew install ruby-build`
  - `rbenv install 2.7.5`
- Bundler 2.2.26 - `gem install bundler --version 2.2.26`
- PostgreSQL with PostGIS extension
  - `brew install postgis`
  - `brew services start postgresql`
- Redis
  - `brew install redis`
  - `brew services start redis`
- NodeJS 14.x
- Yarn
- Chrome (for javascript tests in Cucumber)

## Setting up the app in development

1. Clone this repo
2. Check your dependencies
  1. ruby -v
  2. node -v
  3. bundler -v
  4. yarn -v
2. Run `bundle install` to install ruby dependencies
3. Run `npx yarn` to install node dependencies
4. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data.
5. If you don't wish to use the first available Redis Database, set the `REDIS_URL`, eg in the `.env` file
6. Create SSL certificates - `bundle exec rake dev:ssl:generate`
7. Add the `config/master.key` file - this is available from other team members
8. Run `bundle exec rake spec` to run the spec tests.
9. Run `bundle exec rake cucumber` to run the cucumber tests.
10. Run `yarn spec` to run the Javascript tests.
11. Run `bundle exec rails s` to launch the app on https://localhost:3000.
12. If running with `RAILS_ENV=production`, DelayedJob is needed for background job processing
   a. running `bundle exec rake jobs:work` will start a DelayedJob Worker

### If Chrome give a certificates error and will not let you proceed

1. Add the Root Certificate to macOS Keychain

    ***Via the CLI***

    Run `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain config/ssl/localhost.crt`

    ***Via the UI***

    1. Double click on `./config/ssl/localhost.crt`
    2. Right click and select "Get Info"
    3. Open "Trust" Panel
    4. Change "When using this certificate" to "Always Trust"

2. Reload the webpage
3. Open the "Advanced" pane at the bottom
4. Click "Proceed to website"

## Whats included in this App?

- Rails 6.1 app with Webpacker
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
bundle exec rubocop app config lib features spec
```

You can copy the `script/pre-commit` to `.git/hooks/pre-commit` and `git` will
then lint check your commits prior to committing.

## Configuring the application

This can be controlled from various environment variables, see
[Env Vars](doc/env-vars.md) for more information.

## Monitoring health and deployment version

There is a JSON `/healthcheck` endpoint which will verify connectivity to each of the
services dependencies to confirm whether the service is healthy.

The endpoint also includes the git commit SHA of the codebase deployed as well
as a copy of the `DEPLOYMENT_ID` to allow checking when the deployed version has
changed. This is retrieved from the following environment variable.

`DEPLOYMENT_ID` - identifier for the current deployment.

## Feature flags

We store feature flags in a JSON config (`./feature-flags.json`), so that flags are visible across all environments.

To add a feature flag, add an object to the `features` array in the following format. The `name` key is used to enable the feature (e.g., `Feature.enabled? :sms`)

```json
{
  "features": [
    {
      "name": "sms", 
      "description": "Sends reminder text messages",
      "enabled_for": {
        "environments": ["production", "staging"]
      }
    } 
  ]
}
```

This config is read into a dashboard available at `/feature_flags`.

## Testing

If you have plenty of cpu cores, it faster to run tests with parallel_tests

1. Create the databases - `bundle exec rake parallel:create`
2. Copy the schema over from the main database - `bundle exec rake parallel:prepare`
3. Run RSpecs - `bundle exec rake parallel:spec`
3. Run Cucumber features - `bundle exec rake parallel:features`

### Common issues running tests

1. If you find your tests are failing with a notice about `application.css` not being declared to be precompiled in production, run the following command

```bash
rake tmp:clear
```

2. IF you find your tests are failing with a notice about `Failure/Error: require File.expand_path('../config/environment', __dir__)` you will need to make sure you have an instance of Redis running a simple way to do this in a separate terminal is to run the following command

```bash
brew services start redis
```

or

```bash
redis-server
```

## Deployment
### Review Applications

When deploying a review application a script is run to find the first available static route (review-school-experience[1-10] ) and attach that to the review, via terraform. This enables the DFE Sign In process to work.
