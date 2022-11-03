module Schools
  class ManageUsersController < Schools::BaseController
    def index
      organisation = Schools::DFESignInAPI::Organisations.new(current_user.sub).organisation(current_school.urn)
      school_users = Schools::DFESignInAPI::Users.new(organisation["ukprn"]).school_users
      byebug
      # gse_users = User.where()

      @users = Kaminari.paginate_array(school_users).page(params[:page]).per(15)
    end
  end
end
