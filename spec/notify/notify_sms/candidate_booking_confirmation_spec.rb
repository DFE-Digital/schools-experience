require 'rails_helper'

describe NotifySms::CandidateBookingConfirmation do
  it_should_behave_like "sms template", "c034e972-a9c6-4fae-924a-25ad8bf54031",
                        school_name: "Springfield Elementary School",
                        dates_requested: "16th January",
                        cancellation_url: 'https://example.com/candiates/cancel/abc-123'
end
