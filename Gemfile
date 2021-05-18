source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.3'

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
gem 'puma', '~> 5.3'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'dotenv-rails'

gem 'govuk_elements_form_builder', github: 'DFE-Digital/govuk_elements_form_builder'
gem 'notifications-ruby-client'

gem 'acts_as_list'
gem 'delayed_job_active_record'
gem 'delayed_cron_job'
gem 'delayed_job_web'

gem "redis", "~> 4.2"

gem 'kaminari'

gem 'phonelib'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-delayed_job'

gem 'rack-rewrite'
gem 'rack-timeout'

gem 'openid_connect'
gem 'uk_postcode'
gem 'application_insights', github: 'microsoft/ApplicationInsights-Ruby', ref: 'a7429200'

gem 'addressable'
gem 'faraday'

gem 'validates_timeliness', '>= 5.0.0.beta1'
gem 'activerecord-import'

gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem "get_into_teaching_api_client_faraday", github: "DFE-Digital/get-into-teaching-api-ruby-client", require: "api/client"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'rubocop-govuk', require: false

  # Debugging
  gem 'pry-rails'
  gem 'pry-byebug'

  # Testing framework
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec_junit_formatter'
  gem 'factory_bot_rails'

  gem 'brakeman', '>= 4.4.0'

  gem 'bullet'

  gem 'parallel_tests'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  gem 'listen', '>= 3.0.5'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'

  # Manage multiple processes i.e. web server and webpack
  gem 'foreman'
  gem 'rails-erd'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'

  gem 'selenium-webdriver'
  gem 'webdrivers'

  gem 'cucumber-rails', require: false
  gem 'database_cleaner'

  gem 'shoulda-matchers', '~> 4.5'
  gem 'rails-controller-testing'
  gem "rspec-json_expectations", "~> 2.2"

  gem 'webmock'
  gem 'capybara-screenshot'
end

