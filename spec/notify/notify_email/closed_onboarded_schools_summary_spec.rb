require 'rails_helper'

describe NotifyEmail::ClosedOnboardedSchoolsSummary do
  it_behaves_like "email template", "a9547f2d-adb2-4cff-b9df-f2afc1ccbc66",
    closed_onboarded_schools: "data"
end
