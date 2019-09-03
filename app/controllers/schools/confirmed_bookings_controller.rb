module Schools
  class ConfirmedBookingsController < Schools::BaseController
    def index
      @bookings = current_school
        .bookings
        .unprocessed
        .attendance_unlogged
        .accepted
        .eager_load(:bookings_subject, bookings_placement_request: :candidate)
        .order(date: :asc)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @bookings
    end

    def show
      @booking = current_school
        .bookings
        .eager_load(:bookings_subject, :bookings_placement_request)
        .find(params[:id])

      @booking.bookings_placement_request.fetch_gitis_contact gitis_crm
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
