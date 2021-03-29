module Schools
  class ChangeSchoolsController < Schools::BaseController
    before_action :ensure_in_app_school_changing_enabled?, only: :create
    skip_before_action :ensure_onboarded, :set_current_school

    rescue_from Schools::ChangeSchool::InaccessibleSchoolError, with: :access_denied

    def show
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids(reload: true), change_to_urn: current_urn

      @schools = @change_school.available_schools
    end

    def create
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids(reload: true), change_school_params

      if @change_school.valid?
        assign_current_school! @change_school.retrieve_valid_school!
        redirect_to schools_dashboard_path
      else
        @schools = @change_school.available_schools
        render :show
      end
    end

  private

    def ensure_in_app_school_changing_enabled?
      head(:forbidden) unless Schools::ChangeSchool.allow_school_change_in_app?
    end

    def change_school_params
      params.fetch(:schools_change_school, {}).permit(:change_to_urn)
    end

    def access_denied
      redirect_to schools_errors_inaccessible_school_path
    end

    def assign_current_school!(new_school)
      session[:urn]         = new_school.urn
      session[:school_name] = new_school.name
    end
  end
end
