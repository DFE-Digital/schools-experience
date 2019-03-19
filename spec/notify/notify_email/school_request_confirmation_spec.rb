require 'rails_helper'

describe NotifyEmail::SchoolRequestConfirmation do
  it_should_behave_like "email template", "3da1cb35-efd2-4aa6-8416-27efc5611d06",
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
    school_name: "Springfield Elementary School",
    school_admin_name: "Seymour Skinner"

  it_should_behave_like "email template from application preview", true
end
