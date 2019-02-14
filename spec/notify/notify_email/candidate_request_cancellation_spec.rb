require 'rails_helper'

describe NotifyEmail::CandidateRequestCancellation do
  it_should_behave_like "email template", "17e87d47-afe9-477d-969d-8a4ab67280f3",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    placement_start_date: "2020-04-05",
    placement_finish_date: "2020-04-12"
end
