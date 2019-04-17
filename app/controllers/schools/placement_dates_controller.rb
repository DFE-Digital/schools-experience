class Schools::PlacementDatesController < Schools::BaseController
  before_action :set_placement_date, only: %w(destroy edit update)

  def index
    @placement_dates = current_school.school_profile.placement_dates.future
  end

  def new
    @placement_date = current_school
      .school_profile
      .placement_dates
      .new
  end

  def create
    @placement_date = current_school
      .school_profile
      .placement_dates
      .new(placement_date_params)

    if @placement_date.save
      redirect_to schools_placement_dates_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @placement_date.update_attributes(placement_date_params)
      redirect_to schools_placement_dates_path
    else
      render :edit
    end
  end

  def destroy
    redirect_to schools_placement_dates_path if @placement_date.destroy
  end

private

  def set_placement_date
    @placement_date = current_school.school_profile.placement_dates.find(params[:id])
  end

  def placement_date_params
    params.require(:bookings_placement_date).permit(:date, :duration)
  end
end
