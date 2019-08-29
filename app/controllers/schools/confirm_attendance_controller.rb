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
      bookings = unlogged_bookings.where(id: bookings_params.keys). \
        includes(bookings_placement_request: :candidate)
      attendance = Schools::Attendance.new(bookings: bookings, bookings_params: bookings_params)

      if attendance.save
        attendance.update_gitis
        redirect_to schools_dashboard_path
      end
    end

  private

    def bookings_params
      params
        .select { |key, _| key.match(/\A\d+\z/) }
        .transform_keys(&:to_i)
    end

    def unlogged_bookings
      current_school
        .bookings
        .previous
        .attendance_unlogged
        .eager_load(
          :bookings_placement_request,
          :bookings_subject,
          :bookings_school
        )
        .order(date: 'desc')
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
