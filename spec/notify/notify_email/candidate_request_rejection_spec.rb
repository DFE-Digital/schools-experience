require 'rails_helper'

describe NotifyEmail::CandidateRequestRejection do
  it_should_behave_like "email template", "74f84226-539a-43b0-b887-d8ffc9348965",
    school_name: "Springfield Elementary School",
    rejection_reasons: "Failed security checks",
    extra_details: 'HawHaw',
    dates_requested: 'Whenever really',
    school_search_url: 'https://example.com/'
end
