require 'rails_helper'

describe NotifyEmail::CandidateRequestCancellation do
  it_should_behave_like "email template", "12370ef4-5146-4732-87c9-76f852b4bfa9",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    requested_availability: 'won lottery going on holiday',
    school_search_url: 'https://www.springfield.edu/search'
end
