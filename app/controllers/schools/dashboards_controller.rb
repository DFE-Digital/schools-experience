module Schools
  class DashboardsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school

      @new_requests = current_school.placement_requests.unprocessed.count
      @new_bookings = current_school.bookings.upcoming.count
      @candidate_attendances = 4
    end
  end
end
