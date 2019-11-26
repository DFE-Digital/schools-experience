class Schools::SchoolsController < Schools::BaseController
  def index
    @schools = Bookings::School.ordered_by_name.where(urn: urns)
  end

private
  def urns
    organisations.urns
  end

  def organisations
    @organisations ||= Schools::DFESignInAPI::Organisations.new(current_user.sub)
  end
end
