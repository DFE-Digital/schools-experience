class Schools::AvailabilityInfoController < Schools::BaseController
  def edit; end

  def update
    @current_school.assign_attributes(placement_date_params)

    if @current_school.save(context: :configuring_availability)
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
