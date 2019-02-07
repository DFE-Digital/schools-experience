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
5. Run `bundle exec rails s` to launch the app on http://localhost:5000.

## Whats included in this boilerplate?

- Rails 5.2 with Webpacker
- SassC (replacement for deprecated sass-rails)
- [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
- [GOV.UK Lint](https://github.com/alphagov/govuk-lint)
- Autoprefixer rails
- RSpec
- Dotenv (managing environment variables)
- Azure DevOps integration

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec govuk-lint-ruby app lib spec
```

## HTTP Basic Auth access control

If its required to password protect then entire application then you can set two
environment variables when booting the app. This can either be part of the 
deployment configuration.

```
SECURE_USERNAME = <my-username>
SECURE_PASSWORD = <my-password>
```


