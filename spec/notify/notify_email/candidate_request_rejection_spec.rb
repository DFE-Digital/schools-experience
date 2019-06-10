require 'rails_helper'

describe NotifyEmail::CandidateRequestRejection do
  it_should_behave_like "email template", "577100df-1dae-405e-8500-947b85edf76e",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    rejection_reasons: "Failed security checks",
    extra_details: 'HawHaw',
    dates_requested: 'Whenever really',
    school_search_url: 'https://example.com/'
end
