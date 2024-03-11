module Schools
  class UsersController < BaseController
    def index
      @users = DFESignInAPI::OrganisationUsers.new(current_user.sub, current_school.urn).users['users']
      @dfe_sign_in_request_organisation_url =
        Rails.application.config.x.dfe_sign_in_request_organisation_url.presence
    end

    def new
      @user_invite = DFESignInAPI::UserInvite.new
    end

    def create
      @user_invite = DFESignInAPI::UserInvite.new(user_params)
      @user_invite.organisation_id = DFESignInAPI::Organisation.new(current_user.sub, current_school.urn).current_organisation_id

      if params[:confirmed] == 'true'
        if @user_invite.valid?
          invitation_response = @user_invite.invite_user
          redirect_to schools_users_path, notice: "#{@user_invite.email} has been added. With Response: #{invitation_response} and #{@user_invite.organisation_id}"
        else
          render :new
        end
      else
        render :show, locals: { user_invite: @user_invite }
      end
    end

    def show
      render :show
    end

    def edit
      @user_invite = DFESignInAPI::UserInvite.new(user_params)
      render :new, locals: { user_invite: @user_invite }
    end

  private

    def user_params
      params.require(:schools_dfe_sign_in_api_user_invite).permit(:email, :firstname, :lastname, :organisation_id)
    end
  end
end
