# Bookings::Reminder is responsible for sending an email to a candidate
# informing them that they have an upcoming school experience
class Bookings::Reminder
  include GitisAccess
  include Rails.application.routes.url_helpers

  def initialize(booking, time_until_booking, time_until_booking_descriptive)
    @time_until_booking = time_until_booking
    @time_until_booking_descriptive = time_until_booking_descriptive

    @booking = booking
    assign_gitis_contact(@booking)
  end

  def deliver
    NotifyEmail::CandidateBookingReminder.from_booking(
      @booking.candidate_email,
      @time_until_booking,
      @booking,
      candidates_cancel_url(@booking.token)
    ).despatch_later!
  end

private

  def default_url_options
    { host: Rails.configuration.x.base_url }
  end

  def assign_gitis_contact(booking)
    return if booking.blank?

    api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
    gitis_contact = api.get_schools_experience_sign_up(booking.contact_uuid)

    booking
      .bookings_placement_request
      .candidate.gitis_contact = gitis_contact
  end
end
