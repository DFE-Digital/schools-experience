# DfE School Experience

[![Build Status](https://dfe-ssp.visualstudio.com/School-Experience/_apis/build/status/School-Experience-CI?branchName=master)](https://dfe-ssp.visualstudio.com/School-Experience/_build/latest?definitionId=33&branchName=master)

## Documentation

Legacy documentation is available on Confluence; whilst some of this is still relevant its largely only useful as a historical reference.

[Confluence Development page](https://dfedigital.atlassian.net/wiki/spaces/SE/pages/945618970/Development)

We also have markdown pages within the `doc` folder of this git repo

- [Environment Variables](doc/env-vars.md)
- [Release process](doc/release-process.md)
- [DfE Sign-in](doc/dfe-sigin.md)
- [Gitis CRM](doc/gitis-crm.md)
- [Candidate notifications](doc/candidate-notifications.md)

## Prerequisites

- Ruby 3.1.4 - easiest with rbenv and ruby-build
  - `brew install rbenv`
  - `brew install ruby-build`
  - `rbenv install 3.1.4`
- Bundler 2.3.10 - `gem install bundler --version 2.3.10`
- PostgreSQL with PostGIS extension
  - `brew install postgis`
  - `brew services start postgresql`
- Redis
  - `brew install redis`
  - `brew services start redis`
- NodeJS 24.13.0
- Yarn 4.x
- Chrome (for javascript tests in Cucumber)

## Setting up the app in development

1. Clone this repo
2. Check your dependencies
3. ruby -v
4. node -v
5. bundler -v
6. yarn -v
7. Run `bundle install` to install ruby dependencies
8. Run `yarn install` to install node dependencies
9. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data.
10. If you don't wish to use the first available Redis Database, set the `REDIS_URL`, eg in the `.env` file
11. Install [Caddy](https://caddyserver.com/docs/install) (e.g. `brew install caddy`). It terminates HTTPS locally so the DfE Sign-in callback works — see "Local HTTPS with Caddy" below.
12. Get a copy of `.env.local` from another team member
13. Run `rspec` to run the spec tests.
14. Run `cucumber` to run the cucumber tests.
15. Run `yarn spec` to run the Javascript tests.
16. Run `bin/dev` to launch the app on https://school-experience.localhost.
17. If running with `RAILS_ENV=production`, Sidekiq is needed for background job processing
    a. running `bundle exec sidekiq --config config/sidekiq.yml` will start a Sidekiq Worker

### Local HTTPS with Caddy

DfE Sign-in only redirects back to a pre-registered HTTPS URL, so local development is served over HTTPS. Rather than binding Puma to a self-signed certificate, [Caddy](https://caddyserver.com/) sits in front and terminates TLS using its own locally-trusted CA (no browser certificate warnings), reverse-proxying to Rails (and the Shakapacker dev server) over plain HTTP. See [`Caddyfile.dev`](Caddyfile.dev).

- `bin/dev` starts Rails, the Shakapacker dev server, and Caddy together via [`Procfile.dev`](Procfile.dev).
- The app is served at **https://school-experience.localhost**. The `.localhost` TLD resolves to `127.0.0.1` automatically, so no `/etc/hosts` entry is needed.
- The first run will ask for your password once so Caddy can install its local CA into the system trust store.

To override the host (e.g. to fall back to `https://localhost:3000`), set `DFE_SIGNIN_BASE_URL` and adjust `Caddyfile.dev` accordingly.

#### DfE Sign-in redirect URIs

For the schools/admin login flow to complete locally, the pre-production DfE Sign-in service must have these registered for this client:

- redirect URI: `https://school-experience.localhost/auth/callback`
- post-logout redirect URI: `https://school-experience.localhost/schools`

## Whats included in this App?

- Rails 7 app with Shakapacker
- SassC (replacement for deprecated sass-rails)
- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Lint](https://github.com/alphagov/rubocop-govuk)
- Autoprefixer rails
- RSpec
- Cucumber
- Dotenv (managing environment variables)
- Dockerfile to package app for deployment
- GOV.UK terraform files

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

There is a JSON `/healthcheck` endpoint which will verify connectivity to each of the service dependencies to confirm whether the service is healthy.

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

This config is read into a dashboard available at `/feature_flags` in any of the non-production environments.

## Testing

If you have plenty of cpu cores, it is faster to run tests with parallel_tests

1. Create the databases - `bundle exec rake parallel:create`
2. Copy the schema over from the main database - `bundle exec rake parallel:prepare`
3. Run RSpecs - `bundle exec rake parallel:spec`
4. Run Cucumber features - `bundle exec rake parallel:features`

### Feature tests in headed mode

To run feature tests in a headed configuration for easier troubleshooting, add an `.env.test.local` file to the root of the project with the following environment variable:

```
SELENIUM_CHROME_DRIVER=true
```

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
