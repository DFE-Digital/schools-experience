module Schools
  class PreviousBookingsController < Schools::BaseController
    def index
      @bookings = current_school
        .bookings
        .historical
        .includes(:bookings_subject, bookings_placement_request:
          %i(candidate candidate_cancellation school_cancellation))
        .order(date: :desc)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @bookings
    end

  private

    def assign_gitis_contacts(bookings)
      return bookings if bookings.empty?

      contacts = gitis_crm.find(bookings.map(&:contact_uuid)).index_by(&:id)

      bookings.each do |booking|
        booking.bookings_placement_request.candidate.gitis_contact = \
          contacts[booking.contact_uuid]
      end
    end
  end
end
