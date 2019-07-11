class Schools::Feedback < Feedback
  enum reason_for_using_service: %i(
    set_up_new_school
    manage_school_experience_requests_and_bookings
    something_else
  )
end
