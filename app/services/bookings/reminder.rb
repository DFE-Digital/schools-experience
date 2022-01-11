# Bookings::Reminder is responsible for sending an email and SMS to a candidate
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
    despatch_reminder_email
    despatch_reminder_sms
  end

private

  def despatch_reminder_email
    NotifyEmail::CandidateBookingReminder.from_booking(
      @booking.candidate_email,
      @time_until_booking,
      @booking,
      candidates_cancel_url(@booking.token)
    ).despatch_later!
  end

  def despatch_reminder_sms
    NotifySms::CandidateBookingReminder.new(
      to: @booking.gitis_contact.telephone,
      time_until_booking_descriptive: @time_until_booking_descriptive,
      dates_requested: @booking.date.to_formatted_s(:govuk),
      cancellation_url: candidates_cancel_url(@booking.token)
    ).despatch_later!
  end

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
