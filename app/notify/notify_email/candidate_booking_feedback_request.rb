class NotifyEmail::CandidateBookingFeedbackRequest < NotifyDespatchers::Email
  include Rails.application.routes.url_helpers

  attr_accessor :candidate_name,
    :school_name,
    :placement_schedule,
    :feedback_url

  def initialize(
    to:,
    candidate_name:,
    school_name:,
    placement_schedule:,
    feedback_url:
  )
    self.candidate_name = candidate_name
    self.school_name = school_name
    self.placement_schedule = placement_schedule
    self.feedback_url = feedback_url

    super(to: to)
  end

  def self.from_booking(booking)
    new(
      to: booking.candidate_email,
      candidate_name: booking.candidate_name,
      school_name: booking.bookings_school.name,
      placement_schedule: booking.placement_start_date_with_duration,
      feedback_url: generate_feedback_url(booking),
    )
  end

  def self.generate_feedback_url(booking)
    url_helpers = Rails.application.routes.url_helpers
    url_helpers.new_candidates_booking_feedback_url(
      booking.token,
      host: Rails.configuration.x.base_url
    )
  end

protected

  def template_id
    "189569bd-3115-43e0-8396-be14480a5f2d"
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_schedule: placement_schedule,
      feedback_url: feedback_url
    }
  end
end
