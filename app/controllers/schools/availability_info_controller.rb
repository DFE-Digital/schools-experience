class Schools::AvailabilityInfoController < Schools::BaseController
  def edit; end

  def update
    if @current_school.update(placement_date_params)
      redirect_to schools_dashboard_path
    else
      render :edit
    end
  end

private

  def placement_date_params
    params
      .require(:bookings_school)
      .permit(:availability_info)
  end
end
