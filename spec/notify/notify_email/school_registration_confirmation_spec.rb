require 'rails_helper'

describe NotifyEmail::SchoolRegistrationConfirmation do
  it_should_behave_like "email template", "1b805620-1910-40b0-afe4-4ce9e5deebbf",
    school_experience_profile_link: "https://se.gov.uk/12345",
    school_experience_dashboard_link: "https://se.gov.uk/12345/dashboard"
end
