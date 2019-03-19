# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :full_name,
  :email,
  :building,
  :street,
  :town_or_city,
  :county,
  :postcode,
  :phone
]
