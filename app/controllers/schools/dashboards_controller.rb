module Schools
  class DashboardsController < BaseController
    def show
      @school = current_school
    end
  end
end
