class Schools::PlacementDatesController < Schools::BaseController
  before_action :set_placement_date, only: %w(destroy edit update)

  def index
    @placement_dates = current_school
      .bookings_placement_dates
      .published
      .future
      .in_date_order
      .eager_load(:bookings_school, :placement_date_subjects, :subjects)
  end

  def new
    @placement_date = current_school
      .bookings_placement_dates
      .new
  end

  def create
    @placement_date = current_school
      .bookings_placement_dates
      .new(new_placement_date_params)

    # if the user hasn't seen the 'select a phase' option on #new, set
    # it here based on their available phases
    if @placement_date.supports_subjects.nil?
      @placement_date.supports_subjects = school_supports_subjects?
    end

    if @placement_date.save
      next_step @placement_date
    else
      render :new
    end
  end

  def edit; end

  def update
    if @placement_date.update(edit_placement_date_params)
      next_step @placement_date
    else
      render :edit
    end
  end

private

  def school_supports_subjects?
    @current_school.phases.any?(&:supports_subjects?)
  end

  def next_step(placement_date)
    if Feature.instance.active? :subject_specific_dates
      redirect_to new_schools_placement_date_configuration_path(placement_date)
    else
      placement_date.update! published_at: DateTime.now
      redirect_to schools_placement_dates_path
    end
  end

  def set_placement_date
    @placement_date = current_school
      .bookings_placement_dates
      .find(params[:id])
  end

  def new_placement_date_params
    params.require(:bookings_placement_date).permit(:date, :duration, :active)
  end

  def edit_placement_date_params
    params.require(:bookings_placement_date).permit(:duration, :active)
  end
end
