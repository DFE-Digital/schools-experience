module Schools
  class AttendancesController < BaseController
    def index
      @attendances = attendances(params[:page])
      assign_gitis_contacts @attendances
    end

  private

    def attendances(page)
      scope
        .order(date: :desc, id: :desc)
        .includes(:bookings_subject, bookings_placement_request: :candidate)
        .page(page)
    end

    def scope
      current_school.bookings.historical.attendance_logged
    end
  end
end
