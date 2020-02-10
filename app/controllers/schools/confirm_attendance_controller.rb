module Schools
  # Allow school admins to record whether or not a candidate
  # attended a booking
  class ConfirmAttendanceController < Schools::BaseController
    def show
      @updated_attendance = build_outstanding_attendance
    end

    def update
      @updated_attendance = build_updated_attendance

      if @updated_attendance.save
        redirect_to schools_dashboard_path
      else
        build_outstanding_attendance
        render 'show'
      end

      # will only update those bookings which were successfully updated
      @updated_attendance.update_gitis
    end

  private

    def bookings_params
      params
        .select { |key, _| key.match(/\A\d+\z/) }
        .transform_keys(&:to_i)
        .slice(*unlogged_bookings.ids)
        # Avoid throwing key error if the user hits back button then
        # resubmits the form causing the params to no longer match up with
        # the unlogged_bookings.
    end

    def unlogged_bookings
      current_school
        .bookings
        .previous
        .attendance_unlogged
        .not_cancelled
        .accepted
        .eager_load(
          :bookings_placement_request,
          :bookings_subject,
          :bookings_school
        )
        .order(date: 'desc')
    end

    def build_outstanding_attendance
      @bookings = unlogged_bookings \
        .eager_load(:bookings_subject, bookings_placement_request: :candidate) \
        .page(params[:page])

      assign_gitis_contacts(@bookings)

      @attendance = Schools::Attendance.new bookings: @bookings, bookings_params: {}
    end

    def build_updated_attendance
      bookings = unlogged_bookings.where(id: bookings_params.keys). \
        includes(bookings_placement_request: %i(candidate candidate_cancellation school_cancellation))

      @updated_attendance = Schools::Attendance.new(bookings: bookings, bookings_params: bookings_params)
    end
  end
end
