module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user = DFESignInAPI::UserInvite.new
    end
  end
end
