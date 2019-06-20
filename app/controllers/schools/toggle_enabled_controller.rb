module Schools
  class ToggleEnabledController < Schools::BaseController
    include Schools::RestrictAccessUnlessOnboarded
    before_action :set_school

    def edit; end

    def update
      if current_school.update_attributes(school_availability_params)
        redirect_to schools_dashboard_path
      else
        render :edit
      end
    end

  private

    def set_school
      current_school
    end

    def school_availability_params
      params.require(:bookings_school).permit(:enabled)
    end
  end
end
