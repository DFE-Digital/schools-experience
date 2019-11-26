class Schools::ChangeSchoolsController < Schools::BaseController
  def show
    @schools = Bookings::School.ordered_by_name.where(urn: urns)
    @change_school = Schools::ChangeSchool.new(id: @current_school.id)
  end

  def create
    new_school = Bookings::School.find(change_school_params[:id])

    unless new_school.urn.in?(urns)
      fail 'invalid school option'
    end

    session[:urn]  = new_school.urn
    session[:name] = new_school.name

    redirect_to schools_dashboard_path
  end

private

  def change_school_params
    params.require(:schools_change_school).permit(:id)
  end

  def urns
    organisations.urns
  end

  def organisations
    @organisations ||= Schools::DFESignInAPI::Organisations.new(current_user.sub)
  end
end
