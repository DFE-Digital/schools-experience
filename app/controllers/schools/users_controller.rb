module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user = UserInvite.new
    end
  end
end
