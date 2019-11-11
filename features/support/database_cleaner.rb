require 'database_cleaner/prevent_disabling_referential_integrity'

exceptions = { except: %w{schema_migrations spatial_ref_sys} }

DatabaseCleaner.clean_with :truncation, exceptions
DatabaseCleaner.strategy = :deletion, exceptions
Cucumber::Rails::Database.javascript_strategy = :deletion, exceptions
if ENV['DEBUG_DATABASE_CLEANER'].present?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
