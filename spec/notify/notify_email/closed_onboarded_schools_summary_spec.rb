require 'rails_helper'

describe NotifyEmail::ClosedOnboardedSchoolsSummary do
  it_should_behave_like "email template", "a9547f2d-adb2-4cff-b9df-f2afc1ccbc66",
    closed_onboarded_schools: "data"
end
