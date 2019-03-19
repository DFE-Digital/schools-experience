require 'rails_helper'

describe NotifyEmail::SchoolRegistrationConfirmation do
  it_should_behave_like "email template", "9b32a2f9-47b7-4069-897b-5ce637c5d5ba",
    school_experience_profile_link: "https://se.gov.uk/12345",
    school_experience_dashboard_link: "https://se.gov.uk/12345/dashboard"
end
