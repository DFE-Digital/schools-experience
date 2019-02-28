exceptions = {except: %w{schema_migrations spatial_ref_sys}}

DatabaseCleaner.clean_with(:truncation, exceptions)
DatabaseCleaner.strategy = :truncation, exceptions
Cucumber::Rails::Database.javascript_strategy = :truncation, exceptions
