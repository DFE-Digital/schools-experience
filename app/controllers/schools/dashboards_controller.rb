module Schools
  class DashboardsController < BaseController
    def show
      @school = current_school

      @new_requests = 5
      @new_bookings = 3
      @candidate_attendances = 4
    end
  end
end
