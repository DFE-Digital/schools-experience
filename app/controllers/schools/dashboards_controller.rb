module Schools
  class DashboardsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school

      @requests_requiring_attention = current_school
        .placement_requests
        .requiring_attention
        .count

      @bookings_requiring_attention = current_school.bookings.upcoming.count

      @candidate_attendances = current_school
        .bookings
        .previous
        .attendance_unlogged
        .count
    end
  end
end
