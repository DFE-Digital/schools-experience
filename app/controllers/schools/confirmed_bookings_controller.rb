module Schools
  class ConfirmedBookingsController < Schools::BaseController
    include Schools::RestrictAccessUnlessOnboarded

    def index
      @bookings = current_school
        .bookings
        .eager_load(:bookings_subject, :bookings_placement_request)
        .all

      assign_gitis_contacts @bookings
    end

    def show
      @booking = current_school
        .bookings
        .eager_load(:bookings_subject)
        .find(params[:id])

      @booking.bookings_placement_request.fetch_gitis_contact gitis_crm
    end

  private

    def assign_gitis_contacts(bookings)
      return bookings if bookings.empty?

      contacts = gitis_crm.find(bookings.map(&:contact_uuid)).index_by(&:id)

      bookings.each do |booking|
        booking.bookings_placement_request.gitis_contact = \
          contacts[booking.contact_uuid]
      end
    end
  end
end
