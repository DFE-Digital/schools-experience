module Schools
  class ManageUsersController < Schools::BaseController
    def index
      organisations_api = Schools::DFESignInAPI::Organisations.new(current_user.sub)
      ukprn = organisations_api.ukprn(current_school.urn)
      organisation_users = Schools::DFESignInAPI::Users.new(ukprn).organisation_users

      @users = Kaminari.paginate_array(
        User.exchange_all(organisation_users)
      ).page(params[:page]).per(15)
    end
  end
end
