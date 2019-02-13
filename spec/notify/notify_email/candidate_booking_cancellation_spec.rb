require 'rails_helper'
require_relative 'shared_examples'

describe NotifyEmail::CandidateBookingCancellation do
  it_should_behave_like "email template", "ec830a0d-d032-4d4b-a107-882d6f3b471f",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    start_date: "2020-04-05",
    finish_date: "2020-04-12"
end
