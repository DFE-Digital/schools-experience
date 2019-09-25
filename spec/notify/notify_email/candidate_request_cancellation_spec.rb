require 'rails_helper'

describe NotifyEmail::CandidateRequestCancellation do
  it_should_behave_like "email template", "86b06712-cb58-4cc7-82a1-3748cc9ad671",
    school_name: "Springfield Elementary School",
    requested_availability: 'won lottery going on holiday',
    school_search_url: 'https://www.springfield.edu/search'
end
