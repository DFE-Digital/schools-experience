source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# Required to fix a dependency issue with Rails upgrade to version 7.0.8 and the Logger error
gem "concurrent-ruby", "1.3.4"
gem 'rails', '~> 7.0.8'

gem 'json', '>= 2.3.0' # Fix for CVE-2020-10663

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Take advantage of postgresql's full text indexing
gem 'pg_search'

# PostGIS adapter for Active Record
gem 'activerecord-postgis-adapter', '8.0.3'
gem 'breasal'
gem 'geocoder'

# Use Puma as the app server
gem 'puma', '~> 6.5.0'

# Transpile app-like JavaScript. Read more: https://github.com/shakacode/shakapacker
gem 'shakapacker', '8.2.0'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Install Semantic Logger, this is needed to make Logit.io work
gem 'amazing_print'
gem 'rails_semantic_logger'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem "sidekiq", "< 7"
gem "sidekiq-cron"

# Metrics
gem "webrick"
gem 'yabeda-http_requests'
gem 'yabeda-prometheus'
gem 'yabeda-puma-plugin'
gem 'yabeda-rails'
gem 'yabeda-sidekiq'

gem 'dotenv-rails', '>= 2.7.6'

gem 'govuk_design_system_formbuilder', '~> 5.9.0'
gem 'notifications-ruby-client'

gem 'acts_as_list'
gem 'daemons'

gem "connection_pool"
gem "redis", "~> 4.7"

gem 'kaminari'

gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.1"
gem 'dfe-autocomplete', require: 'dfe/autocomplete', github: 'DFE-Digital/dfe-autocomplete'
gem 'dfe-reference-data', require: 'dfe/reference_data', github: 'DFE-Digital/dfe-reference-data', tag: 'v3.5.0'

gem "rolify"

gem 'phonelib'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'

gem 'rack-attack'
gem 'rack-rewrite'
gem 'rack-timeout'

gem 'openid_connect'
gem 'uk_postcode'

gem 'addressable'
gem 'faraday'

gem 'ice_cube'

gem 'activerecord-import'

# Using a fork until Rails 7 support is upstreamed.
# See https://github.com/adzap/validates_timeliness/pull/213
gem "validates_timeliness", github: "mitsuru/validates_timeliness", ref: "f28a625"

gem "get_into_teaching_api_client_faraday", '=3.4.0', github: "DFE-Digital/get-into-teaching-api-ruby-client", ref: 'f538756', require: "api/client"

# See https://github.com/mikel/mail/pull/1439
gem 'net-smtp', require: false

# Ignore cloudfront IPs when getting customer IP address
gem 'actionpack-cloudfront', '>= 1.2.0'

gem 'invisible_captcha', '>= 2.0.0'
gem 'meta-tags', '~> 2.22'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'benchmark'
gem 'hashids'
gem 'irb'
gem 'mutex_m'
gem 'ostruct'
gem 'reline'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'rubocop-govuk', require: false

  # Debugging
  gem 'pry-byebug'
  gem 'pry-rails'

  # Testing framework
  gem 'factory_bot_rails', '>= 6.2.0'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 6.1.1'
  gem 'rspec-sonarqube-formatter'

  gem 'brakeman', '>= 6.0.1'

  gem 'bullet'

  gem 'parallel_tests'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.8.0'
  gem 'web-console', '>= 4.2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'

  # Manage multiple processes i.e. web server and webpack
  gem 'foreman'
  gem 'rails-erd'
end

group :test do
  # Adds support for Capybara system testing and selenium
  gem 'capybara', '>= 3.38.0'

  gem 'selenium-webdriver'

  gem 'cucumber', '>= 9.2.1'
  gem 'cucumber-rails', '>= 3.1.1', require: false
  gem 'database_cleaner'

  gem 'rails-controller-testing', '>= 1.0.5'
  gem "rspec-json_expectations", "~> 2.2"
  gem 'rubocop-capybara', '~> 2.21'
  gem 'rubocop-factory_bot', '~> 2.26'
  gem 'rubocop-rspec', '~> 3.5'
  gem 'shoulda-matchers', '~> 6.1'

  gem 'capybara-screenshot'
  gem 'drb'
  gem 'simplecov', require: false
  gem 'webmock'
end
