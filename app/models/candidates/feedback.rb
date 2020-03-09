class Candidates::Feedback < Feedback
  enum reason_for_using_service: {
    make_a_school_experience_request: 0,
    withdraw_request_or_cancel_booking: 1,
    something_else: 2
  }
end
