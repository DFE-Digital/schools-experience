class Candidates::Feedback < Feedback
  enum reason_for_using_service: %i(
    make_a_school_experience_request
    withdraw_request_or_cancel_booking
    something_else
  )
end
