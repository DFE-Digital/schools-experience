# This method overwrites SessionsController#create so that it can log in
# users without having to mimic an entire OIDC stack.
#
# **It should only be used by Cucumber**
module InsecureCreate
  def create
    FactoryBot.create(:bookings_school, urn: 123456)

    session[:id_token]        = 'abc123'
    session[:current_user]    = {name: params[:name] || 'Joey'}
    session[:urn]             = 123456
    redirect_to schools_dashboard_path
  end
end

Schools::SessionsController.send(:prepend, InsecureCreate)
