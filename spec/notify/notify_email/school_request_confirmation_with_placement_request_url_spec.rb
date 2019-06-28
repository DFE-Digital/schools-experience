require 'rails_helper'

describe NotifyEmail::SchoolRequestConfirmationWithPlacementRequestUrl do
  it_should_behave_like "email template", "74f5df05-548a-4949-8ec2-fcc27b9034d7",
    candidate_address: "392 Firwood Crescent",
    candidate_dbs_check_document: "Yes",
    candidate_degree_stage: "Postgraduate",
    candidate_degree_subject: "Sociology",
    candidate_email_address: "milhouse.vh@gmail.com",
    candidate_name: "Milhouse van Houten",
    candidate_phone_number: "01234 456 678",
    candidate_teaching_stage: "I want to become a teacher",
    candidate_teaching_subject_first_choice: "Sociology",
    candidate_teaching_subject_second_choice: "Philosophy",
    placement_outcome: "I enjoy teaching",
    placement_availability: "Late Smarch",
    placement_request_url: "https://schoolexperience.edu/placement/abc123",
    school_name: "Springfield Elementary School"

  it_should_behave_like "email template from application preview", true, "https://schoolexperience.edu/placement/abc123"
end
