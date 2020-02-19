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

      raise Schools::InaccessibleSchoolError unless user_has_role_at_school?(current_user.sub, new_school.urn)

      session[:urn]         = new_school.urn
      session[:school_name] = new_school.name

      redirect_to schools_dashboard_path
    end

  private

    def ensure_in_app_school_changing_enabled?
      head(:forbidden) unless Schools::ChangeSchool.allow_school_change_in_app?
    end

    def change_school_params
      params.require(:schools_change_school).permit(:id)
    end

    def access_denied
      redirect_to schools_errors_inaccessible_school_path
    end

    def urns
      organisations.uuids.values
    end

    def organisations
      @organisations ||= Schools::DFESignInAPI::Organisations.new(current_user.sub)
    end

    def user_has_role_at_school?(user_uuid, organisation_uuid)
      return true unless Schools::DFESignInAPI::Client.role_check_enabled?

      Schools::DFESignInAPI::Roles.new(user_uuid, organisation_uuid).has_school_experience_role?
    rescue Faraday::ResourceNotFound
      # if the role isn't found the API returns a 404 - this means that the user
      # has insufficient privileges but this *isn't* really an error, so log it
      # and return false
      Rails.logger.warn("Role query yielded 404, uuid: #{user_uuid}, urn: #{urn}")

      false
    end
  end
end
