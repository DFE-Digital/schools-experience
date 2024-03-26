module Schools
  class ApproversController < BaseController
    def index
      @users = DFESignInAPI::OrganisationUsers.new(current_user.sub, current_school.urn).users
      @dfe_sign_in_manage_users_url =
        Rails.application.config.x.dfe_sign_in_manage_users_url.presence
    end
  end
end
