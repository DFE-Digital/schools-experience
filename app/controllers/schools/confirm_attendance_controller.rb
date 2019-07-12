module Schools
  # Allow school admins to record whether or not a candidate
  # attended a booking
  class ConfirmAttendanceController < Schools::BaseController
    def show
      @bookings = current_school
        .bookings
        .eager_load(:bookings_subject, bookings_placement_request: :candidate)
        .previous
        .attendance_unlogged

      assign_gitis_contacts(@bookings)
    end

    def update
      Bookings::Booking.transaction do
        params
          .select { |k,_| k.match(/\A\d+\z/) }
          .each do |booking_id, attended|
            current_school
              .bookings
              .find(booking_id).tap do |booking|
                booking.attended = ActiveModel::Type::Boolean.new.cast(attended)
                booking.save
              end
          end

        redirect_to schools_confirm_attendance_path
      end
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
