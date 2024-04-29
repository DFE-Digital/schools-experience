module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user_invite = DFESignInAPI::UserInvite.new
    end

    def create
      @user_invite = DFESignInAPI::UserInvite.new(user_params)
      @user_invite.organisation_id = DFESignInAPI::Organisation.new(current_user.sub, current_school.urn).current_organisation_id

      if params[:confirmed] == 'true'
        if @user_invite.valid?
          begin
            @user_invite.create
            redirect_to schools_users_path, notice: "#{@user_invite.email} has been added."
          rescue StandardError => e
            Rails.logger.error("User invite failed with: #{e}")
            flash.notice = "An error occurred while adding #{@user_invite.email}"
            render :show, locals: { user_invite: @user_invite }
          end
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
