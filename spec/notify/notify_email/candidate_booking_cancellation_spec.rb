require 'rails_helper'

describe NotifyEmail::CandidateBookingCancellation do
  it_should_behave_like "email template", "12b5984b-be09-44fe-9f79-68aea6108f91",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    placement_start_date_with_duration: "2020-04-05",
    school_search_url: 'https://www.springfield.edu/search'
end
