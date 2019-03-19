require 'rails_helper'

describe NotifyEmail::TeacherBookingCancellation do
  it_should_behave_like "email template", "7445560b-46da-4c23-9017-e8d45b2a6c84",
    school_teacher_name: "Edna Krabappel",
    school_name: "Springfield Elementary School",
    candidate_name: "Dolph Starbeam",
    placement_start_date: "2021-04-05",
    placement_finish_date: "2021-04-10",
    placement_cancellation_reason: "Looks iffy"
end
