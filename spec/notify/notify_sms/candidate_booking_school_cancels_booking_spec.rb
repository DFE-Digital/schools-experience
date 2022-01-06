require 'rails_helper'

describe NotifySms::CandidateBookingSchoolCancelsBooking do
  it_should_behave_like "sms template", "f4bbf2dc-5ebf-4723-8560-1266608e558d",
                        school_name: "Springfield Elementary School",
                        dates_requested: '16th January 2022'
end
