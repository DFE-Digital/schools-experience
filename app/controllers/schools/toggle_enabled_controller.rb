module Schools
  class ToggleEnabledController < Schools::BaseController
    before_action :set_school

    def edit; end

    def update
      if update_school_enabled_status(school_enabled_params[:enabled])
        redirect_to schools_dashboard_path
      else
        render :edit
      end
    end

  private

    def set_school
      current_school
    end

    def school_enabled_params
      params.require(:bookings_school).permit(:enabled)
    end

    def update_school_enabled_status(status)
      if ActiveModel::Type::Boolean.new.cast(status)
        current_school.enable!
      else
        current_school.disable!
      end
    end
  end
end
