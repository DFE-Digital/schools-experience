class Schools::Feedback < Feedback
  enum reason_for_using_service: {
    set_up_new_school: 0,
    manage_school_experience_requests_and_bookings: 1,
    set_up_new_school_experience: 3,
    something_else: 2
  }
end
