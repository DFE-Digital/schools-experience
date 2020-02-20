module Schools
  class ChangeSchoolsController < Schools::BaseController
    before_action :ensure_in_app_school_changing_enabled?, only: :create
    skip_before_action :ensure_onboarded, :set_current_school

    rescue_from Schools::ChangeSchool::InaccessibleSchoolError, with: :access_denied

    def show
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids, id: @current_school&.id

      @schools = @change_school.available_schools
    end

    def create
      @change_school = Schools::ChangeSchool.new \
        current_user, school_uuids, change_school_params

      new_school = @change_school.retrieve_valid_school!

      unless user_has_role_at_school?(current_user.sub, new_school.urn)
        raise Schools::ChangeSchool::InaccessibleSchoolError
      end

      self.current_school = new_school

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
