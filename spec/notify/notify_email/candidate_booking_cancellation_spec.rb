require 'rails_helper'

describe NotifyEmail::CandidateBookingCancellation do
  it_should_behave_like "email template", "af2311b2-7b7e-4342-b1da-bba957273b3e",
    school_name: "Springfield Elementary School",
    placement_start_date_with_duration: "2020-04-05",
    school_search_url: 'https://www.springfield.edu/search'
end
