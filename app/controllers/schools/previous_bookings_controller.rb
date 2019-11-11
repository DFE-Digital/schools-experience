module Schools
  class PreviousBookingsController < Schools::BaseController
    def index
      @bookings = scope
        .includes(:bookings_subject, bookings_placement_request:
          %i(candidate candidate_cancellation school_cancellation))
        .order(date: :desc)
        .page(params[:page])

      assign_gitis_contacts @bookings
    end

    def show
      @booking = scope.find(params[:id])

      @booking.fetch_gitis_contact gitis_crm
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

    def scope
      current_school.bookings.historical
    end
  end
end
