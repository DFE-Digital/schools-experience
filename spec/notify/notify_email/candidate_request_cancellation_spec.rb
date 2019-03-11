require 'rails_helper'

describe NotifyEmail::CandidateRequestCancellation do
  it_should_behave_like "email template", "12370ef4-5146-4732-87c9-76f852b4bfa9",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    placement_start_date: "2020-04-05",
    placement_finish_date: "2020-04-12"
end
