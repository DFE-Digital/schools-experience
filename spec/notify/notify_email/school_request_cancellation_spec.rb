require 'rails_helper'

describe NotifyEmail::SchoolRequestCancellation do
  it_should_behave_like "email template", "1d2b44bc-9d73-4839-b06b-41f35012c14d",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    cancellation_reasons: 'Spinal Tap playing same day',
    requested_availability: 'whenever',
    placement_request_url: 'http://example.com/schools/placement_requests/1'
end
