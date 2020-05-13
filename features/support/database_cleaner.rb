require 'database_cleaner/prevent_disabling_referential_integrity'

truncation_options = { except: %w[schema_migrations spatial_ref_sys] }
deletion_options = {
  only: %w[
    events schools_school_profiles
    bookings_placement_request_cancellations
    bookings_bookings bookings_placement_requests
    candidates_session_tokens bookings_candidates
    bookings_profiles bookings_placement_date_subjects bookings_placement_dates
    bookings_schools_subjects bookings_schools_phases bookings_schools
    bookings_subjects bookings_phases
  ]
}

DatabaseCleaner.clean_with :truncation, truncation_options
at_exit do
  DatabaseCleaner.clean_with :truncation, truncation_options
end

DatabaseCleaner.strategy = :deletion, deletion_options
Cucumber::Rails::Database.javascript_strategy = :deletion, deletion_options
if ENV['DEBUG_DATABASE_CLEANER'].present?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
