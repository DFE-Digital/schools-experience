require 'rails_helper'

describe NotifyEmail::TeacherBookingConfirmation do
  it_should_behave_like "email template", "a9e737f1-198c-4060-b341-b9485527c377",
    candidate_name: "Dolph Starbeam",
    placement_start_date: "2021-04-05",
    placement_finish_date: "2021-04-10",
    school_experience_dashboard_link: "https://se.gov.uk/12345/dashboard"
end
