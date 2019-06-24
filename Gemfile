source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Take advantage of postgresql's full text indexing
gem 'pg_search'

# PostGIS adapter for Active Record
gem 'activerecord-postgis-adapter'
gem 'breasal', require: false
gem 'geocoder'

# Use Puma as the app server
gem 'puma', '~> 3.12'

# Use SCSS for stylesheets
gem 'sassc-rails'
gem "autoprefixer-rails"

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Canonical meta tag
gem 'canonical-rails'

gem 'govuk_elements_form_builder', github: 'DFE-Digital/govuk_elements_form_builder'
gem 'notifications-ruby-client'

gem 'acts_as_list'
gem 'delayed_job_active_record'

gem "redis", "~> 4.1"

gem 'exception_notification'
gem 'slack-notifier'

gem 'dotenv-rails'

gem "font-awesome-rails"
gem 'kaminari'

gem 'phonelib'
gem 'sentry-raven'

gem 'rack-rewrite'
gem 'rack-timeout'

gem 'openid_connect'
gem 'uk_postcode'
gem 'application_insights', github: 'microsoft/ApplicationInsights-Ruby', ref: 'a7429200'

gem 'addressable'
gem 'faraday'

gem 'validates_timeliness', '~> 5.0.0.alpha4'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'rubocop', '~> 0.65.0', require: false
  # GOV.UK interpretation of rubocop for linting Ruby
  gem 'govuk-lint', require: false

  # Debugging
  gem 'pry-rails'
  gem 'pry-byebug'

  # Testing framework
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails'

  gem 'brakeman', '>= 4.4.0'

  gem 'bullet'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'

  # Manage multiple processes i.e. web server and webpack
  gem 'foreman'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'

  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper', platforms: [:mri]

  gem 'cucumber-rails', require: false
  gem 'database_cleaner'

  gem 'shoulda-matchers', '~> 4.1'
  gem 'rails-controller-testing'

  gem 'webmock'
  gem 'capybara-screenshot'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
