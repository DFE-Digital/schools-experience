module Schools
  class UsersController < ApplicationController
    def index
      @users = current_school.users
    end
  end
end
