require 'rails_helper'

describe NotifyEmail::SchoolRequestCancellation do
  it_should_behave_like "email template", "1997e48f-33bd-4ce8-8aa7-c680f1e33e98",
    school_admin_name: "Seymour Skinner",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    placement_start_date: "2022-04-01",
    placement_finish_date: "2022-04-20"
end
