# Just use the production settings
require File.expand_path("production.rb", __dir__)

Rails.application.configure do
  # Override any production defaults here

  config.x.dfe_sign_in_request_organisation_url = "https://pp-services.signin.education.gov.uk/request-organisation/search"
  config.x.git_api_endpoint = "https://get-into-teaching-api-dev.london.cloudapps.digital/api"
end
