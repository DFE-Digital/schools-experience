# Bookings::Reminder is responsible for sending emails to candidates
# informing them that they have an upcoming school experience
class Bookings::Reminder
  include GitisAccess
  include Rails.application.routes.url_helpers

  def initialize(time_until_booking, bookings)
    @time_until_booking = time_until_booking

    @bookings = bookings
    assign_gitis_contacts(@bookings)
  end

  def enqueue
    Delayed::Job.transaction do
      @bookings.each do |booking|
        NotifyEmail::CandidateBookingReminder.from_booking(
          booking.candidate_email,
          @time_until_booking,
          booking,
          candidates_cancel_url(booking.token)
        ).despatch_later!
      end
    end
  end

private

  def default_url_options
    { host: Rails.configuration.x.base_url }
  end

  def assign_gitis_contacts(bookings)
    return bookings if bookings.empty?

    contacts = gitis_crm.find(bookings.map(&:contact_uuid)).index_by(&:id)

    bookings.each do |booking|
      booking.bookings_placement_request.candidate.gitis_contact = \
        contacts[booking.contact_uuid]
    end
  end
end
