require 'rails_helper'

describe NotifyEmail::CandidateBookingConfirmation do
  it_should_behave_like "email template", "482c3495-8e99-46f0-93d4-b88e31879565",
    school_name: "Springfield Elementary",
    candidate_name: "Kearney Zzyzwicz",
    start_date: "2022-01-01",
    finish_date: "2022-02-01",
    school_start_time: "08:40",
    school_finish_time: "15:30",
    school_dress_code: "Smart casual, elbow patches",
    school_parking: "There is a car park on the school grounds",
    school_admin_name: "Seymour Skinner",
    school_admin_email: "sskinner@springfield.co.uk",
    school_admin_telephone: "01234 123 1234",
    school_teacher_name: "Edna Krabappel",
    school_teacher_email: "ednak@springfield.co.uk",
    school_teacher_telephone: "01234 234 1245",
    placement_details: "You will shadow a teacher and assist with lesson planning",
    placement_fee: 30
end
