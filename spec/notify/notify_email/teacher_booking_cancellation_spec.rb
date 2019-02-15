require 'rails_helper'

describe NotifyEmail::TeacherBookingCancellation do
  it_should_behave_like "email template", "394cf3c3-cea1-4999-99c5-1dc51449ccf4",
    school_teacher_name: "Edna Krabappel",
    school_name: "Springfield Elementary School",
    candidate_name: "Dolph Starbeam",
    placement_start_date: "2021-04-05",
    placement_finish_date: "2021-04-10",
    placement_cancellation_reason: "Looks iffy"
end
