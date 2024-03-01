module Schools
  class UsersController < BaseController
    def index; end

    def new
      @user = InviteUser.new
    end
  end
end
