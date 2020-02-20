module Schools
  class ChangeSchoolsController < Schools::BaseController
    before_action :ensure_in_app_school_changing_enabled?, only: :create
    skip_before_action :ensure_onboarded, :set_current_school

    rescue_from Schools::ChangeSchool::InaccessibleSchoolError, with: :access_denied

    def show
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids, urn: @current_school&.urn

      @schools = @change_school.available_schools
    end

    def create
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids, change_school_params

      self.current_school = @change_school.retrieve_valid_school!

      redirect_to schools_dashboard_path
    rescue ActiveModel::ValidationError
      raise Schools::ChangeSchool::InaccessibleSchoolError
    end

  private

    def ensure_in_app_school_changing_enabled?
      head(:forbidden) unless Schools::ChangeSchool.allow_school_change_in_app?
    end

    def change_school_params
      params.require(:schools_change_school).permit(:urn)
    end

    def access_denied
      redirect_to schools_errors_inaccessible_school_path
    end
  end
end
