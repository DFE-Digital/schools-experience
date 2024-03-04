module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user = DfeSignInApi::UserInvite.new
    end
  end
end
