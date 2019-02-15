require 'rails_helper'

describe NotifyEmail::SchoolBookingCancellation do
  it_should_behave_like "email template", "02cef1a1-230f-4fbf-8249-9d4f2ec769d3",
    school_admin_name: "Seymour Skinner",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    placement_start_date: "2022-04-01",
    placement_finish_date: "2022-04-20"
end
