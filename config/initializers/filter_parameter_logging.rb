# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i(
  password
  full_name
  first_name
  last_name
  date_of_birth
  email
  building
  street
  town_or_city
  county
  postcode
  phone
)
