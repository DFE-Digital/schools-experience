require 'rails_helper'

describe NotifyEmail::CandidateBookingSchoolCancelsBooking do
  it_should_behave_like "email template", "d7e4fd68-0f01-4a9e-96f1-62a8a77a9de1",
    school_name: "Springfield Elementary School",
    candidate_name: "James Jones",
    rejection_reasons: "We're oversubscribed",
    extra_details: 'Maybe try rebooking... at another school!',
    dates_requested: 'Whenever really',
    school_search_url: 'https://example.com/'
end
