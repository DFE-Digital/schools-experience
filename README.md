# DfE School Experience

[![Build and Deploy](https://github.com/DFE-Digital/schools-experience/actions/workflows/build.yml/badge.svg)](https://github.com/DFE-Digital/schools-experience/actions/workflows/build.yml)

## Documentation

Legacy documentation is available on Confluence; whilst some of this is still relevant its largely only useful as a historical reference.

[Confluence Development page](https://dfedigital.atlassian.net/wiki/spaces/SE/pages/945618970/Development)

We also have markdown pages within the `docs/documents` folder of this git repo

- [Environment Variables](docs/documents/env-vars.md)
- [Release process](docs/documents/release-process.md)
- [DfE Sign-in](docs/documents/dfe-signin.md)
- [Candidate notifications](docs/documents/candidate-notifications.md)
- [Inviting users to Manage School Experience](docs/documents/mse-user-invite.md)
- [DevOps processes and procedures](docs/documents/DevOps/index.md)

## Prerequisites

- Ruby 4.0.7 (see `.ruby-version`) - easiest with [asdf](https://asdf-vm.com), which reads the versions pinned in `.tool-versions`
  - `brew install asdf`
  - Add the plugins: `asdf plugin add ruby`, `asdf plugin add nodejs`, `asdf plugin add terraform` and `asdf plugin add caddy`
  - `asdf install` (installs the Ruby, Node, Terraform and Caddy versions pinned in `.tool-versions`)
- Bundler 4.0.20 - `gem install bundler --version 4.0.20`
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

### Quick start

1. Install the [prerequisites](#prerequisites) above — `asdf` and its plugins (`asdf install`), plus PostgreSQL and Redis (both running).
2. Clone this repo.
3. Run `bin/setup`.

`bin/setup` installs the Ruby and JavaScript dependencies, creates `.env.local` from `.env.template`, prepares the database, imports sample school data, and launches the app with `bin/dev` at **https://school-experience.localhost**.

Fill in the blank secret values in `.env.local` (ask another team member, or retrieve them from the Azure key vault). The candidate-facing journey works without them; DfE Sign-in (the schools/admin area) needs them.

Handy flags:

- `bin/setup --skip-dev-data` — skip importing the sample school data
- `bin/setup --skip-server` — set everything up without launching `bin/dev`

### Manual setup

If you'd prefer to install things yourself, or differently:

1. Install the Ruby and JavaScript dependencies: `bundle install` then `yarn install`.
2. Copy `.env.template` to `.env.local` and fill in the secret values.
3. Set up the database and seed test data: `bin/rails db:setup`.
4. Make sure Caddy is installed (via `asdf` per the prerequisites, or `brew install caddy`) — it provides local HTTPS; see "Local HTTPS with Caddy" below.
5. Launch the app with `bin/dev` (served at https://school-experience.localhost).

If you don't wish to use the first available Redis database, set `REDIS_URL` (e.g. in the `.env` file).

### Running the tests

- `rspec` — Ruby specs
- `cucumber` — Cucumber features
- `yarn spec` — JavaScript tests

### Background jobs

When running with `RAILS_ENV=production`, Sidekiq is needed for background job processing:

```bash
bundle exec sidekiq --config config/sidekiq.yml
```

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

- Rails 8 app with the Propshaft asset pipeline
- JavaScript bundling with esbuild (jsbundling-rails) and CSS bundling with Dart Sass (cssbundling-rails)
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
   1. That can be done from the [Manage school experience](https://school-experience.localhost/schools) service
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
[Env Vars](docs/documents/env-vars.md) for more information.

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
