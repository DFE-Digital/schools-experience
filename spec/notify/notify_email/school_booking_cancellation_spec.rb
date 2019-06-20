require 'rails_helper'

describe NotifyEmail::SchoolBookingCancellation do
  it_should_behave_like "email template", "1e0073e2-1334-4a50-a386-acc57f380e14",
    school_name: "Springfield Elementary School",
    candidate_name: "Otto Mann",
    placement_start_date_with_duration: "2022-04-01 for 1 day"
end
