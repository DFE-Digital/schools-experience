exceptions = {except: %w{schema_migrations spatial_ref_sys}}
  
options = {:pre_count => true, except: %w{schema_migrations spatial_ref_sys}}

DatabaseCleaner.clean_with(:truncation, exceptions)
DatabaseCleaner.strategy = :truncation, options
Cucumber::Rails::Database.javascript_strategy = :truncation, exceptions
if ENV['DEBUG_DATABASE_CLEANER'].present?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
