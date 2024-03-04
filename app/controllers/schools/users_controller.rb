module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user = DFESignInAPI::UserInvite.new
    end

    def create
      @user_invite = DfeSignInApi::UserInvite.new(user_params)

      if @user_invite.valid?
        @user_invite.invite_user
        redirect_to users_path, notice: 'User invited successfully.'
      else
        render :new
      end
    end

  private

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :organisation_id)
    end
  end
end
