require 'rails_helper'
require_relative 'shared_examples'

describe NotifyEmail::CandidateRequestRejection do
  it_should_behave_like "email template", "7693242f-1ae4-40b9-9e4a-061f94e0587b",
    school_name: "Springfield Elementary School",
    candidate_name: "Nelson Muntz",
    rejection_reasons: "Failed security checks",
    school_experience_admin: "school-experience-admin@dfe.gov.uk",
    teaching_line_telephone_number: "01234 123 1234"
end
