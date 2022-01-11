require 'rails_helper'

describe NotifySms::CandidateBookingReminder do
  it_should_behave_like "sms template", "10aa6a3b-bbe8-4e98-97b2-4409eef47496",
                        time_until_booking_descriptive: "tomorrow",
                        dates_requested: "16th January 2022",
                        cancellation_url: "https://example.com/candiates/cancel/abc-123"
end
