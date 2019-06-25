module Schools
  class DashboardsController < BaseController
    def show
      @school = current_school

      @new_requests = current_school.placement_requests.open.count
      @new_bookings = current_school.bookings.upcoming.count
      @candidate_attendances = 4
    end
  end
end
