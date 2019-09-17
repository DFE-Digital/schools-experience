class Schools::AvailabilityPreferencesController < Schools::BaseController
  def edit
    @placement_dates = @current_school.bookings_placement_dates.available
  end

  def update
    @current_school.assign_attributes(placement_date_params)

    if @current_school.save(context: :selecting_availability_preference)
      redirect_to redirection_path
    else
      render :edit
    end
  end

private

  def redirection_path
    if @current_school.availability_preference_fixed?
      schools_placement_dates_path
    else
      edit_schools_availability_info_path
    end
  end

  def placement_date_params
    params.require(:bookings_school).permit(:availability_preference_fixed)
  end
end
