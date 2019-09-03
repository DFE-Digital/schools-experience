class Schools::AvailabilityPreferencesController < Schools::BaseController
  def edit
    @placement_dates = @current_school.bookings_placement_dates.available
  end

  def update
    @current_school.assign_attributes(placement_date_params)

    if @current_school.save(context: :selecting_availability_preference)
      if @current_school.availability_preference_fixed?
        redirect_to schools_placement_dates_path
      else
        redirect_to schools_dashboard_path
      end
    else
      render :edit
    end
  end

private

  def placement_date_params
    params.require(:bookings_school).permit(:availability_preference_fixed)
  end
end
