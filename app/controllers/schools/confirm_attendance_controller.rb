module Schools
  # Allow school admins to record whether or not a candidate
  # attended a booking
  class ConfirmAttendanceController < Schools::BaseController
    def show
      @bookings = unlogged_bookings.eager_load(
        :bookings_subject,
        bookings_placement_request: :candidate
      )

      assign_gitis_contacts(@bookings)
    end

    def update
      bookings_params = params
        .select { |key,_| key.match(/\A\d+\z/) }
        .transform_keys { |key| key.to_i }

      bookings = unlogged_bookings.where(id: bookings_params.keys).index_by(&:id)

      Bookings::Booking.transaction do
        bookings_params.each do |booking_id, attended|
          bookings[booking_id].tap do |booking|
            booking.attended = ActiveModel::Type::Boolean.new.cast(attended)
            booking.save
          end
        end

        redirect_to schools_dashboard_path
      end
    end

  private

    def unlogged_bookings
      current_school
        .bookings
        .previous
        .attendance_unlogged
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
end
