source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.4', '>= 6.1.4.1'

gem 'json', '>= 2.3.0' # Fix for CVE-2020-10663

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Take advantage of postgresql's full text indexing
gem 'pg_search'

# PostGIS adapter for Active Record
gem 'activerecord-postgis-adapter', '~> 7.1'
gem 'breasal'
gem 'geocoder'

# Use Puma as the app server
gem 'puma', '~> 5.5'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Install Semantic Logger, this is needed to make Logit.io work with PaaS
gem 'amazing_print'
gem 'rails_semantic_logger'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'dotenv-rails', '>= 2.7.6'

gem 'govuk_design_system_formbuilder', '~> 2.7'
gem 'govuk_elements_form_builder', github: 'DFE-Digital/govuk_elements_form_builder'
gem 'notifications-ruby-client'

gem 'acts_as_list'
gem 'daemons'
gem 'delayed_cron_job'
gem 'delayed_job_active_record'
gem 'delayed_job_web'

gem "redis", "~> 4.4"

gem 'kaminari'

gem 'phonelib'
gem 'sentry-delayed_job'
gem 'sentry-rails', '>= 4.6.5'
gem 'sentry-ruby'

gem 'rack-attack'
gem 'rack-rewrite'
gem 'rack-timeout'

gem 'application_insights', github: 'microsoft/ApplicationInsights-Ruby', ref: 'a7429200'
gem 'openid_connect'
gem 'uk_postcode'

gem 'addressable'
gem 'faraday'

gem 'activerecord-import'
gem 'validates_timeliness', '>= 5.0.0.beta1'

gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem "get_into_teaching_api_client_faraday", github: "DFE-Digital/get-into-teaching-api-ruby-client", require: "api/client"

# Ignore cloudfront IPs when getting customer IP address
gem 'actionpack-cloudfront', '>= 1.1.0'

gem 'invisible_captcha', '>= 2.0.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

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
  gem 'rspec-rails', '~> 5.0', '>= 5.0.2'
  gem 'rspec-sonarqube-formatter'

  gem 'brakeman', '>= 4.4.0'

  gem 'bullet'

  gem 'parallel_tests'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5'
  gem 'web-console', '>= 4.1.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Manage multiple processes i.e. web server and webpack
  gem 'foreman'
  gem 'rails-erd'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'

  gem 'selenium-webdriver'
  gem 'webdrivers'

  gem 'cucumber-rails', '>= 2.4.0', require: false
  gem 'database_cleaner'

  gem 'rails-controller-testing', '>= 1.0.5'
  gem "rspec-json_expectations", "~> 2.2"
  gem 'shoulda-matchers', '~> 5.0'

  gem 'capybara-screenshot'
  gem 'flipper-active_support_cache_store'
  gem 'simplecov', require: false
  gem 'webmock'
end
