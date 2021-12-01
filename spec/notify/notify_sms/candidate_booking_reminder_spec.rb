require 'rails_helper'

describe NotifySms::CandidateBookingReminder do
  it_should_behave_like "sms template", "4bcb7dc7-cf1d-47d0-8773-1183c315d284",
                        school_name: "Springfield Elementary School",
                        time_until_booking: "1 week"
end
