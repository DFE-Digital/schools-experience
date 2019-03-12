require 'rails_helper'

describe NotifyEmail::SchoolBookingCancellation do
  it_should_behave_like "email template", "1e0073e2-1334-4a50-a386-acc57f380e14",
    school_admin_name: "Seymour Skinner",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    placement_start_date: "2022-04-01",
    placement_finish_date: "2022-04-20"
end
