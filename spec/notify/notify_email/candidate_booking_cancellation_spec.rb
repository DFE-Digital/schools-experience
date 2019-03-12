require 'rails_helper'

describe NotifyEmail::CandidateBookingCancellation do
  it_should_behave_like "email template", "12b5984b-be09-44fe-9f79-68aea6108f91",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    placement_start_date: "2020-04-05",
    placement_finish_date: "2020-04-12"
end
