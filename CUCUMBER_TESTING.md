## Pre-requisites

```
git clone https://github.com/DFE-Digital/schools-experience.git
cd schools-experience
docker build -f Dockerfile -t school-experience:latest .
```

## Spin Up a Basic Environment
`docker-compose up`

Then to test, access in a browser http://localhost:3000

## To shut down

`docker-compose down`

## Spin Up a Selenium Enabled Environment
`docker-compose -f docker-compose.yml -f docker-compose-chrome.yml -f docker-compose-firefox.yml up`

## Cucumber Testing (Functional Testing)
Then to execute Cucumber tests from a temporary container against the app via a Selenium Chrome standalone node

`docker-compose run --rm -e RAILS_ENV=test -e SELENIUM_HUB_HOSTNAME=selenium-chrome -e DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true -e APP_URL='http://school-experience:3000' -v /tmp/screenshots:/app/tmp/capybara/ school-experience cucumber`

for Firefox execute

`docker-compose run --rm -e RAILS_ENV=test -e SELENIUM_HUB_HOSTNAME=selenium-firefox -e DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true -e APP_URL='http://school-experience:3000' -e CUC_DRIVER=firefox -v /tmp/screenshots:/app/tmp/capybara/ school-experience cucumber`

The html dumps will be available on the local machine in /tmp/screenshots

## Profiling Cucumber Tests using ruby-prof

Add a file `features/support/ruby_prof_cucumber.rb`

with contents

```
if ENV['RUBY_PROF'].present?
  require 'ruby-prof'
  RubyProf.start

  at_exit do
    results = RubyProf.stop
    File.open "/app/tmp/profile-graph.html", 'w' do |file|
      RubyProf::GraphHtmlPrinter.new(results).print(file)
    end 

    File.open "/app/tmp/profile-flat.txt", 'w' do |file|
      RubyProf::FlatPrinter.new(results).print(file)
    end

    File.open "/app/tmp/profile-stack.html", 'w' do |file|
      RubyProf::CallStackPrinter.new(results).print(file)
    end 
  end 
end
```

and add a line into the Gemfile

`gem 'ruby-prof'`

and then rebuild the docker image. Then run the tests with the following command

`docker-compose run --rm -e RAILS_ENV=test -e SELENIUM_HUB_HOSTNAME=selenium-chrome -e DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true -e APP_URL='http://school-experience:3000' -e DEBUG_DATABASE_CLEANER=true -v /tmp/screenshots:/app/tmp/capybara/ -v /tmp/ruby-prof:/app/tmp/ -e RUBY_PROF=true school-experience cucumber features/candidates/bookings/cancelling_a_booking.feature`

Note that the command above has restricted the profiling to a single feature. This is because the profiling processing takes a long time ( > 5 mins) . Then to view the profile results in stack form for each thread

`open /tmp/ruby-prof/profile-stack.html` 

## To shut down the Selenium enabled environment
`docker-compose -f docker-compose.yml -f docker-compose-chrome.yml -f docker-compose-firefox.yml down`
