module Schools
  class InaccessibleSchoolError < StandardError; end

  class ChangeSchoolsController < Schools::BaseController
    before_action :ensure_in_app_school_changing_enabled?, only: :create

    rescue_from Schools::InaccessibleSchoolError, with: :access_denied

    def show
      @schools = Bookings::School.ordered_by_name.where(urn: urns)
      @change_school = Schools::ChangeSchool.new(id: @current_school.id)
    end

    def create
      new_school = Bookings::School.find(change_school_params[:id])

      unless new_school.urn.in?(urns)
        raise Schools::InaccessibleSchoolError, "cannot access"
      end

      session[:urn]         = new_school.urn
      session[:school_name] = new_school.name

      redirect_to schools_dashboard_path
    end

  private

    def ensure_in_app_school_changing_enabled?
      enabled = [
        Rails.configuration.x.dfe_sign_in_api_enabled,
        Rails.configuration.x.dfe_sign_in_api_school_change_enabled
      ].all?

      head(:forbidden) unless enabled
    end

    def change_school_params
      params.require(:schools_change_school).permit(:id)
    end

    def access_denied
      redirect_to schools_errors_inaccessible_school_path
    end

    def urns
      organisations.urns
    end

    def organisations
      @organisations ||= Schools::DFESignInAPI::Organisations.new(current_user.sub)
    end
  end
end
